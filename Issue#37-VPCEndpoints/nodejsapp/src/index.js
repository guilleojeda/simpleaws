const express = require('express');
const cors = require('cors');
const AWS = require('aws-sdk');
require('dotenv').config();
require('./setup.js');
const app = express();
app.use(cors());
const bucketName = process.env.S3_BUCKET_NAME;
const fileName = process.env.FILE_NAME;

app.get('/', async (req, res) => {
  const s3 = new AWS.S3();
  const start = Date.now();
  // Fetch the file from S3
  const params = {
    Bucket: bucketName,
    Key: fileName,
  };
  try {
    const s3Response = await s3.getObject(params).promise();
    const end = Date.now();
    const elapsedTime = end - start;  
    // Set no-cache headers
    res.set('Cache-Control', 'no-store, no-cache, must-revalidate, private');
    // Send response
    res.json({ elapsedTime: elapsedTime });
  } catch (e) {
    console.log('Error: ', e);
    res.status(500).json({ error: 'An error occurred while fetching file from S3' });
  }
});

// Set the port for the application
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});
