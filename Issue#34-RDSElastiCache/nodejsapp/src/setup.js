const db = require('./db.js');

// Function to create the table if it does not exist
async function createTable() {
  try {
    const createTableQuery = `
      CREATE TABLE IF NOT EXISTS simple_aws (
        ID SERIAL PRIMARY KEY,
        message TEXT NOT NULL
      );
    `;

    await db.query(createTableQuery);
    console.log("Table created successfully or already exists.");
  } catch (err) {
    console.error('Error creating table:', err);
  }
}

// Function to insert initial data
async function insertInitialData() {
  try {
    const initialDataCheck = await db.query('SELECT COUNT(*) FROM simple_aws');
    if (initialDataCheck.rows[0].count === '0') {
      // The table is empty. Insert initial data.
      const initialDataQuery = `
        INSERT INTO simple_aws (message)
        VALUES ('Thank you for being a subscriber!');
      `;

      await db.query(initialDataQuery);
      console.log("Initial data inserted successfully.");
    } else {
      console.log("Initial data already present, skipping insertion.");
    }
  } catch (err) {
    console.error('Error inserting initial data:', err);
  }
}

// Call the functions
createTable().then(insertInitialData);
