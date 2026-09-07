'use strict';

// Small entity-service boundary fixture: numeric CMS relations are populated
// here so tests exercise the real public-ID repository adapter as well.
function memoryEntities() {
  const tables = new Map();
  const writes = [];
  const table = (uid) => {
    if (!tables.has(uid)) tables.set(uid, []);
    return tables.get(uid);
  };
  const uidFor = (kind) => `api::${kind}.${kind}`;
  function relation(uid, record, key) {
    if (key === 'ecosystem') return table(uidFor('ecosystem')).find((item) => item.id === record.ecosystem);
    if (key === 'level') return table(uidFor('level')).find((item) => item.id === record.level);
    if (key === 'plants') return table(uidFor('plant')).filter((item) => record.plants?.includes(item.id));
    if (key === 'quizzes') return table(uidFor('quiz')).filter((item) => item.level === record.id);
    if (key === 'levels' && uid === uidFor('ecosystem')) {
      return table(uidFor('level')).filter((item) => item.ecosystem === record.id);
    }
    return record[key];
  }
  function matches(uid, record, filters = {}) {
    return Object.entries(filters).every(([key, expected]) => {
      if (key === '$or') return expected.some((filter) => matches(uid, record, filter));
      const value = record[key];
      if (expected && typeof expected === 'object') {
        if ('$in' in expected) return expected.$in.includes(value);
        if ('$notNull' in expected) return value != null;
        if ('$ne' in expected) return value !== expected.$ne;
        return matches(uid, relation(uid, record, key) || {}, expected);
      }
      return value === expected;
    });
  }
  const entities = {
    tables, writes, table,
    async findMany(uid, options = {}) {
      let records = table(uid).filter((item) => matches(uid, item, options.filters)
        && (options.publicationState !== 'live' || item.publishedAt));
      if (options.sort) {
        const [key, direction] = Object.entries(options.sort)[0];
        records = [...records].sort((a, b) => (a[key] < b[key] ? -1 : a[key] > b[key] ? 1 : 0)
          * (direction === 'desc' ? -1 : 1));
      }
      if (options.limit !== undefined) records = records.slice(0, options.limit);
      return records.map((record) => {
        const populated = structuredClone(record);
        for (const [key, config] of Object.entries(options.populate || {})) {
          const related = relation(uid, record, key);
          populated[key] = structuredClone(Array.isArray(related)
            ? related.filter((item) => matches(uid, item, config.filters)) : related);
        }
        return populated;
      });
    },
    async create(uid, { data }) {
      const record = { id: table(uid).length + 1, ...structuredClone(data) };
      table(uid).push(record);
      writes.push({ uid, id: record.id, data: structuredClone(data) });
      return structuredClone(record);
    },
    async update(uid, id, { data }) {
      const record = table(uid).find((item) => item.id === id);
      if (!record) throw new Error(`Missing ${uid}/${id}`);
      Object.assign(record, structuredClone(data));
      writes.push({ uid, id, data: structuredClone(data) });
      return structuredClone(record);
    },
  };
  return entities;
}

module.exports = { memoryEntities };
