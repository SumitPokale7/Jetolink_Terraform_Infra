#!/usr/bin/env bash
set -eux

echo "Decrypting secrets..."

DB_USER="$(sops -d secrets.json | jq -r '.username')"
DB_PASS="$(sops -d secrets.json | jq -r '.password')"

export PGPASSWORD="${DEFAULT_DB_PASS}"

echo "Testing DB connection for user ${DEFAULT_DB_USER}..."
psql -h "${DB_HOST}" -U "${DEFAULT_DB_USER}" -d postgres -c "\l"

echo "Creating DB jetolink_maindb_${TF_WORKSPACE} if not exists..."
psql -h "${DB_HOST}" -U "${DEFAULT_DB_USER}" -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'jetolink_maindb_${TF_WORKSPACE}'" | grep -q 1 || \
psql -h "${DB_HOST}" -U "${DEFAULT_DB_USER}" -d postgres -c "CREATE DATABASE jetolink_maindb_${TF_WORKSPACE};"

echo "Creating DB jetolink_chatdb_${TF_WORKSPACE} if not exists..."
psql -h "${DB_HOST}" -U "${DEFAULT_DB_USER}" -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'jetolink_chatdb_${TF_WORKSPACE}'" | grep -q 1 || \
psql -h "${DB_HOST}" -U "${DEFAULT_DB_USER}" -d postgres -c "CREATE DATABASE jetolink_chatdb_${TF_WORKSPACE};"

echo "Creating DB user if needed..."
psql -h "${DB_HOST}" -U "${DEFAULT_DB_USER}" -d postgres -tc "SELECT 1 FROM pg_catalog.pg_user WHERE usename = '${DB_USER}'" | grep -q 1 || \
psql -h "${DB_HOST}" -U "${DEFAULT_DB_USER}" -d postgres -c "CREATE USER \"${DB_USER}\" WITH PASSWORD '${DB_PASS}';"

echo "Granting privileges to user..."
psql -h "${DB_HOST}" -U "${DEFAULT_DB_USER}" -d "jetolink_maindb_${TF_WORKSPACE}" -c "GRANT ALL PRIVILEGES ON DATABASE jetolink_maindb_${TF_WORKSPACE} TO \"${DB_USER}\";"
psql -h "${DB_HOST}" -U "${DEFAULT_DB_USER}" -d "jetolink_chatdb_${TF_WORKSPACE}" -c "GRANT ALL PRIVILEGES ON DATABASE jetolink_chatdb_${TF_WORKSPACE} TO \"${DB_USER}\";"

echo "Creating schema jetolink_schema in both databases and granting permissions..."

# Create schema and set privileges in jetolink_maindb
psql -h "${DB_HOST}" -U "${DEFAULT_DB_USER}" -d "jetolink_maindb_${TF_WORKSPACE}" <<EOF
CREATE SCHEMA IF NOT EXISTS jetolink_schema AUTHORIZATION "${DB_USER}";
GRANT ALL PRIVILEGES ON SCHEMA jetolink_schema TO "${DB_USER}";
ALTER DEFAULT PRIVILEGES IN SCHEMA jetolink_schema GRANT ALL PRIVILEGES ON TABLES TO "${DB_USER}";
GRANT USAGE ON SCHEMA jetolink_schema TO "${DB_USER}";
EOF

# Repeat for jetolink_chatdb
psql -h "${DB_HOST}" -U "${DEFAULT_DB_USER}" -d "jetolink_chatdb_${TF_WORKSPACE}" <<EOF
CREATE SCHEMA IF NOT EXISTS jetolink_schema AUTHORIZATION "${DB_USER}";
GRANT ALL PRIVILEGES ON SCHEMA jetolink_schema TO "${DB_USER}";
ALTER DEFAULT PRIVILEGES IN SCHEMA jetolink_schema GRANT ALL PRIVILEGES ON TABLES TO "${DB_USER}";
GRANT USAGE ON SCHEMA jetolink_schema TO "${DB_USER}";
EOF

echo "Bootstrap complete."
