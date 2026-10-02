const TYPES = ['string', 'number', 'boolean', 'object', 'array', 'null'];
const TYPE_NAMES = {
  string: 'Text', number: 'Zahl', boolean: 'Ja/Nein', object: 'Objekt', array: 'Liste', null: 'Leer',
};
const LABELS = {
  prompt: 'Frage', choices: 'Antwortmöglichkeiten', id: 'ID', label: 'Antworttext',
  correctChoiceId: 'Richtige Antwort-ID', minimumScore: 'Mindestpunktzahl',
  requiredQuizIds: 'Benötigte Quiz-IDs', requiredPlantIds: 'Benötigte Pflanzen-IDs',
  requiredLevelIds: 'Benötigte Level-IDs', collectionScope: 'Sammelbereich',
  heading: 'Überschrift', text: 'Steckbrief-Text', question: 'Frage',
  correctAnswer: 'Richtige Antwort', wrongAnswer1: 'Falsche Antwort 1',
  wrongAnswer2: 'Falsche Antwort 2', wrongAnswer3: 'Falsche Antwort 3',
};
const UNSAFE_KEYS = new Set(['__proto__', 'prototype', 'constructor']);

function element(tag, className, content) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (content !== undefined) node.textContent = content;
  return node;
}

function detectType(value) {
  if (value === null || value === undefined) return 'null';
  if (Array.isArray(value)) return 'array';
  if (typeof value === 'object') return 'object';
  return typeof value;
}

function initialValue(type) {
  return { string: '', number: 0, boolean: false, object: {}, array: [], null: null }[type];
}

function labelFor(key) {
  return LABELS[key] || String(key).replace(/([a-z])([A-Z])/g, '$1 $2');
}

function cloneJson(value) {
  return value === undefined ? null : JSON.parse(JSON.stringify(value));
}

function assertSafeKeys(value) {
  if (Array.isArray(value)) return value.forEach(assertSafeKeys);
  if (value && typeof value === 'object') {
    for (const [key, child] of Object.entries(value)) {
      if (UNSAFE_KEYS.has(key)) throw new Error(`Reservierter JSON-Feldname: ${key}`);
      assertSafeKeys(child);
    }
  }
}

export class JsonEditor {
  constructor(host, label, value, { readOnly = false } = {}) {
    this.host = host;
    this.label = label;
    this.value = cloneJson(value);
    this.readOnly = readOnly;
    this.mode = 'form';
    this.rawDraft = '';
    this.render();
  }

  getValue() {
    if (this.mode === 'form') {
      const result = cloneJson(this.value);
      assertSafeKeys(result);
      return result;
    }
    try {
      const parsed = JSON.parse(this.rawDraft);
      assertSafeKeys(parsed);
      this.setError('');
      return parsed;
    } catch (error) {
      this.setError(`Ungültiges JSON: ${error.message}`);
      throw new Error(`${this.label}: ungültiges JSON.`);
    }
  }

  setError(message) {
    if (!this.error) return;
    this.error.textContent = message;
    this.error.hidden = !message;
  }

  switchMode(mode) {
    if (mode === this.mode) return;
    if (mode === 'raw') {
      if ([...this.host.querySelectorAll('input[type="number"]')].some((input) => !input.checkValidity())) {
        this.setError('Bitte zuerst die ungültige Zahl korrigieren.');
        return;
      }
      this.rawDraft = JSON.stringify(this.value, null, 2);
    } else {
      try {
        this.value = JSON.parse(this.rawDraft);
        assertSafeKeys(this.value);
      } catch (error) {
        this.setError(`Ungültiges JSON: ${error.message}`);
        return;
      }
    }
    this.mode = mode;
    this.render();
  }

  get(path) {
    return path.reduce((node, part) => node[part], this.value);
  }

  set(path, value) {
    if (path.length === 0) this.value = value;
    else this.get(path.slice(0, -1))[path.at(-1)] = value;
  }

  remove(path) {
    const parent = this.get(path.slice(0, -1));
    const key = path.at(-1);
    if (Array.isArray(parent)) parent.splice(key, 1);
    else delete parent[key];
    this.render();
  }

  rename(path, key, input) {
    const previous = path.at(-1);
    const parentPath = path.slice(0, -1);
    const parent = this.get(parentPath);
    const next = key.trim();
    if (!next || UNSAFE_KEYS.has(next) || (next !== previous && Object.hasOwn(parent, next))) {
      input.value = previous;
      this.setError('Feldname ist leer, reserviert oder bereits vorhanden.');
      return;
    }
    this.setError('');
    if (next === previous) return;
    this.set(parentPath, Object.fromEntries(Object.entries(parent)
      .map(([name, value]) => [name === previous ? next : name, value])));
    this.render();
  }

