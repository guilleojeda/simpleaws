const express = require('express');
const cors = require('cors');
require('dotenv').config();
require('./setup.js');
const app = express();
app.use(cors());
const fs = require('fs');
const fileName = process.env.FILE_NAME;
const localFilePath = './' + fileName;

app.get('/', async (req, res) => {
  try {
    const fileContents = fs.readFileSync(localFilePath, 'utf-8');
    console.log(fileContents);
  res.set('Cache-Control', 'no-store, no-cache, must-revalidate, private');
  res.json({ message: fileContents });
} catch (e) {
  console.log('Error: ', e);
  res.status(500).json({ error: 'An error occurred while reading the file' });
}
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});
