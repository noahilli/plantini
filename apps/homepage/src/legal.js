import '@fontsource-variable/fraunces';
import '@fontsource-variable/inter';
import './style.css';
import content from './content.json';
import { renderCredits } from './cards.js';

const credits = document.querySelector('#credits');
if (credits) renderCredits(credits, content.ecosystems);
