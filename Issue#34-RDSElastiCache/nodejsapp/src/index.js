const express = require('express');
const cors = require('cors');
const db = require('./db-no-cache');
//const db = require('./db-with-cache');
require('dotenv').config();

const app = express();

// Enable CORS
app.use(cors());

app.get('/test', async (req, res) => {
  const start = Date.now();
  
  // Fetch the record from database
  const dbResponse = await db.query('SELECT * FROM simple_aws LIMIT 1', []);
  
  const end = Date.now();

  const elapsedTime = end - start;
  
  // Set no-cache headers
  res.set('Cache-Control', 'no-store, no-cache, must-revalidate, private');

  // Send response
  res.json({ data: dbResponse, elapsedTime: elapsedTime });
});

// Set the port for your application
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});
