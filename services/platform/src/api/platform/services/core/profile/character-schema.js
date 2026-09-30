'use strict';

const { invalidRequest } = require('../errors');

/**
 * The player's avatar: a small record of part choices and colours that the app
 * assembles from its character kit (assets/characters/parts.json). Only known
 * styles and plain hex colours are accepted, so nothing but presentation data
 * can be stored here.
 */
const VERSION = 1;
const GENDERS = ['female', 'male', 'diverse'];
const STYLES = {
  hair: ['short', 'long', 'bun', 'ponytail', 'curly', 'buzz', 'none'],
  hat: ['cap', 'sunhat', 'beanie', 'ranger', 'none'],
  glasses: ['round', 'square', 'sunglasses', 'none'],
  top: ['tshirt', 'hoodie', 'jacket', 'sweater'],
  bottom: ['trousers', 'shorts', 'skirt'],
  shoes: ['sneakers', 'boots', 'rainboots'],
  backpack: ['rucksack', 'none'],
};
const COLOURED = ['hair', 'hat', 'glasses', 'top', 'bottom', 'shoes', 'backpack'];
const HEX = /^#[0-9a-fA-F]{6}$/;

function requireHex(value, field) {
  if (typeof value !== 'string' || !HEX.test(value)) {
    throw invalidRequest({ [field]: 'Muss eine Farbe wie #3f7fd0 sein.' });
  }
  return value.toLowerCase();
}

function validateCharacter(value) {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw invalidRequest({ character: 'Muss ein Objekt sein.' });
  }
  const allowed = new Set(['v', 'gender', 'skin', ...Object.keys(STYLES)]);
  for (const key of Object.keys(value)) {
    if (!allowed.has(key)) throw invalidRequest({ [`character.${key}`]: 'Unbekanntes Feld.' });
  }
  if (value.v !== VERSION) throw invalidRequest({ 'character.v': `Unterstützt wird nur Version ${VERSION}.` });
  if (!GENDERS.includes(value.gender)) {
    throw invalidRequest({ 'character.gender': `Erlaubt: ${GENDERS.join(', ')}.` });
  }
  const character = { v: VERSION, gender: value.gender, skin: requireHex(value.skin, 'character.skin') };
  for (const part of Object.keys(STYLES)) {
    const entry = value[part];
    if (entry === undefined || entry === null) {
      if (part === 'top' || part === 'bottom' || part === 'shoes') {
        throw invalidRequest({ [`character.${part}`]: 'Fehlt.' });
      }
      character[part] = { style: 'none' };
      continue;
    }
    if (typeof entry !== 'object' || Array.isArray(entry)) {
      throw invalidRequest({ [`character.${part}`]: 'Muss ein Objekt sein.' });
    }
    for (const key of Object.keys(entry)) {
      if (key !== 'style' && key !== 'color') {
        throw invalidRequest({ [`character.${part}.${key}`]: 'Unbekanntes Feld.' });
      }
    }
    if (!STYLES[part].includes(entry.style)) {
      throw invalidRequest({ [`character.${part}.style`]: `Erlaubt: ${STYLES[part].join(', ')}.` });
    }
    if (entry.style === 'none') {
      character[part] = { style: 'none' };
    } else {
      character[part] = { style: entry.style, color: requireHex(entry.color, `character.${part}.color`) };
    }
  }
  return character;
}

module.exports = { validateCharacter, STYLES, GENDERS, COLOURED, VERSION };
