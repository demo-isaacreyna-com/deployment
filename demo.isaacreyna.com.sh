#!/bin/bash

set -e

# Sets up demo.isaacreyna.com
function main() {
    create_env_file
    validate_env_file
    create_pgadmin_servers
    start_app
    run_migrations
}

function validate_env_file() {
    if [[ ! -f .env ]]; then
        echo "Error: .env does not exist!"
        exit 1
    else
        source .env

        if [[ -z "${COMPOSE_PROJECT_NAME}" ]]; then
            echo "Error: COMPOSE_PROJECT_NAME is not set"
            exit 1
        fi

        if [[ -z "${DATABASE_HOST}" ]]; then
            echo "Error: DATABASE_HOST is not set"
            exit 1
        fi

        if [[ -z "${DATABASE_USER}" ]]; then
            echo "Error: DATABASE_USER is not set"
            exit 1
        fi

        if [[ -z "${DATABASE_PASSWORD}" ]]; then
            echo "Error: DATABASE_PASSWORD is not set"
            exit 1
        fi

        if [[ -z "${DATABASE_DB}" ]]; then
            echo "Error: DATABASE_DB is not set"
            exit 1
        fi

        if [[ -z "${PGADMIN_DEFAULT_EMAIL}" ]]; then
            echo "Error: PGADMIN_DEFAULT_EMAIL is not set"
            exit 1
        fi

        if [[ -z "${PGADMIN_DEFAULT_PASSWORD}" ]]; then
            echo "Error: PGADMIN_DEFAULT_PASSWORD is not set"
            exit 1
        fi

        if [[ -z "${DATABASE_PORT}" ]]; then
            echo "Error: DATABASE_PORT is not set"
            exit 1
        fi
    fi
}

function create_env_file() {
    if [[ ! -f .env ]]; then
        cat << EOF > .env
COMPOSE_PROJECT_NAME=''
DATABASE_HOST=''
DATABASE_USER=''
DATABASE_PASSWORD=''
DATABASE_DB=''
DATABASE_PORT=''
PGADMIN_DEFAULT_EMAIL=''
PGADMIN_DEFAULT_PASSWORD=''
KEYCLOAK_DATABASE_NAME=''
KEYCLOAK_DATABASE_USER=''
KEYCLOAK_DATABASE_PASSWORD=''

EOF
        echo "NOTICE: .env created. Edit .env and set values"
        exit 1
    fi
}

function create_pgadmin_servers() {
    if [[ ! -f .env ]]; then
        echo "Error: .env file not found."
        exit 1
    fi

    source .env
    cat << EOF > servers.json
{
    "Servers": {
        "1": {
            "Name": "${COMPOSE_PROJECT_NAME}",
            "Group": "Servers",
            "Host": "${DATABASE_HOST}",
            "Port": ${DATABASE_PORT},
            "MaintenanceDB": "${DATABASE_DB}",
            "Username": "${DATABASE_USER}",
            "SSLMode": "prefer"
        }
    }
}
EOF
}

function start_app() {
    docker-compose down
    local result=$(docker rmi isaacdanielreyna/react-sandbox:0.1.0)
    docker-compose --profile all up -d
}

function run_migrations() {
     docker exec -d django python manage.py migrate 
}

main "$@"