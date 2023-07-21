const express = require('express');
const cors = require('cors');
require('dotenv').config();
require('./setup.js');
const app = express();
app.use(cors());
const { S3Client, GetObjectCommand } = require("@aws-sdk/client-s3");
const bucketName = process.env.S3_BUCKET_NAME;
const fileName = process.env.FILE_NAME;
const region = process.env.AWS_REGION;

const s3Client = new S3Client({ region });

app.get('/', async (req, res) => {
  const params = {
    Bucket: bucketName,
    Key: fileName,
  };

  try {
    const s3Response = await s3Client.send(new GetObjectCommand(params));

    // Convert the readable stream to a string
    let fileContents = '';
    for await (const chunk of s3Response.Body) {
      fileContents += chunk.toString();
    }
    // Set no-cache headers
    res.set('Cache-Control', 'no-store, no-cache, must-revalidate, private');
    // Send response
    res.json({ message: fileContents });
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
