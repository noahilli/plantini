'use strict';

const { ApplicationError } = require('@strapi/utils').errors;

function fail(detail) {
  throw new ApplicationError(`Generierter Lernpfad noch nicht veröffentlichbar: ${detail}`);
}

function assertPublishedDependencies(level) {
  const sameRelease = (record) => record?.publishedAt && record.releaseVersion === level.releaseVersion;
  if (!sameRelease(level.ecosystem)) fail('Ökosystem zuerst in derselben Inhaltsversion veröffentlichen.');
  if (!level.plants?.length || level.plants.some((plant) => !sameRelease(plant) || plant.reviewStatus !== 'approved')) {
    fail('Alle Pflanzen müssen fachlich freigegeben und in derselben Inhaltsversion veröffentlicht sein.');
  }
  const required = level.completionRule?.requiredQuizIds;
  if (!Array.isArray(required) || required.length !== 3 || new Set(required).size !== 3) {
    fail('Drei unterschiedliche Pflichtfragen erforderlich.');
  }
  for (const id of required) {
    const quiz = level.quizzes?.find((item) => item.publicId === id);
    if (!sameRelease(quiz) || quiz.reviewStatus !== 'approved'
      || quiz.contentVersion !== level.releaseVersion) {
      fail('Alle drei Pflichtfragen müssen fachlich freigegeben und in derselben Inhaltsversion veröffentlicht sein.');
    }
  }
}

module.exports = {
  beforeCreate(event) {
    if (event.params.data.generatedFromBlueprint && event.params.data.publishedAt) {
      fail('Zuerst als Entwurf speichern und die zugehörigen Fragen prüfen.');
    }
  },
  async beforeUpdate(event) {
    const data = event.params.data;
    // Explicit unpublish always remains available, including broken drafts.
    if (data.publishedAt === null) return;
    const current = await strapi.entityService.findOne('api::level.level', event.params.where.id, {
      populate: { ecosystem: true, plants: true, quizzes: true },
    });
    if (!current?.generatedFromBlueprint && !data.generatedFromBlueprint) return;
    if (!data.publishedAt && !current.publishedAt) return;
    const blueprints = await strapi.entityService.findMany('api::journey-blueprint.journey-blueprint', {
      filters: { slug: current.generatedFromBlueprint }, limit: 1,
    });
    const blueprint = blueprints[0];
    if (blueprint?.generationState !== 'ready'
      || blueprint.generationFingerprint !== current.generationFingerprint) {
      fail('Die zugehörige Entwurfsserie muss vollständig generiert sein und die aktuell ausgewählte Serie sein.');
    }
    // Publication must validate the saved graph, not stale relations from the
    // same mutation. Content Manager's separate save/publish flow supports this.
    for (const relation of ['ecosystem', 'plants', 'quizzes']) {
      const value = data[relation];
      if (value !== undefined && !(value && !Array.isArray(value)
        && Object.keys(value).every((key) => ['connect', 'disconnect'].includes(key))
        && !(value.connect?.length || value.disconnect?.length))) {
        fail('Beziehungen zuerst im unveröffentlichten Entwurf speichern.');
      }
    }
    if (data.completionRule !== undefined
      && JSON.stringify(data.completionRule) !== JSON.stringify(current.completionRule)) {
      fail('Abschlussregeln zuerst im unveröffentlichten Entwurf speichern.');
    }
    assertPublishedDependencies({ ...current, releaseVersion: data.releaseVersion || current.releaseVersion });
  },
};
