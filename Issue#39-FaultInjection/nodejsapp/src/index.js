const express = require('express');
const cors = require('cors');
require('dotenv').config();
const db = require('./db');
require('./setup.js');
const app = express();
app.use(cors());
const query = "SELECT * FROM simple_aws WHERE message='Thank you for being a subscriber!' LIMIT 1;";

app.get('/', async (req, res) => {
  try {
    const dbResponse = await db.query(query, []);
    console.log("Success")
    res.set('Cache-Control', 'no-store, no-cache, must-revalidate, private');
    res.json({ data: dbResponse });
  } catch (error) {
    console.error('Database connection error:', error);
    res.status(500).send('Internal Server Error');
  }
});

app.get('/health', async (req, res) => {
  res.set('Cache-Control', 'no-store, no-cache, must-revalidate, private');
  res.json({ });
});

// Set the port for the application
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});