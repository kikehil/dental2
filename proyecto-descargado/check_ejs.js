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
    let openTags = 0;

    // Simple check: split by <%- and see if each part (except first) contains %>
    // This is naive because %> might be part of a string but inside EJS tags strings should be handled.
    // But EJS doesn't parse strings inside tags fully until execution.

    // A better check:
    // Find index of <%-
    // Find index of %> after that.

    let regex = /<%-/g;
    let match;
    while ((match = regex.exec(content)) !== null) {
        const startIndex = match.index;
        const rest = content.substring(startIndex + 3);
        const closeIndex = rest.indexOf('%>');
        if (closeIndex === -1) {
            console.log(`Error in file: ${file}`);
            console.log(`Unclosed <%- tag at index ${startIndex}`);
            // Show context
            console.log('Context:', content.substring(startIndex, startIndex + 50) + '...');
        }
    }
});
