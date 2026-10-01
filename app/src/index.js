const express = require('express');
const { pool, initDb } = require('./db');

const app = express();
app.use(express.json());

// Middleware de validação
const validarReserva = (req, res, next) => {
  const { cliente, data, status } = req.body;
  const statusPermitidos = ['pendente', 'confirmada', 'cancelada'];

  if (!cliente || !data || !status) {
    return res.status(400).json({ erro: 'Campos obrigatórios: cliente, data e status não informados.' });
  }

  // Valida se a data tem um formato correto
  const dataObj = new Date(data);
  if (isNaN(dataObj.getTime())) {
    return res.status(400).json({ erro: 'Data inválida.' });
  }

  if (!statusPermitidos.includes(status)) {
    return res.status(400).json({ erro: 'Status inválido. Valores aceitos: pendente, confirmada ou cancelada.' });
  }
  next();
};

// Middleware para validar se o ID é um número válido
const validarId = (req, res, next) => {
  const id = parseInt(req.params.id, 10);
  if (isNaN(id)) {
    return res.status(400).json({ erro: 'ID inválido.' });
  }
  next();
};

// R1: POST /reservas
app.post('/reservas', validarReserva, async (req, res) => {
  const { cliente, data, status } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO reservas (cliente, data, status) VALUES ($1, $2, $3) RETURNING *',
      [cliente, data, status]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ erro: 'Erro interno ao criar reserva.' });
  }
});

// R2: GET /reservas
app.get('/reservas', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM reservas ORDER BY id ASC');
    res.status(200).json(result.rows);
  } catch (err) {
    res.status(500).json({ erro: 'Erro interno ao listar reservas.' });
  }
});

// R3: GET /reservas/:id
app.get('/reservas/:id', validarId, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM reservas WHERE id = $1', [req.params.id]);
    if (result.rowCount === 0) return res.status(404).json({ erro: 'Reserva não encontrada.' });
    res.status(200).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ erro: 'Erro interno ao buscar reserva.' });
  }
});

// R4: PUT /reservas/:id
app.put('/reservas/:id', validarId, validarReserva, async (req, res) => {
  const { cliente, data, status } = req.body;
  try {
    const result = await pool.query(
      'UPDATE reservas SET cliente = $1, data = $2, status = $3 WHERE id = $4 RETURNING *',
      [cliente, data, status, req.params.id]
    );
    if (result.rowCount === 0) return res.status(404).json({ erro: 'Reserva não encontrada.' });
    res.status(200).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ erro: 'Erro interno ao atualizar reserva.' });
  }
});

// R5: DELETE /reservas/:id
app.delete('/reservas/:id', validarId, async (req, res) => {
  try {
    const result = await pool.query('DELETE FROM reservas WHERE id = $1', [req.params.id]);
    if (result.rowCount === 0) return res.status(404).json({ erro: 'Reserva não encontrada.' });
    res.status(204).send();
  } catch (err) {
    res.status(500).json({ erro: 'Erro interno ao deletar reserva.' });
  }
});

// R6: GET /health
app.get('/health', (req, res) => {
  res.status(200).send('UP');
});

const PORT = 3000;


initDb().then(() => {
  app.listen(PORT, () => {
    console.log(`API rodando na porta ${PORT}`);
  });
});