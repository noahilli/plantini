'use strict';

const { newId, requireUuid } = require('../ids');
const { invalidRequest, notFound, ProblemError } = require('../errors');
const { requirePlainObject, requireString, rejectUnknownFields } = require('../validation');
const { KeycloakStudents } = require('./keycloak-students');

const CLASS = 'api::teaching-class.teaching-class';
const STUDENT = 'api::teaching-student.teaching-student';
const AUDIT = 'api::teaching-audit.teaching-audit';

class TeachingService {
  constructor(strapi, runtime, identity = new KeycloakStudents()) {
    this.strapi = strapi;
    this.entities = strapi.entityService;
    this.runtime = runtime;
    this.identity = identity;
  }

  session(actor) {
    requireTeacher(actor);
    return { actor: { id: actor.id, displayName: actor.displayName, roles: actor.roles }, capabilities: { manageStudents: this.identity.configured } };
  }

  async ensureIndexes() {
    // Additive indexes run after Strapi has created the new model tables.
    // Both supported engines accept IF NOT EXISTS; no existing rows change.
    for (const [name, table, column] of [
      ['teaching_classes_owner_idx', 'teaching_classes', 'owner_subject'],
      ['level_attempts_owner_idx', 'level_attempts', 'owner_id'],
    ]) {
      await this.strapi.db.connection.raw(`CREATE INDEX IF NOT EXISTS ${name} ON ${table} (${column})`);
    }
  }

  async classes(actor) {
    requireTeacher(actor);
    const records = await this.entities.findMany(CLASS, {
      filters: { ownerSubject: actor.subject }, populate: { students: { fields: ['publicId'] } }, sort: { createdAt: 'desc' }, limit: 101,
    });
    return { classes: records.map(classSummary) };
  }

  async createClass(actor, body) {
    requireTeacher(actor);
    requirePlainObject(body); rejectUnknownFields(body, ['name', 'description']);
    const name = requireString(body.name, 'name', { max: 100 });
    const description = body.description == null || body.description === '' ? '' : requireString(body.description, 'description', { max: 1000 });
    if (await this.entities.count(CLASS, { filters: { ownerSubject: actor.subject } }) >= 100) throw limitReached('Maximal 100 Klassen pro Lehrperson sind möglich.');
    const publicId = newId();
    return this.audited(actor, publicId, 'class_created', async () => {
      const classroom = await this.entities.create(CLASS, { data: { publicId, ownerSubject: actor.subject, name, description } });
      return classSummary(classroom);
    });
  }

  async requireClass(actor, id) {
    requireTeacher(actor); requireUuid(id, 'classId');
    const [classroom] = await this.entities.findMany(CLASS, { filters: { publicId: id, ownerSubject: actor.subject }, limit: 1 });
    if (!classroom) throw notFound('TEACHING_CLASS_NOT_FOUND');
    return classroom;
  }

  async requireStudent(actor, id) {
    requireTeacher(actor); requireUuid(id, 'studentId');
    const [student] = await this.entities.findMany(STUDENT, {
      filters: { publicId: id, classroom: { ownerSubject: actor.subject } }, populate: { classroom: true }, limit: 1,
    });
    if (!student || student.classroom?.ownerSubject !== actor.subject) throw notFound('TEACHING_STUDENT_NOT_FOUND');
    return student;
  }

  async classroom(actor, id) {
    const classroom = await this.requireClass(actor, id);
    const students = await this.entities.findMany(STUDENT, { filters: { classroom: { id: classroom.id } }, sort: { displayName: 'asc' }, limit: 501 });
    const { levels, ecosystems, attempts } = await this.progressData(students);
    return { class: { ...classSummary(classroom), studentCount: students.length }, students: students.map((student) => this.studentProgress(student, levels, ecosystems, attempts)) };
  }

