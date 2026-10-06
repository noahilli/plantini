import '@fontsource-variable/fraunces';
import '@fontsource-variable/inter';
import './style.css';

// Filter chips: show one part of Plantini or all. The page works without this.
const chips = [...document.querySelectorAll('.chip')];
const entries = [...document.querySelectorAll('.entry')];

function show(filter) {
  for (const entry of entries) entry.hidden = filter !== 'all' && entry.dataset.app !== filter;
  for (const chip of chips) chip.setAttribute('aria-pressed', String(chip.dataset.filter === filter));
}

for (const chip of chips) {
  chip.addEventListener('click', () => {
    show(chip.dataset.filter);
    history.replaceState(null, '', chip.dataset.filter === 'all' ? location.pathname : `#${chip.dataset.filter}`);
  });
}
const fromHash = location.hash.slice(1);
if (chips.some((chip) => chip.dataset.filter === fromHash)) show(fromHash);
