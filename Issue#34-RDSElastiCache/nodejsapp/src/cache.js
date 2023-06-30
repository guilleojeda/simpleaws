const Redis = require('ioredis');

const redis = new Redis({
  host: process.env.CACHE_HOST,
  port: process.env.CACHE_PORT,
  db: process.env.CACHE_DB,
});

module.exports = redis;
