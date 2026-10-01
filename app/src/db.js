const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

const initDb = async (retries = 5) => {
  const query = `
    CREATE TABLE IF NOT EXISTS reservas (
      id SERIAL PRIMARY KEY,
      cliente VARCHAR(255) NOT NULL,
      data DATE NOT NULL,
      status VARCHAR(20) NOT NULL CHECK (status IN ('pendente', 'confirmada', 'cancelada'))
    );
  `;
  
  while (retries > 0) {
    try {
      await pool.query(query);
      console.log('Banco de dados conectado e tabela verificada.');
      return; // Sai do loop e continua a aplicação
    } catch (err) {
      console.error(`Erro ao conectar no banco. Tentativas restantes: ${retries - 1}`);
      retries -= 1;
      await new Promise(res => setTimeout(res, 5000)); // Espera 5 segundos
    }
  }
  console.error('Falha fatal: Não foi possível conectar ao banco de dados.');
  process.exit(1); // Derruba a aplicação se o banco não responder
};

module.exports = { pool, initDb };