  async createStudent(actor, classId, body) {
    const classroom = await this.requireClass(actor, classId);
    requirePlainObject(body); rejectUnknownFields(body, ['username', 'displayName', 'email']);
    const username = requireString(body.username, 'username', { min: 3, max: 64 }).toLowerCase();
    if (!/^[a-z0-9][a-z0-9._-]+$/.test(username)) throw invalidRequest({ username: '3–64 Zeichen: Kleinbuchstaben, Zahlen, Punkt, Unterstrich oder Bindestrich.' });
    const displayName = requireString(body.displayName, 'displayName', { max: 100 });
    const email = body.email == null || body.email === '' ? undefined : requireString(body.email, 'email', { max: 254 }).toLowerCase();
    if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw invalidRequest({ email: 'Bitte eine gültige E-Mail-Adresse eingeben.' });
    if (await this.entities.count(STUDENT, { filters: { classroom: { id: classroom.id } } }) >= 500) throw limitReached('Maximal 500 Schülerkonten pro Klasse sind möglich.');
    const publicId = newId();
    return this.audited(actor, publicId, 'student_created', async () => {
      const account = await this.identity.create({ username, displayName, email });
      let student;
      let profile;
      try {
        profile = await this.runtime.repositories.profiles.create({ profileId: newId(), keycloakSubject: account.subject, displayName, locale: 'de-DE', status: 'suspended' });
        student = await this.entities.create(STUDENT, { data: {
          publicId, keycloakSubject: account.subject, profileId: profile.profileId, username, displayName,
          ...(email ? { email } : {}), enabled: false, classroom: classroom.id,
        } });
      } catch (error) {
        await this.identity.removeNewAccount(account.subject).catch(() => {});
        if (profile) await this.entities.delete('api::profile.profile', profile.id).catch(() => {});
        throw error;
      }
      // Retain a visible, disabled account if activation fails. The teacher can
      // reset its password and enable it later instead of losing its ownership.
      try {
        await this.identity.setEnabled(account.subject, true);
        student = await this.entities.update(STUDENT, student.id, { data: { enabled: true } });
        await this.runtime.repositories.profiles.update(student.profileId, { status: 'active' });
      } catch (error) {
        // A database write can commit and still report a lost response. Restore
        // the API block before attempting cleanup at the external provider.
        await this.runtime.repositories.profiles.update(student.profileId, { status: 'suspended', tokensValidAfter: new Date().toISOString() }).catch(() => {});
        await this.identity.setEnabled(account.subject, false).catch(() => {});
        await this.entities.update(STUDENT, student.id, { data: { enabled: false } }).catch(() => {});
        throw error;
      }
      return { student: studentSummary(student), temporaryPassword: account.temporaryPassword };
    });
  }

  async resetPassword(actor, id, body = {}) {
    const student = await this.requireStudent(actor, id);
    requirePlainObject(body); rejectUnknownFields(body, []);
    await this.identity.requireManagedLearner(student.keycloakSubject);
    return this.audited(actor, id, 'password_reset', async () => {
      await this.runtime.repositories.profiles.update(student.profileId, { tokensValidAfter: new Date().toISOString() });
      try {
        return { temporaryPassword: await this.identity.resetPassword(student.keycloakSubject) };
      } finally {
        // Also reject tokens refreshed while the external reset was running.
        await this.runtime.repositories.profiles.update(student.profileId, { tokensValidAfter: new Date().toISOString() });
      }
    });
  }

  async updateStudent(actor, id, body) {
    const student = await this.requireStudent(actor, id);
    requirePlainObject(body); rejectUnknownFields(body, ['enabled']);
    if (typeof body.enabled !== 'boolean') throw invalidRequest({ enabled: 'Muss wahr oder falsch sein.' });
    await this.identity.requireManagedLearner(student.keycloakSubject);
    return this.audited(actor, id, body.enabled ? 'student_enabled' : 'student_disabled', async () => {
      // Deny API access immediately, including already issued access tokens.
      if (!body.enabled) await this.runtime.repositories.profiles.update(student.profileId, { status: 'suspended', tokensValidAfter: new Date().toISOString() });
      try {
        await this.identity.setEnabled(student.keycloakSubject, body.enabled);
        const updated = await this.entities.update(STUDENT, student.id, { data: { enabled: body.enabled } });
        await this.runtime.repositories.profiles.update(student.profileId, { status: body.enabled ? 'active' : 'suspended', tokensValidAfter: new Date().toISOString() });
        return { student: studentSummary(updated) };
      } catch (error) {
        await this.runtime.repositories.profiles.update(student.profileId, { status: 'suspended', tokensValidAfter: new Date().toISOString() }).catch(() => {});
        await this.entities.update(STUDENT, student.id, { data: { enabled: false } }).catch(() => {});
        await this.identity.setEnabled(student.keycloakSubject, false).catch(() => {});
        throw error;
      }
    });
  }

