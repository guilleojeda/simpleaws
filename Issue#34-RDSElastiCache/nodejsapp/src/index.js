const express = require('express');
const cors = require('cors');
require('dotenv').config();
const dbNoCache = require('./db-no-cache');
const dbWithCache = require('./db-with-cache');
require('./setup.js');
const app = express();
app.use(cors());
const slowQuery = "SELECT * FROM simple_aws WHERE message='Thank you for being a subscriber!' LIMIT 1;";

app.get('/withcache', async (req, res) => {
  const start = Date.now();
  // Fetch the record from database
  const dbResponse = await dbWithCache.query(slowQuery, []);
  const end = Date.now();
  const elapsedTime = end - start;  
  // Set no-cache headers
  res.set('Cache-Control', 'no-store, no-cache, must-revalidate, private');
  // Send response
  res.json({ data: dbResponse, elapsedTime: elapsedTime });
});

app.get('/nocache', async (req, res) => {
  const start = Date.now();
  // Fetch the record from database
  const dbResponse = await dbNoCache.query(slowQuery, []);
  const end = Date.now();
  const elapsedTime = end - start;
  // Set no-cache headers
  res.set('Cache-Control', 'no-store, no-cache, must-revalidate, private');
  // Send response
  res.json({ data: dbResponse, elapsedTime: elapsedTime });
});

// Set the port for the application
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});
