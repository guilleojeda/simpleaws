const AWS = require('aws-sdk');
const bucketName = process.env.S3_BUCKET_NAME;
const fileName = process.env.FILE_NAME;

async function uploadToS3() {
  const content = "thanks for being a Simple AWS subscriber";
  const params = {
    Bucket: bucketName,
    Key: fileName,
    Body: content,
    ContentType: "text/plain"
  };
  const s3 = new AWS.S3();
  try {
    const data = await s3.upload(params).promise();
    console.log(`File uploaded successfully at ${data.Location}`);
  } catch (e) {
    console.error('Upload Error', e);
  }
}

uploadToS3()
