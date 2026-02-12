const fs = require('fs');
const path = require('path');

function getAllFiles(dirPath, arrayOfFiles) {
    const files = fs.readdirSync(dirPath);

    arrayOfFiles = arrayOfFiles || [];

    files.forEach(file => {
        if (fs.statSync(dirPath + "/" + file).isDirectory()) {
            arrayOfFiles = getAllFiles(dirPath + "/" + file, arrayOfFiles);
        } else {
            if (file.endsWith('.ejs')) {
                arrayOfFiles.push(path.join(dirPath, "/", file));
            }
        }
    });

    return arrayOfFiles;
}

const viewsDir = 'C:/WEB/dentali/src/views';
const files = getAllFiles(viewsDir);

files.forEach(file => {
    const content = fs.readFileSync(file, 'utf8');
    if (content.trim().startsWith('<%- include')) {
        // Check for other EJS tags
        // We expect ONLY the first <%- include ... %> and maybe the closing %>
        // If the file pattern is <%- include(..., { body: `...` }) %>
        // Then inside the body string there should be NO EJS tags.

        // Find the first %>
        const firstClose = content.indexOf('%>');
        // If there are tags BEFORE the first close, it means nested tags (bad) or multiple tags (maybe ok if logic).

        // But if the pattern is wrapping the WHOLE file in one tag...
        // Then there should be only ONE open tag at start and ONE close tag at end.

        const openTags = (content.match(/<%[-=]?/g) || []).length;
        const closeTags = (content.match(/%>/g) || []).length;

        if (openTags > 1) {
            console.log(`File ${file} has ${openTags} open tags. It might be broken if it uses the body-wrap pattern.`);
        }
    }
});
