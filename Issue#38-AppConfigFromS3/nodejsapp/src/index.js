const express = require('express');
const cors = require('cors');
require('dotenv').config();
require('./setup.js');
const app = express();
app.use(cors());
const fs = require('fs');
const { AppConfigClient, GetConfigurationCommand } = require('@aws-sdk/client-appconfig');

const appConfigClient = new AppConfigClient({ region: process.env.AWS_REGION });

const application = process.env.APPCONFIG_APPLICATION;
const environment = process.env.APPCONFIG_ENVIRONMENT;
const configuration = process.env.APPCONFIG_CONFIGURATION;
const clientId = process.env.APPCONFIG_CLIENTID;

const fileNameFallback = process.env.FILE_NAME;
const localFilePath = './' + fileNameFallback;

async function fetchAppConfig() {
  const params = {
    Application: application,
    Environment: environment,
    Configuration: configuration,
    ClientId: clientId,
  };

  try {
    const data = await appConfigClient.send(new GetConfigurationCommand(params));
    return data.Content.toString();
  } catch (error) {
    console.error(`Failed to fetch AppConfig: ${error}`);
    return null;
  }
}

app.get('/', async (req, res) => {
  let message = await fetchAppConfig();
  if (!message) {
    try {
      message = fs.readFileSync(localFilePath, 'utf-8');
    } catch (e) {
      console.log('Error: ', e);
      res.status(500).json({ error: 'An error occurred while reading the file' });
      return;
    }
  }
  res.set('Cache-Control', 'no-store, no-cache, must-revalidate, private');
  res.json({ message: message });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});
