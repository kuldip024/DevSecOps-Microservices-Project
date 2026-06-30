const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3001;

// Security middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Mock database
let users = [
  { id: uuidv4(), name: 'Alice Johnson', email: 'alice@example.com', role: 'admin' },
  { id: uuidv4(), name: 'Bob Smith', email: 'bob@example.com', role: 'user' },
  { id: uuidv4(), name: 'Carol Davis', email: 'carol@example.com', role: 'user' },
];

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'User Service is healthy' });
});

// Get all users
app.get('/api/users', (req, res) => {
  console.log('[User Service] GET /api/users');
  res.json(users);
});

// Get user by ID
app.get('/api/users/:id', (req, res) => {
  const user = users.find(u => u.id === req.params.id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  console.log(`[User Service] GET /api/users/${req.params.id}`);
  res.json(user);
});

// Create new user
app.post('/api/users', (req, res) => {
  const { name, email, role } = req.body;
  
  if (!name || !email) {
    return res.status(400).json({ error: 'Name and email are required' });
  }

  const newUser = {
    id: uuidv4(),
    name,
    email,
    role: role || 'user'
  };

  users.push(newUser);
  console.log('[User Service] POST /api/users -', name);
  res.status(201).json(newUser);
});

// Update user
app.put('/api/users/:id', (req, res) => {
  const user = users.find(u => u.id === req.params.id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  Object.assign(user, req.body);
  console.log(`[User Service] PUT /api/users/${req.params.id}`);
  res.json(user);
});

// Delete user
app.delete('/api/users/:id', (req, res) => {
  const index = users.findIndex(u => u.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'User not found' });
  }

  const deletedUser = users.splice(index, 1);
  console.log(`[User Service] DELETE /api/users/${req.params.id}`);
  res.json(deletedUser[0]);
});

// Error handling
app.use((err, req, res, next) => {
  console.error('[User Service Error]', err);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, () => {
  console.log(` User Service running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});