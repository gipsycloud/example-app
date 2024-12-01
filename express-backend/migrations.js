const fs = require("fs");
const path = require("path");
const { pool } = require("./db");

(async () => {
  try {
    const filePath = path.join(
      __dirname,
      "migrations/001_create_users_table.sql"
    );
    const sql = fs.readFileSync(filePath, "utf8");

    await pool.query(sql);

    console.log("Migration completed: users table created or already exists.");
  } catch (error) {
    console.error("Error running migration:", error.message);
    process.exit(1);
  } finally {
    pool.end();
  }
})();
