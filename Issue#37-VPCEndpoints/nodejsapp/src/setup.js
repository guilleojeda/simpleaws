const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const bucketName = process.env.S3_BUCKET_NAME;
const fileName = process.env.FILE_NAME;
const region = process.env.AWS_REGION;

const s3Client = new S3Client({ region });

async function uploadToS3() {
  const content = "thanks for being a Simple AWS subscriber";
  const params = {
    Bucket: bucketName,
    Key: fileName,
    Body: content,
    ContentType: "text/plain"
  };

  try {
    const data = await s3Client.send(new PutObjectCommand(params));
    console.log(`File uploaded successfully. ${data}`);
  } catch (e) {
    console.error('Upload Error', e);
  }
}

uploadToS3()
