#!/usr/bin/env bash

set -e

# Sets up demo.isaacreyna.com
function main() {
    validate_env_file
    create_pgadmin_servers
    start_app
    run_migrations
}

function validate_env_file() {
    local fileENV='.env'
    if [[ -f "${fileENV}" ]]; then
        source "${fileENV}"
    fi

    # This array keeps the order
    local ENV_VARS_ORDER=(
        COMPOSE_PROJECT_NAME
        DATABASE_HOST
        DATABASE_USER
        DATABASE_PASSWORD
        DATABASE_DB
        DATABASE_PORT
        PGADMIN_DEFAULT_EMAIL
        PGADMIN_DEFAULT_PASSWORD
        KEYCLOAK_DATABASE_NAME
        KEYCLOAK_DATABASE_USER
        KEYCLOAK_DATABASE_PASSWORD
        KEYCLOAK_ADMIN
        KEYCLOAK_ADMIN_PASSWORD
    )

    # This associative array holds the value
    declare -A ENV_VARS

    # Use parameter expansion to set associative array values
    for key in "${ENV_VARS_ORDER[@]}"; do
        ENV_VARS[$key]=${!key}
    done

    # Creat the env file
    if [[ ! -f "${fileENV}" ]]; then
        echo "Error: ${fileENV} does not exist! Creating ${fileENV}"
        create_env_file "${fileENV}"
    fi

    # Validate the env file
    local hasError=false
    for key in "${ENV_VARS_ORDER[@]}"; do
        if [[ -z "${ENV_VARS[$key]}" ]]; then
            echo "Error: ${key} is not set"
            hasError=true
        fi
    done

    if [[ "${hasError}" == true ]]; then
        exit 1
    fi
}

function create_env_file() {
    local fileENV=$1
    if [[ ! -f "${fileENV}" ]]; then
        local first=true
        for key in "${ENV_VARS_ORDER[@]}"; do
            if [[ "${first}" == true ]]; then
                first=false
                echo "${key}=''" > "${fileENV}"
            else
                echo "${key}=''" >> "${fileENV}"
            fi
        done
        echo "NOTICE: .env created. Edit .env and set values"
        exit 0
    fi
}

function create_pgadmin_servers() {
    local fileENV='.env'
    if [[ ! -f "${fileENV}" ]]; then
        echo "Error: ${fileENV} file not found."
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