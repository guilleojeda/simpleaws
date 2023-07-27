const { S3Client, PutObjectCommand, GetObjectCommand } = require("@aws-sdk/client-s3");
const { createWriteStream, createReadStream } = require('fs');
const fse = require('fs-extra');
const { pipeline, Transform } = require('stream/promises');
const archiver = require('archiver');

const bucketName = process.env.S3_BUCKET_NAME;
const fileName = process.env.FILE_NAME;
const region = process.env.AWS_REGION;
const localFilePath = './' + fileName;
const zipFileName = fileName + '.zip';
const zipFilePath = './' + zipFileName;

const s3Client = new S3Client({ region });

async function createZipAndUploadToS3() {
  // Write the content to a local file
  const content = "to do: write a review for Simple AWS";
  await fse.writeFile(localFilePath, content);

  // Zip the file
  const output = createWriteStream(zipFilePath);
  const archive = archiver('zip', { zlib: { level: 9 } }); // Sets the compression level.
  archive.pipe(output);
  archive.file(localFilePath, { name: fileName });

  await new Promise((resolve, reject) => {
    archive.on('error', reject); // Rejects on error
    output.on('close', resolve); // Resolves when the stream has been closed (and file is written).
    output.on('error', reject); // Rejects on error
    archive.finalize(); // Finalize the archiving process
  }).catch(error => {
    throw new Error(`Error occurred: ${error.message}`);
  });

  // Upload the zipped file to S3
  const params = {
    Bucket: bucketName,
    Key: fileName + '.zip',
    Body: createReadStream(zipFilePath),
    ContentType: "application/zip"
  };

  try {
    const data = await s3Client.send(new PutObjectCommand(params));
    console.log(`File uploaded successfully. ${data}`);
  } catch (e) {
    console.error('Upload Error', e);
  }
}

// Ensure the upload completes before starting the download
createZipAndUploadToS3()
  .then(() => console.log('Upload completed'))
  .catch(e => console.error('Error occurred:', e));
