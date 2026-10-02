'use strict';

const { createHash } = require('crypto');
const { ProblemError } = require('../errors');

const PACKAGE_IDS = ['ecosystems', 'levels', 'plants'];

function buildReleasePackages(version, collections) {
  if (typeof version !== 'string' || !/^[a-zA-Z0-9._-]{1,80}$/.test(version)) {
    throw new Error('Invalid content release version.');
  }
  const blobs = {};
  const descriptors = PACKAGE_IDS.map((id) => {
    const items = collections[id];
    if (!Array.isArray(items) || items.length === 0) {
      throw new Error(`Content release ${version} needs non-empty ${id}.`);
    }
    const bytes = Buffer.from(JSON.stringify({ items }), 'utf8');
    const sha256 = createHash('sha256').update(bytes).digest('hex');
    // Base64 is intentional: Strapi's JSONB storage may reorder object keys,
    // but package bytes must stay identical to the signed manifest checksum.
    blobs[id] = bytes.toString('base64');
    return {
      id,
      url: `/api/v1/content/packages/${encodeURIComponent(version)}/${id}`,
      sha256,
      bytes: bytes.length,
    };
  });
  return { descriptors, blobs };
}

function readReleasePackage(release, packageId) {
  if (!release || !PACKAGE_IDS.includes(packageId)) {
    throw new ProblemError('CONTENT_PACKAGE_NOT_FOUND', { status: 404 });
  }
  const descriptor = release.manifest?.packages?.find((item) => item.id === packageId);
  const encoded = release.packageBlobs?.[packageId];
  if (!descriptor || typeof encoded !== 'string' || !/^[A-Za-z0-9+/]*={0,2}$/.test(encoded)) {
    throw integrityError('Content package is missing.');
  }
  const bytes = Buffer.from(encoded, 'base64');
  const sha256 = createHash('sha256').update(bytes).digest('hex');
  if (bytes.length !== descriptor.bytes || sha256 !== descriptor.sha256) {
    throw integrityError('Content package checksum or size does not match the release manifest.');
  }
  return { bytes, sha256 };
}

function integrityError(detail) {
  return new ProblemError('CONTENT_INTEGRITY_FAILED', { status: 503, detail });
}

module.exports = { PACKAGE_IDS, buildReleasePackages, readReleasePackage };
