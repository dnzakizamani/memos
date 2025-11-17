#!/bin/bash

# Memos Deployment Script
# Usage: ./deploy.sh [install|start|stop|restart|update]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    export $(cat "$ENV_FILE" | xargs)
else
    echo "Environment file $ENV_FILE not found!"
    echo "Please copy .env.example to .env and update the values"
    exit 1
fi

# Function to install prerequisites
install() {
    echo "Installing prerequisites..."
    
    # Install Docker if not present
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
    fi
    
    # Install Docker Compose if not present
    if ! command -v docker-compose &> /dev/null; then
        echo "Installing Docker Compose..."
        DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
        mkdir -p $DOCKER_CONFIG/cli-plugins
        curl -SL https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m) -o $DOCKER_CONFIG/cli-plugins/docker-compose
        chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
    fi
    
    echo "Prerequisites installed."
}

# Function to start Memos
start() {
    echo "Starting Memos..."
    docker-compose -f docker-compose.prod.yml up -d
    echo "Memos started. Check status with: docker-compose -f docker-compose.prod.yml ps"
}

# Function to stop Memos
stop() {
    echo "Stopping Memos..."
    docker-compose -f docker-compose.prod.yml down
    echo "Memos stopped."
}

# Function to restart Memos
restart() {
    echo "Restarting Memos..."
    stop
    sleep 5
    start
}

# Function to update Memos to latest version
update() {
    echo "Updating Memos..."
    docker-compose -f docker-compose.prod.yml down
    docker pull neosmemo/memos:stable
    docker-compose -f docker-compose.prod.yml up -d
    echo "Memos updated."
}

# Function to show status
status() {
    echo "Checking Memos status..."
    docker-compose -f docker-compose.prod.yml ps
    echo "Checking logs..."
    docker-compose -f docker-compose.prod.yml logs --tail=50
}

# Main script logic
case "$1" in
    "install")
        install
        ;;
    "start")
        start
        ;;
    "stop")
        stop
        ;;
    "restart")
        restart
        ;;
    "update")
        update
        ;;
    "status")
        status
        ;;
    *)
        echo "Usage: $0 {install|start|stop|restart|update|status}"
        echo "  install  - Install Docker and Docker Compose if not present"
        echo "  start    - Start Memos service"
        echo "  stop     - Stop Memos service"
        echo "  restart  - Restart Memos service"
        echo "  update   - Update to latest Memos version"
        echo "  status   - Show service status and recent logs"
        exit 1
        ;;
esac