// Importa Pool (gestor de conexiones) de la librería de PostgreSQL.
const { Pool } = require("pg");

// Carga las variables del archivo .env para poder acceder a ellas mediante process.env.
require("dotenv").config();

// Crea Pool (conexiones reutilizables con PostgreSQL)
const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD
});

module.exports = pool;
