const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const bucketName = process.env.S3_BUCKET_NAME;
const fileName = process.env.FILE_NAME;
const region = process.env.AWS_REGION;
const localFilePath = './' + fileName;

const s3Client = new S3Client({ region });
const { createWriteStream } = require('fs');
const { pipeline } = require('stream/promises');

async function uploadToS3() {
  const content = "to do: write a review for Simple AWS";
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

const downloadFile = async () => {
  const downloadParams = {
    Bucket: bucketName,
    Key: fileName,
  };
  try {
    const { Body } = await s3Client.send(new GetObjectCommand(downloadParams));
    await pipeline(
      Body,
      createWriteStream(localFilePath)
    );
    console.log('Downloaded the file.');
  } catch (error) {
    console.error(`Error: ${error}`);
  }
};

uploadToS3();
downloadFile();
