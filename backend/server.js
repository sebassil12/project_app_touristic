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
const allowedOrigins = [
  'http://localhost:*',       // All localhost ports
  'http://192.168.18.155:*',  // Your local network IP
  'https://your-production-domain.com' // Production domain
];

app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, curl, etc)
    if (!origin) return callback(null, true);
    
    // Check if the origin is in allowedOrigins
    if (allowedOrigins.some(allowed => origin.match(new RegExp(allowed.replace('*', '.*'))))) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  credentials: true,
  preflightContinue: false,
  optionsSuccessStatus: 204
}));

// Explicitly handle OPTIONS requests
app.options('*', cors());

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
        .isLength({ min: 6 }) // Changed from 8 to match Flutter
        .withMessage('Password must be at least 6 characters'),
      body('email')
        .isEmail()
        .withMessage('Must be a valid email')
        .normalizeEmail()
    ],
    async (req, res) => {
      console.log('Full request body:', req.body);
      
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ 
          success: false,
          message: 'Validation failed',
          errors: errors.array() 
        });
      }
  
      const { username, password, email } = req.body;

      try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const result = await pool.query(
          'INSERT INTO gis_schema.users (username, password, email) VALUES ($1, $2, $3) RETURNING id, username, email',
          [username, hashedPassword, email]
        );
        
        res.status(201).json({ 
          success: true,
          user: result.rows[0],
          message: 'Registration successful'
        });
      } catch (err) {
        if (err.code === '23505') {
          const detail = err.detail.includes('email') 
            ? 'Email already exists' 
            : 'Username already exists';
          
          return res.status(400).json({
            success: false,
            message: detail
          });
        }
        
        res.status(500).json({ 
          success: false,
          message: 'Internal server error',
          error: process.env.NODE_ENV === 'development' ? err.message : undefined
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
// Obtener usuario actual
app.get('/users/me', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, username, email FROM gis_schema.users WHERE id = $1',
      [req.user.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Actualizar usuario actual
app.put('/users/me', authenticateToken, 
  [
    body('username').optional().isLength({ min: 3 }),
    body('email').optional().isEmail(),
    body('newPassword').optional().isLength({ min: 6 })
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { username, email, newPassword } = req.body;

    try {
      let query = 'UPDATE gis_schema.users SET';
      const values = [];
      let paramCount = 1;

      if (username) {
        query += ` username = $${paramCount++},`;
        values.push(username);
      }
      if (email) {
        query += ` email = $${paramCount++},`;
        values.push(email);
      }
      if (newPassword) {
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        query += ` password = $${paramCount++},`;
        values.push(hashedPassword);
      }

      query = query.slice(0, -1) + ` WHERE id = $${paramCount} RETURNING id, username, email`;
      values.push(req.user.userId);

      const result = await pool.query(query, values);
      
      res.json({ 
        success: true,
        user: result.rows[0]
      });
    } catch (err) {
      if (err.code === '23505') {
        return res.status(400).json({ error: 'Username or email already exists' });
      }
      res.status(500).json({ error: err.message });
    }
  }
);

// Eliminar usuario actual
app.delete('/users/me', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM gis_schema.users WHERE id = $1', [req.user.userId]);
    res.status(204).send();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
app.put('/users/:id', authenticateToken, 
  [
    body('username').optional().isLength({ min: 3 }),
    body('email').optional().isEmail(),
    body('newPassword').optional().isLength({ min: 6 })
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { id } = req.params;
    const { username, email, newPassword } = req.body;

    try {
      let query = 'UPDATE gis_schema.users SET';
      const values = [];
      let paramCount = 1;

      if (username) {
        query += ` username = $${paramCount++},`;
        values.push(username);
      }
      if (email) {
        query += ` email = $${paramCount++},`;
        values.push(email);
      }
      if (newPassword) {
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        query += ` password = $${paramCount++},`;
        values.push(hashedPassword);
      }

      query = query.slice(0, -1) + ` WHERE id = $${paramCount} RETURNING id, username, email`;
      values.push(id);

      const result = await pool.query(query, values);
      
      res.json({ 
        success: true,
        user: result.rows[0]
      });
    } catch (err) {
      if (err.code === '23505') {
        return res.status(400).json({ error: 'Username or email already exists' });
      }
      res.status(500).json({ error: err.message });
    }
  }
);

// Eliminar usuario
app.delete('/users/:id', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM gis_schema.users WHERE id = $1', [req.params.id]);
    res.status(204).send();
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
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV}`);
  console.log(`Database host: ${process.env.DB_HOST}`);
});