const { Pool } = require("pg");

const pool = new Pool({
  user: process.env.DB_USERNAME,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: 5432,
  ssl: false,
});

async function ping() {
  try {
    await pool.query("SELECT 1");
  } catch (error) {
    throw new Error("Database connection failed: " + error.message);
  }
}

module.exports = { pool, ping };
