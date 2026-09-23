const http = require("http");
const fs = require("fs");
const path = require("path");
const os = require("os");

const PORT = 3000;
const HOST = "0.0.0.0";

const mimeTypes = {
  ".html": "text/html",
  ".js": "text/javascript",
  ".css": "text/css",
  ".json": "application/json",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".svg": "image/svg+xml",
};

const server = http.createServer((req, res) => {
  let filePath = path.join(
    __dirname,
    "web_app",
    req.url === "/" ? "index.html" : req.url,
  );

  // Security fallback to index.html if file doesn't exist
  if (!fs.existsSync(filePath)) {
    filePath = path.join(__dirname, "web_app", "index.html");
  }

  const extname = String(path.extname(filePath)).toLowerCase();
  const contentType = mimeTypes[extname] || "application/octet-stream";

  fs.readFile(filePath, (error, content) => {
    if (error) {
      res.writeHead(500);
      res.end("Error loading application: " + error.code);
    } else {
      res.writeHead(200, {
        "Content-Type": contentType,
        "Access-Control-Allow-Origin": "*",
      });
      res.end(content, "utf-8");
    }
  });
});

server.listen(PORT, HOST, () => {
  console.log(`\n======================================================`);
  console.log(`🚀 UIU CGPA Calculator AI is LIVE & Accessible!`);
  console.log(`📱 Phone (Same Wi-Fi Network): http://192.168.0.105:${PORT}`);
  console.log(`💻 Local Computer:            http://localhost:${PORT}`);
  console.log(`======================================================\n`);
});
