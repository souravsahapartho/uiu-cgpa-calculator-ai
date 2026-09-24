const fs = require('fs');

const html = fs.readFileSync('web_app/index.html', 'utf8');
const workerContent = fs.readFileSync('worker.js', 'utf8');

const marker = 'function getHtmlContent()';
const index = workerContent.indexOf(marker);

if (index !== -1) {
  const head = workerContent.substring(0, index);
  const newContent = head + 'function getHtmlContent() {\n  return ' + JSON.stringify(html) + ';\n}\n';
  fs.writeFileSync('worker.js', newContent, 'utf8');
  console.log('worker.js updated successfully with pristine full SPA HTML!');
} else {
  console.error('Marker not found in worker.js');
}

