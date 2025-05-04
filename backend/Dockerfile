FROM node:18-alpine

WORKDIR /usr/src/app

# Install dependencies for node-gyp and Postgres client
RUN apk add --no-cache python3 make g++ postgresql-client

# First copy only package files for better layer caching
COPY package*.json ./

# Install production dependencies only
RUN npm install --omit=dev

# Copy the rest of the application
COPY . .

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if(r.statusCode !== 200) throw new Error()})"

EXPOSE 3000

CMD ["node", "server.js"]