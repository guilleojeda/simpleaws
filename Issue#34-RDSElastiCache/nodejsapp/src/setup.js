const db = require('./db-no-cache.js');

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
      // Insert initial data.
      const initialDataQuery1 = `
        INSERT INTO simple_aws (message)
        VALUES ('Thank you for being a subscriber!');
      `;

      await db.query(initialDataQuery1);

      let insertQuery = 'INSERT INTO simple_aws (message) VALUES ';
      const params = [];
        let paramIndex = 1;
        for (let i = 0; i < 1000000; i++) {
          insertQuery += `($${paramIndex}),`;
          params.push('not this one');
          paramIndex++;
        }
        // Remove the trailing comma and add a semicolon to end the query
        insertQuery = insertQuery.slice(0, -1) + ';';
        await db.query(insertQuery, params);
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
