// Landing page for the app's login return (https://plantini.eu/app/login).
// Android opens the app directly through the verified App Link; where that does
// not happen (a browser that does not hand off, a not yet verified install) this
// page forwards code and state to the app's own URL scheme and shows a button,
// because browsers only allow that hop after a tap.
import './style.css';

const query = window.location.search;
const params = new URLSearchParams(query);
const target = `eu.plantini.app://oauth2redirect${query}`;
const button = document.querySelector('#open');
button.href = target;

if (params.has('error')) {
  document.querySelector('#title').textContent = 'Anmeldung abgebrochen';
  document.querySelector('#text').textContent = 'Zurück in der App kannst du es noch einmal versuchen.';
  button.textContent = 'Zurück zu Plantini';
} else if (!params.has('code')) {
  document.querySelector('#title').textContent = 'Plantini';
  document.querySelector('#text').textContent = 'Diese Seite leitet nach der Anmeldung zurück in die App.';
  button.hidden = true;
} else {
  // Works where the browser allows it; otherwise the button above does.
  window.setTimeout(() => { window.location.href = target; }, 150);
}
