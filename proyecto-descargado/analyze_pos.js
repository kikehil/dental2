const fs = require('fs');
const file = 'C:/WEB/dentali/src/views/vault/index.ejs';
const content = fs.readFileSync(file, 'utf8');

let regex = /<%[-=]?|%>/g;
let match;
while ((match = regex.exec(content)) !== null) {
    console.log(`Found ${match[0]} at index ${match.index} (line ${content.substring(0, match.index).split('\n').length})`);
}
