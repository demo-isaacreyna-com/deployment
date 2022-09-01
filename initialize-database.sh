#!/usr/bin/env bash
# psql postgresql://postgres@:5432/postgres -c 'select 1;'

psql "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@/${POSTGRES_DB}?sslmode=disable" <<-EOSQL
SELECT 'CREATE DATABASE demo'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'demo')\gexec

SELECT 'CREATE DATABASE keycloak'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'keycloak')\gexec
EOSQL
