'use strict';

const { invalidRequest } = require('../errors');
const { validateCharacter } = require('./character-schema');
const { optionalString, rejectUnknownFields, requirePlainObject } = require('../validation');

class ProfileService {
  constructor(options) {
    this.actorService = options.actorService;
  }

  async getMe(actor) {
    return mapProfile(actor);
  }

  async updateMe(actor, body) {
    const patch = validateProfilePatch(body);
    const updated = await this.actorService.updateProfile(actor, patch);
    return mapProfile(updated);
  }
}

function validateProfilePatch(body) {
  const value = requirePlainObject(body);
  rejectUnknownFields(value, ['displayName', 'locale', 'character']);
  const displayName = optionalString(value.displayName, 'displayName', { min: 1, max: 100 });
  const locale = optionalString(value.locale, 'locale', { min: 2, max: 35 });
  if (locale && !/^[a-z]{2,3}(?:-[A-Z]{2})?$/.test(locale)) {
    throw invalidRequest({ locale: 'Muss ein BCP-47-Sprachcode wie de-DE sein.' });
  }
  const character = value.character === undefined ? undefined : validateCharacter(value.character);
  if (!displayName && !locale && !character) {
    throw invalidRequest({ body: 'Mindestens displayName, locale oder character muss gesetzt sein.' });
  }
  return {
    ...(displayName ? { displayName } : {}),
    ...(locale ? { locale } : {}),
    ...(character ? { character } : {}),
  };
}

function mapProfile(actor) {
  return {
    id: actor.id,
    displayName: actor.displayName,
    locale: actor.locale,
    roles: actor.roles,
    ...(actor.character ? { character: actor.character } : {}),
    ...(actor.organisationId ? { organisationId: actor.organisationId } : {}),
  };
}

module.exports = {
  ProfileService,
  validateProfilePatch,
  mapProfile,
};
