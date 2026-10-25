const fs = require('fs');
const darkD = fs.readFileSync('scratch/dark_refined.path', 'utf8').trim();
const terraD = fs.readFileSync('scratch/terra_refined.path', 'utf8').trim();
const starD = fs.readFileSync('scratch/star_refined.path', 'utf8').trim();

// Light stem version for dark backgrounds (Ivory stem + Terracotta ribbon + Terracotta star)
const lightSvg = `<!-- HeyMey Monogram Brand Mark (Light Stem for Dark Backdrops) -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 660 435" fill="none" width="100%" height="100%">
  <defs>
    <linearGradient id="hml-ribbon" x1="15%" y1="5%" x2="85%" y2="95%">
      <stop offset="0%" stop-color="#EAA08A" />
      <stop offset="40%" stop-color="#D8826A" />
      <stop offset="100%" stop-color="#BF684E" />
    </linearGradient>
    <linearGradient id="hml-star" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#F2AF9D" />
      <stop offset="100%" stop-color="#DA846C" />
    </linearGradient>
    <filter id="hml-glow" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="4" stdDeviation="10" flood-color="#e28f75" flood-opacity="0.25" />
    </filter>
  </defs>
  <g id="heymey-mark-light" filter="url(#hml-glow)">
    <path id="ribbon-arch" d="${terraD}" fill="url(#hml-ribbon)" />
    <path id="h-serif-stem" d="${darkD}" fill="#FFF8F4" />
    <path id="radiant-star" d="${starD}" fill="url(#hml-star)" />
  </g>
</svg>
`;

fs.writeFileSync('public/logo-mark-light.svg', lightSvg);
fs.writeFileSync('public/images/logo-mark-light.svg', lightSvg);
console.log('✓ Created public/logo-mark-light.svg');
