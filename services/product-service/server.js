const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3002;

// Security middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Mock database
let products = [
  { id: uuidv4(), name: 'Laptop', price: 999.99, category: 'Electronics', stock: 10 },
  { id: uuidv4(), name: 'Mouse', price: 29.99, category: 'Accessories', stock: 50 },
  { id: uuidv4(), name: 'Keyboard', price: 79.99, category: 'Accessories', stock: 30 },
  { id: uuidv4(), name: 'Monitor', price: 299.99, category: 'Electronics', stock: 15 },
];

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'Product Service is healthy' });
});

// Get all products
app.get('/api/products', (req, res) => {
  console.log('[Product Service] GET /api/products');
  res.json(products);
});

// Get product by ID
app.get('/api/products/:id', (req, res) => {
  const product = products.find(p => p.id === req.params.id);
  if (!product) {
    return res.status(404).json({ error: 'Product not found' });
  }
  console.log(`[Product Service] GET /api/products/${req.params.id}`);
  res.json(product);
});

// Get products by category
app.get('/api/products/category/:category', (req, res) => {
  const categoryProducts = products.filter(p => 
    p.category.toLowerCase() === req.params.category.toLowerCase()
  );
  console.log(`[Product Service] GET /api/products/category/${req.params.category}`);
  res.json(categoryProducts);
});

// Create new product
app.post('/api/products', (req, res) => {
  const { name, price, category, stock } = req.body;
  
  if (!name || !price || !category) {
    return res.status(400).json({ error: 'Name, price, and category are required' });
  }

  const newProduct = {
    id: uuidv4(),
    name,
    price,
    category,
    stock: stock || 0
  };

  products.push(newProduct);
  console.log('[Product Service] POST /api/products -', name);
  res.status(201).json(newProduct);
});

// Update product
app.put('/api/products/:id', (req, res) => {
  const product = products.find(p => p.id === req.params.id);
  if (!product) {
    return res.status(404).json({ error: 'Product not found' });
  }

  Object.assign(product, req.body);
  console.log(`[Product Service] PUT /api/products/${req.params.id}`);
  res.json(product);
});

// Delete product
app.delete('/api/products/:id', (req, res) => {
  const index = products.findIndex(p => p.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Product not found' });
  }

  const deletedProduct = products.splice(index, 1);
  console.log(`[Product Service] DELETE /api/products/${req.params.id}`);
  res.json(deletedProduct[0]);
});

// Error handling
app.use((err, req, res, next) => {
  console.error('[Product Service Error]', err);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, () => {
  console.log(` Product Service running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});