  render() {
    this.host.replaceChildren();
    const toolbar = element('div', 'json-toolbar');
    const caption = element('span', 'json-caption', `${this.label} · ${TYPE_NAMES[detectType(this.value)]}`);
    const tabs = element('div', 'json-tabs');
    for (const [mode, text] of [['form', 'Formular'], ['raw', 'Raw JSON']]) {
      const tab = element('button', `json-tab${this.mode === mode ? ' active' : ''}`, text);
      tab.type = 'button'; tab.setAttribute('aria-pressed', String(this.mode === mode));
      tab.addEventListener('click', () => this.switchMode(mode));
      tabs.append(tab);
    }
    toolbar.append(caption, tabs);
    this.error = element('p', 'json-error');
    this.error.hidden = true;
    this.error.setAttribute('role', 'alert');
    this.host.append(toolbar, this.error);
    if (this.mode === 'raw') {
      const raw = element('textarea', 'json-raw');
      raw.value = this.rawDraft;
      raw.readOnly = this.readOnly;
      raw.spellcheck = false;
      raw.setAttribute('aria-label', `${this.label} als Raw JSON`);
      raw.addEventListener('input', () => { this.rawDraft = raw.value; this.setError(''); });
      this.host.append(raw);
      return;
    }
    this.host.append(this.node(this.value, [], this.label, true));
  }

  node(value, path, label, root = false) {
    const type = detectType(value);
    const wrapper = element('section', `json-node json-${type}${root ? ' json-root' : ''}`);
    const heading = element('div', 'json-node-head');
    if (!root && typeof path.at(-1) === 'string') {
      const friendly = labelFor(path.at(-1));
      if (friendly !== path.at(-1)) heading.append(element('span', 'json-key-title', friendly));
      const key = element('input', 'json-key');
      key.value = path.at(-1);
      key.setAttribute('aria-label', 'Feldname');
      key.disabled = this.readOnly;
      key.addEventListener('change', () => this.rename(path, key.value, key));
      heading.append(key);
    } else heading.append(element('strong', 'json-node-label', label));

    const select = element('select', 'json-type');
    select.setAttribute('aria-label', `Datentyp für ${label}`);
    select.disabled = this.readOnly;
    for (const optionType of TYPES) {
      const option = element('option', '', TYPE_NAMES[optionType]);
      option.value = optionType; option.selected = optionType === type;
      select.append(option);
    }
    select.addEventListener('change', () => {
      this.set(path, cloneJson(initialValue(select.value)));
      this.render();
    });
    heading.append(select);
    if (!root && !this.readOnly) {
      const remove = element('button', 'json-remove', 'Entfernen');
      remove.type = 'button'; remove.setAttribute('aria-label', `${label} entfernen`);
      remove.addEventListener('click', () => this.remove(path));
      heading.append(remove);
    }
    wrapper.append(heading);

    if (type === 'object' || type === 'array') {
      const entries = type === 'array' ? value.map((item, index) => [index, item]) : Object.entries(value);
      const children = element('div', 'json-children');
      for (const [key, child] of entries) children.append(this.node(child, [...path, key], type === 'array' ? `Eintrag ${key + 1}` : labelFor(key)));
      if (entries.length === 0) children.append(element('p', 'json-empty', 'Noch keine Einträge.'));
      wrapper.append(children);
      if (!this.readOnly) wrapper.append(this.addControls(path, type));
    } else if (type === 'string') {
      const multiline = value.length > 120 || ['text', 'description', 'prompt', 'warning'].includes(path.at(-1));
      const input = element(multiline ? 'textarea' : 'input', 'json-value');
      input.value = value;
      input.setAttribute('aria-label', label);
      input.disabled = this.readOnly;
      input.addEventListener('input', () => this.set(path, input.value));
      wrapper.append(input);
    } else if (type === 'number') {
      const input = element('input', 'json-value');
      input.type = 'number'; input.step = 'any'; input.required = true;
      input.value = String(value); input.disabled = this.readOnly;
      input.setAttribute('aria-label', label);
      input.addEventListener('input', () => {
        if (input.value !== '' && Number.isFinite(input.valueAsNumber)) this.set(path, input.valueAsNumber);
      });
      wrapper.append(input);
    } else if (type === 'boolean') {
      const input = element('input'); input.type = 'checkbox'; input.checked = value;
      input.disabled = this.readOnly; input.setAttribute('aria-label', label);
      input.addEventListener('change', () => this.set(path, input.checked));
      wrapper.append(input);
    } else wrapper.append(element('span', 'json-null', 'Kein Wert'));
    return wrapper;
  }

  addControls(path, type) {
    const row = element('div', 'json-add');
    const key = type === 'object' ? element('input') : null;
    if (key) { key.placeholder = 'Neuer Feldname'; key.setAttribute('aria-label', 'Neuer Feldname'); row.append(key); }
    const select = element('select');
    select.setAttribute('aria-label', 'Datentyp des neuen Eintrags');
    for (const optionType of TYPES) {
      const option = element('option', '', TYPE_NAMES[optionType]);
      option.value = optionType; select.append(option);
    }
    const add = element('button', 'secondary', type === 'object' ? '+ Feld' : '+ Eintrag');
    add.type = 'button';
    add.addEventListener('click', () => {
      const container = this.get(path);
      if (type === 'object') {
        const name = key.value.trim();
        if (!name || UNSAFE_KEYS.has(name) || Object.hasOwn(container, name)) {
          this.setError('Neuer Feldname ist leer, reserviert oder bereits vorhanden.');
          return;
        }
        container[name] = cloneJson(initialValue(select.value));
      } else container.push(cloneJson(initialValue(select.value)));
      this.render();
    });
    row.append(select, add);
    return row;
  }
}
