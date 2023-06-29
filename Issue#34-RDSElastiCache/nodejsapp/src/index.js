const express = require('express');
const cors = require('cors');
const dbNoCache = require('./db-no-cache');
const dbWithCache = require('./db-with-cache');
require('./setup.js');
require('dotenv').config();
const app = express();
app.use(cors());
const slowQuery = 'WITH RECURSIVE slow_query AS (SELECT 1 AS val UNION ALL SELECT val+1 FROM slow_query WHERE val < 5000000) SELECT * FROM simple_aws LIMIT 1;';

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

app.get('/reset', async (req, res) => {
  try {
    await db.flushCache();
    console.log('All data flushed from Redis');
  } catch (err) {
    console.error('Error flushing data from Redis:', err);
  }
});

// Set the port for the application
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});
