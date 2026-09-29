// Plant "Karteikarten" as DOM. All text comes from src/content.json (the
// published editorial content) and is inserted with textContent only.

function el(tag, className, text) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
}

export function attribution(photo) {
  const line = el('p', 'credit');
  const link = el('a', '', `Foto: ${photo.author} · ${photo.licenseLabel}`);
  link.href = photo.source;
  link.target = '_blank';
  link.rel = 'noopener noreferrer';
  line.append(link);
  return line;
}

function photoBlock(plant) {
  const figure = el('figure', 'pc-photo');
  const photo = plant.photos[0];
  if (!photo) {
    const empty = el('div', 'pc-photo-empty');
    empty.append(el('span', '', 'Foto folgt'));
    figure.append(empty);
    return figure;
  }
  const image = new Image();
  image.src = `/photos/${photo.file}`;
  image.alt = photo.alt;
  image.loading = 'lazy';
  image.decoding = 'async';
  figure.append(image, attribution(photo));
  return figure;
}

export function renderCard(plant, ecosystem, { compact = false } = {}) {
  const card = el('article', `plant-card${compact ? ' plant-card-compact' : ''} tint-${ecosystem.key}`);
  card.append(el('header', 'pc-tab', 'PLANTINI / FELDNOTIZEN'));
  const body = el('div', 'pc-body');
  const text = el('div', 'pc-text');
  text.append(
    el('p', 'pc-eyebrow', 'PFLANZENPORTRÄT'),
    el('h3', 'pc-name', plant.commonName),
    el('p', 'pc-latin', plant.scientificName),
    el('p', 'pc-family', plant.family),
    el('p', 'pc-label', 'AUF EINEN BLICK'),
    el('p', 'pc-desc', plant.description),
  );
  const notes = compact ? plant.notes.slice(0, 1) : plant.notes;
  if (notes.length) {
    text.append(el('p', 'pc-label', 'GENAU HINSEHEN'));
    const list = el('ol', 'pc-notes');
    notes.forEach((note, index) => {
      const item = el('li');
      item.append(el('span', 'pc-note-num', String(index + 1).padStart(2, '0')));
      const copy = el('div');
      copy.append(el('strong', '', note.heading), el('span', '', note.text));
      item.append(copy);
      list.append(item);
    });
    text.append(list);
  }
  if (plant.warning && !compact) text.append(el('p', 'pc-warning', `Sicherheit: ${plant.warning}`));
  body.append(photoBlock(plant), text);
  card.append(body);
  return card;
}

export function renderMosaic(container, ecosystems) {
  // First photo of every plant, then the second photos; 12 in total.
  const plants = ecosystems.flatMap((ecosystem) => ecosystem.plants);
  const ordered = [
    ...plants.filter((plant) => plant.photos[0]).map((plant) => ({ plant, photo: plant.photos[0] })),
    ...plants.filter((plant) => plant.photos[1]).map((plant) => ({ plant, photo: plant.photos[1] })),
  ].slice(0, 12);
  container.replaceChildren();
  for (const { photo, plant } of ordered) {
    const figure = el('figure', 'mosaic-item');
    const image = new Image();
    image.src = `/photos/${photo.file}`;
    image.alt = photo.alt;
    image.loading = 'lazy';
    image.decoding = 'async';
    const caption = el('figcaption');
    caption.append(el('strong', '', plant.commonName), attribution(photo));
    figure.append(image, caption);
    container.append(figure);
  }
}

export function renderCredits(container, ecosystems) {
  const list = el('ul', 'credits');
  for (const ecosystem of ecosystems) {
    for (const plant of ecosystem.plants) {
      for (const photo of plant.photos) {
        const item = el('li');
        item.append(el('strong', '', `${plant.commonName} (${plant.scientificName})`), document.createTextNode(' – '));
        const link = el('a', '', `${photo.author}, ${photo.licenseLabel}`);
        link.href = photo.source;
        link.target = '_blank';
        link.rel = 'noopener noreferrer';
        item.append(link, document.createTextNode(' · Bild verkleinert und ggf. beschnitten dargestellt'));
        list.append(item);
      }
    }
  }
  container.replaceChildren(list);
}
