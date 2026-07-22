import fs from 'node:fs';

const configPath =
  process.env.FS25_WEB_CONFIG ||
  '/opt/fs25/game/Farming Simulator 2025/dedicatedServer.xml';
const portOnly = process.argv.includes('--port-only');
const port = process.env.WEB_PORT || '7999';

if (!/^\d{1,5}$/.test(port) || Number(port) < 1 || Number(port) > 65535) {
  throw new Error(`Invalid WEB_PORT: ${port}`);
}

if (!fs.existsSync(configPath)) {
  throw new Error(`GIANTS web configuration is missing: ${configPath}`);
}

const escapeXml = (value) =>
  value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');

let config = fs.readFileSync(configPath, 'utf8');

if (!/<webserver\s+port="\d+">/.test(config)) {
  throw new Error(`No webserver port was found in ${configPath}`);
}
config = config.replace(
  /<webserver\s+port="\d+">/,
  `<webserver port="${port}">`
);

if (!portOnly) {
  const replacements = [
    ['WEB_USERNAME', 'username'],
    ['WEB_PASSWORD', 'passphrase'],
  ];

  for (const [environmentName, elementName] of replacements) {
    const value = process.env[environmentName];
    if (!value) continue;

    const pattern = new RegExp(
      `(<${elementName}>)[\\s\\S]*?(</${elementName}>)`
    );
    if (!pattern.test(config)) {
      throw new Error(`No ${elementName} element was found in ${configPath}`);
    }
    config = config.replace(pattern, `$1${escapeXml(value)}$2`);
  }
}

fs.writeFileSync(configPath, config);
console.log(
  `INFO: GIANTS web configuration uses port ${port}${
    portOnly ? '.' : ' and the supplied web credentials.'
  }`
);
