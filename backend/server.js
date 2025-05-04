require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const cors = require('cors');
const { body, validationResult } = require('express-validator');
const bodyParser = require('body-parser');
const app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.NODE_ENV === 'development' 
    ? 'http://localhost:8080' 
    : 'https://flutter-app-domain.com'
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Database connection with SSL for production
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: 5432,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// JWT middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.sendStatus(401);

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', db: 'connected' });
  } catch (err) {
    res.status(500).json({ status: 'error', db: err.message });
  }
});

// User registration
app.post('/register', 
    [
      body('username')
        .trim()
        .isString()
        .withMessage('Username must be a string')
        .isLength({ min: 3 })
        .withMessage('Username must be at least 3 characters'),
      body('password')
        .isString()
        .withMessage('Password must be a string')
        .isLength({ min: 8 })
        .withMessage('Password must be at least 8 characters')
    ],
    async (req, res) => {
      // Log the incoming request body for debugging
      console.log('Request body:', req.body);
      
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        console.log('Validation errors:', errors.array());
        return res.status(400).json({ errors: errors.array() });
      }
  
      const { username, password } = req.body;
      console.log('Extracted values:', { username, password });
  
      try {
        const hashedPassword = await bcrypt.hash(password, 10);
        console.log('Password hashed successfully');
  
        const result = await pool.query(
          'INSERT INTO gis_schema.users (username, password) VALUES ($1, $2) RETURNING id, username',
          [username, hashedPassword]
        );
        
        console.log('User created:', result.rows[0]);
        res.status(201).json({ 
          success: true,
          user: result.rows[0] 
        });
      } catch (err) {
        console.error('Database error:', err);
        
        // Handle duplicate username error
        if (err.code === '23505') { // PostgreSQL unique violation
          return res.status(400).json({ 
            error: 'Username already exists' 
          });
        }
        
        res.status(500).json({ 
          error: 'Internal server error',
          details: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
      }
    }
  );

// User login
app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  
  try {
    const result = await pool.query(
      'SELECT * FROM gis_schema.users WHERE username = $1',
      [username]
    );
    
    if (result.rows.length === 0) {
      return res.status(401).send('Invalid credentials');
    }

    const user = result.rows[0];
    const validPassword = await bcrypt.compare(password, user.password);
    
    if (!validPassword) {
      return res.status(401).send('Invalid credentials');
    }

    const token = jwt.sign(
      { userId: user.id, username: user.username },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );
    
    res.json({ token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Protected marker endpoints
app.get('/api/markers', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, title, description, 
       ST_X(geom) as lng, ST_Y(geom) as lat 
       FROM gis_schema.markers`
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/markers', authenticateToken, 
  [
    body('title').isString().notEmpty(),
    body('description').isString(),
    body('lat').isFloat({ min: -90, max: 90 }),
    body('lng').isFloat({ min: -180, max: 180 })
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { title, description, lat, lng } = req.body;
    const userId = req.user.userId;

    try {
      const result = await pool.query(
        `INSERT INTO gis_schema.markers 
         (title, description, geom, created_by) 
         VALUES ($1, $2, ST_SetSRID(ST_MakePoint($3, $4), 4326), $5)
         RETURNING id, title, description, 
         ST_X(geom) as lng, ST_Y(geom) as lat`,
        [title, description, lng, lat, userId]
      );
      res.status(201).json(result.rows[0]);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

const PORT = process.env.API_PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV}`);
  console.log(`Database host: ${process.env.DB_HOST}`);
});