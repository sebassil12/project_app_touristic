-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Secure schema setup
REVOKE ALL ON SCHEMA public FROM PUBLIC;
CREATE SCHEMA IF NOT EXISTS gis_schema;
GRANT USAGE ON SCHEMA gis_schema TO uisrael_user;

CREATE TABLE IF NOT EXISTS gis_schema.users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    email VARCHAR(255) UNIQUE,
    role VARCHAR(50) DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE,
    last_login TIMESTAMP WITH TIME ZONE
);
-- Secure table for markers
CREATE TABLE IF NOT EXISTS gis_schema.markers (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    geom GEOMETRY(POINT, 4326) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by VARCHAR(100)
);

-- Secure permissions
GRANT CONNECT ON DATABASE gis_app TO uisrael_user;
GRANT USAGE ON SCHEMA gis_schema TO uisrael_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA gis_schema TO uisrael_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA gis_schema TO uisrael_user;

-- Create spatial index
CREATE INDEX idx_markers_geom ON gis_schema.markers USING GIST(geom);