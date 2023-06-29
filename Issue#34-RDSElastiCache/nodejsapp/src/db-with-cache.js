const { Pool } = require('pg');
const redis = require('./cache');

const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT
});

module.exports = {
  query: async (text, params) => {
    const key = JSON.stringify({ text, params });
    const cacheResult = await redis.get(key);

    if (cacheResult) {
      return JSON.parse(cacheResult);
    } else {
      const dbResult = await pool.query(text, params);
      await redis.set(key, JSON.stringify(dbResult.rows));
      return dbResult.rows;
    }
  }
};
