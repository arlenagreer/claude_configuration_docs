const sharp = require('sharp');

async function createGradient(filename, color1, color2) {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="562.5">
    <defs>
      <linearGradient id="g" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style="stop-color:#${color1}"/>
        <stop offset="100%" style="stop-color:#${color2}"/>
      </linearGradient>
    </defs>
    <rect width="100%" height="100%" fill="url(#g)"/>
  </svg>`;

  await sharp(Buffer.from(svg))
    .png()
    .toFile(filename);
}

async function createAccentBar(filename, color, width, height) {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}">
    <rect width="100%" height="100%" fill="#${color}"/>
  </svg>`;

  await sharp(Buffer.from(svg))
    .png()
    .toFile(filename);
}

async function main() {
  // Main gradient background
  await createGradient('gradient-bg.png', '181B24', '2D3748');

  // Content slide background
  await createGradient('gradient-content.png', '1A202C', '2D3748');

  // Accent bars
  await createAccentBar('accent-emerald.png', '40695B', 200, 10);
  await createAccentBar('accent-purple.png', 'B165FB', 200, 10);

  console.log('Gradients created successfully');
}

main().catch(console.error);
