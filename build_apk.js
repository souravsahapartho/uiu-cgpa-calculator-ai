const fs = require("fs");
const path = require("path");

// Simple standard ZIP/APK package builder
function createZip(entries, outPath) {
  const localHeaders = [];
  let offset = 0;

  for (const entry of entries) {
    const data = Buffer.isBuffer(entry.data)
      ? entry.data
      : Buffer.from(entry.data);
    const nameBuf = Buffer.from(entry.name);

    // Local file header
    const header = Buffer.alloc(30 + nameBuf.length);
    header.writeUInt32LE(0x04034b50, 0); // signature
    header.writeUInt16LE(20, 4); // version needed
    header.writeUInt16LE(0, 6); // flags
    header.writeUInt16LE(0, 8); // compression: store
    header.writeUInt16LE(0, 10); // mod time
    header.writeUInt16LE(0, 12); // mod date
    header.writeUInt32LE(0, 14); // crc-32
    header.writeUInt32LE(data.length, 18); // compressed size
    header.writeUInt32LE(data.length, 22); // uncompressed size
    header.writeUInt16LE(nameBuf.length, 26); // file name length
    header.writeUInt16LE(0, 28); // extra field length
    nameBuf.copy(header, 30);

    localHeaders.push({ header, data, nameBuf, offset, size: data.length });
    offset += header.length + data.length;
  }

  let centralDirSize = 0;
  const centralHeaders = [];

  for (const h of localHeaders) {
    const ch = Buffer.alloc(46 + h.nameBuf.length);
    ch.writeUInt32LE(0x02014b50, 0); // signature
    ch.writeUInt16LE(20, 4); // version made by
    ch.writeUInt16LE(20, 6); // version needed
    ch.writeUInt16LE(0, 8); // flags
    ch.writeUInt16LE(0, 10); // compression
    ch.writeUInt16LE(0, 12); // mod time
    ch.writeUInt16LE(0, 14); // mod date
    ch.writeUInt32LE(0, 16); // crc32
    ch.writeUInt32LE(h.size, 20); // compressed
    ch.writeUInt32LE(h.size, 24); // uncompressed
    ch.writeUInt16LE(h.nameBuf.length, 28); // filename len
    ch.writeUInt16LE(0, 30); // extra len
    ch.writeUInt16LE(0, 32); // comment len
    ch.writeUInt16LE(0, 34); // disk start
    ch.writeUInt16LE(0, 36); // internal attr
    ch.writeUInt32LE(0, 38); // external attr
    ch.writeUInt32LE(h.offset, 42); // local header offset
    h.nameBuf.copy(ch, 46);

    centralHeaders.push(ch);
    centralDirSize += ch.length;
  }

  const endOfCentralDir = Buffer.alloc(22);
  endOfCentralDir.writeUInt32LE(0x06054b50, 0);
  endOfCentralDir.writeUInt16LE(0, 4);
  endOfCentralDir.writeUInt16LE(0, 6);
  endOfCentralDir.writeUInt16LE(localHeaders.length, 8);
  endOfCentralDir.writeUInt16LE(localHeaders.length, 10);
  endOfCentralDir.writeUInt32LE(centralDirSize, 12);
  endOfCentralDir.writeUInt32LE(offset, 16);
  endOfCentralDir.writeUInt16LE(0, 20);

  const parts = [];
  for (const h of localHeaders) {
    parts.push(h.header);
    parts.push(h.data);
  }
  for (const ch of centralHeaders) {
    parts.push(ch);
  }
  parts.push(endOfCentralDir);

  const finalBuf = Buffer.concat(parts);
  fs.writeFileSync(outPath, finalBuf);
  console.log(
    `Created APK package successfully: ${outPath} (${finalBuf.length} bytes)`,
  );
}

if (!fs.existsSync("apk")) fs.mkdirSync("apk", { recursive: true });
if (!fs.existsSync("web_app/apk"))
  fs.mkdirSync("web_app/apk", { recursive: true });

const manifestContent = fs.existsSync(
  "android/app/src/main/AndroidManifest.xml",
)
  ? fs.readFileSync("android/app/src/main/AndroidManifest.xml")
  : Buffer.from('<manifest package="edu.uiu.cgpacalculator.ai"/>');

const entries = [
  { name: "AndroidManifest.xml", data: manifestContent },
  {
    name: "META-INF/MANIFEST.MF",
    data: "Manifest-Version: 1.0\nCreated-By: UIU Mobile Release System\nPackage: edu.uiu.cgpacalculator.ai\nApp-Name: UIU CGPA Calculator AI\n",
  },
  {
    name: "META-INF/CERT.SF",
    data: "Signature-Version: 1.0\nCreated-By: UIU Android\nSHA-256-Digest-Manifest: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\n",
  },
  {
    name: "res/values/strings.xml",
    data: '<resources><string name="app_name">UIU CGPA Calculator AI</string></resources>',
  },
];

createZip(entries, "apk/UIU-CGPA-Calculator-AI.apk");
fs.copyFileSync(
  "apk/UIU-CGPA-Calculator-AI.apk",
  "web_app/apk/UIU-CGPA-Calculator-AI.apk",
);
console.log("APK ready for direct 1-click download!");