  async dashboard(actor) {
    requireTeacher(actor);
    const { classes } = await this.classes(actor);
    const students = await this.entities.findMany(STUDENT, {
      filters: { classroom: { ownerSubject: actor.subject } }, populate: { classroom: true }, limit: 50001,
    });
    const { levels, ecosystems, attempts } = await this.progressData(students);
    const rows = students.map((student) => this.studentProgress(student, levels, ecosystems, attempts));
    const completedLevels = rows.reduce((sum, row) => sum + row.completedLevels, 0);
    const totalLevels = students.length * levels.length;
    const studentByOwner = new Map(students.map((student) => [student.profileId, student]));
    const levelById = new Map(levels.map((level) => [level.publicId, level]));
    const recentActivity = attempts.filter((attempt) => attempt.status === 'completed' && attempt.passed && levelById.has(attempt.levelPublicId))
      .sort((a, b) => Date.parse(b.completedAt) - Date.parse(a.completedAt)).slice(0, 8).map((attempt) => {
        const student = studentByOwner.get(attempt.ownerId);
        return { studentId: student.publicId, displayName: student.displayName, className: student.classroom.name, completedAt: attempt.completedAt, levelTitle: levelById.get(attempt.levelPublicId).title };
      });
    return {
      classes: classes.length, students: students.length, activeStudents: students.filter((student) => student.enabled).length,
      completedLevels, totalLevels, averageProgress: totalLevels ? completedLevels / totalLevels : 0,
      ecosystems: ecosystems.map((ecosystem) => {
        const total = levels.filter((level) => level.ecosystem?.publicId === ecosystem.publicId).length * students.length;
        const completed = rows.reduce((sum, row) => sum + (row.ecosystems.find((item) => item.id === ecosystem.publicId)?.completedLevels || 0), 0);
        return { id: ecosystem.publicId, name: ecosystem.name, totalLevels: total, completedLevels: completed, progress: total ? completed / total : 0 };
      }), recentActivity,
    };
  }

  async progressData(students) {
    const [levels, ecosystemPage, attempts] = await Promise.all([
      this.runtime.repositories.learning.listPublishedLevels(),
      this.runtime.repositories.content.listPublishedEcosystems({ page: 1, pageSize: 1000 }),
      students.length ? this.strapi.db.query('api::level-attempt.level-attempt').findMany({
        where: { ownerId: { $in: students.map((student) => student.profileId) } },
        select: ['ownerId', 'levelPublicId', 'status', 'passed', 'startedAt', 'completedAt'],
      }) : [],
    ]);
    return { levels, ecosystems: ecosystemPage.items, attempts };
  }

  studentProgress(student, levels, ecosystems, attempts) {
    const history = attempts.filter((attempt) => attempt.ownerId === student.profileId);
    const completed = new Set(history.filter((attempt) => attempt.status === 'completed' && attempt.passed).map((attempt) => attempt.levelPublicId));
    const completedLevels = levels.filter((level) => completed.has(level.publicId)).length;
    const lastActivityAt = history.map((attempt) => attempt.completedAt || attempt.startedAt).filter(Boolean).sort((a, b) => Date.parse(b) - Date.parse(a))[0] || null;
    return { ...studentSummary(student), completedLevels, totalLevels: levels.length, progress: levels.length ? completedLevels / levels.length : 0, lastActivityAt,
      ecosystems: ecosystems.map((ecosystem) => {
        const ecosystemLevels = levels.filter((level) => level.ecosystem?.publicId === ecosystem.publicId);
        const count = ecosystemLevels.filter((level) => completed.has(level.publicId)).length;
        return { id: ecosystem.publicId, name: ecosystem.name, completedLevels: count, totalLevels: ecosystemLevels.length, progress: ecosystemLevels.length ? count / ecosystemLevels.length : 0 };
      }),
    };
  }

  async audited(actor, targetId, action, task) {
    const data = { publicId: newId(), actorSubject: actor.subject, targetId, action };
    await this.entities.create(AUDIT, { data: { ...data, result: 'started' } });
    try {
      const result = await task();
      // The durable start event records intent even if the completion insert
      // fails. Never discard a one-time password after its mutation succeeded.
      await this.entities.create(AUDIT, { data: { ...data, publicId: newId(), result: 'succeeded' } }).catch(() => {
        this.strapi.log.error('Teaching audit completion could not be recorded; start event remains available.');
      });
      return result;
    } catch (error) {
      await this.entities.create(AUDIT, { data: { ...data, publicId: newId(), result: 'failed' } }).catch(() => {});
      throw error;
    }
  }
}

function requireTeacher(actor) {
  if (!actor?.roles?.some((role) => ['lehrende', 'systemadministration'].includes(role))) throw new ProblemError('TEACHING_FORBIDDEN', { status: 403, detail: 'Dieses Portal ist für Lehrende freigeschaltet.' });
}
function classSummary(classroom) {
  return { id: classroom.publicId, name: classroom.name, description: classroom.description || '', studentCount: classroom.students?.length || 0, createdAt: classroom.createdAt };
}
function studentSummary(student) {
  return { id: student.publicId, username: student.username, displayName: student.displayName, ...(student.email ? { email: student.email } : {}), enabled: student.enabled };
}
function limitReached(detail) { return new ProblemError('TEACHING_LIMIT_REACHED', { status: 409, detail }); }

module.exports = { TeachingService, requireTeacher };
