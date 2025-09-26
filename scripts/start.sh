#!/bin/bash

# Script to manage DeepSeek Local
# Quick commands for daily use

set -e

# Load configurations
if [ -f .env ]; then
    source .env
else
    OLLAMA_PORT=11434
    WEBUI_PORT=3000
fi

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to show help
show_help() {
    echo -e "${BLUE}🤖 DeepSeek Local Manager${NC}"
    echo ""
    echo -e "${YELLOW}Usage: $0 [command]${NC}"
    echo ""
    echo -e "${GREEN}Available commands:${NC}"
    echo "  start       - Start services"
    echo "  stop        - Stop services"
    echo "  restart     - Restart services"
    echo "  status      - Show container status"
    echo "  logs        - Show real-time logs"
    echo "  models      - List installed models"
    echo "  install     - Install new models"
    echo "  test        - Test API with example"
    echo "  urls        - Show access URLs"
    echo "  cleanup     - Remove containers and volumes"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  $0 start                    # Start everything"
    echo "  $0 install deepseek-v3      # Install model"
    echo "  $0 test 'Hello in Python'   # Test with prompt"
    echo ""
}

# Function to check status
check_status() {
    echo -e "${BLUE}📊 Service status:${NC}"
    echo ""

    if docker-compose ps | grep -q "deepseek-ollama.*Up"; then
        echo -e "${GREEN}✅ Ollama: Running${NC}"
        if curl -s http://localhost:${OLLAMA_PORT}/api/tags > /dev/null; then
            echo -e "${GREEN}✅ API: Responding${NC}"
        else
            echo -e "${YELLOW}⚠️  API: Not responding${NC}"
        fi
    else
        echo -e "${RED}❌ Ollama: Stopped${NC}"
    fi

    if docker-compose ps | grep -q "deepseek-webui.*Up"; then
        echo -e "${GREEN}✅ Web Interface: Running${NC}"
    else
        echo -e "${YELLOW}⚠️  Web Interface: Stopped${NC}"
    fi

    echo ""
}

# Function to show URLs
show_urls() {
    echo -e "${BLUE}🌐 Access URLs:${NC}"
    echo ""
    echo -e "${GREEN}Ollama API:${NC}"
    echo "  http://localhost:${OLLAMA_PORT}"
    echo "  http://$(hostname -I | awk '{print $1}'):${OLLAMA_PORT}"
    echo ""
    echo -e "${GREEN}Web Interface:${NC}"
    echo "  http://localhost:${WEBUI_PORT}"
    echo "  http://$(hostname -I | awk '{print $1}'):${WEBUI_PORT}"
    echo ""
}

# Function to test API
test_api() {
    local prompt="${1:-Write a Hello World in Node.js}"

    echo -e "${BLUE}🧪 Testing API with prompt: ${YELLOW}\"$prompt\"${NC}"
    echo ""

    # Check if there are installed models
    local models=$(docker exec deepseek-ollama ollama list 2>/dev/null | tail -n +2)
    if [ -z "$models" ]; then
        echo -e "${RED}❌ No models installed. Run: $0 install${NC}"
        return 1
    fi

    # Get first model from list
    local first_model=$(echo "$models" | head -n 1 | awk '{print $1}')

    echo -e "${YELLOW}📡 Using model: $first_model${NC}"
    echo -e "${YELLOW}⏳ Generating response...${NC}"
    echo ""

    curl -s -X POST http://localhost:${OLLAMA_PORT}/api/generate \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$first_model\",
            \"prompt\": \"$prompt\",
            \"stream\": false
        }" | jq -r '.response' 2>/dev/null || {
        echo -e "${RED}❌ API error. Check logs: $0 logs${NC}"
        return 1
    }

    echo ""
    echo -e "${GREEN}✅ Test completed!${NC}"
}

# Main function
main() {
    case "${1:-help}" in
        "start")
            echo -e "${BLUE}🚀 Starting DeepSeek Local...${NC}"
            docker-compose up -d
            sleep 3
            check_status
            show_urls
            ;;

        "stop")
            echo -e "${YELLOW}⏸️  Stopping services...${NC}"
            docker-compose stop
            echo -e "${GREEN}✅ Services stopped${NC}"
            ;;

        "restart")
            echo -e "${YELLOW}🔄 Restarting services...${NC}"
            docker-compose restart
            sleep 3
            check_status
            ;;

        "status")
            check_status
            ;;

        "logs")
            echo -e "${BLUE}📋 Real-time logs (Ctrl+C to exit):${NC}"
            docker-compose logs -f
            ;;

        "models")
            echo -e "${BLUE}📦 Installed models:${NC}"
            echo ""
            docker exec deepseek-ollama ollama list
            ;;

        "install")
            shift
            if [ $# -eq 0 ]; then
                ./scripts/install-models.sh
            else
                ./scripts/install-models.sh "$@"
            fi
            ;;

        "test")
            shift
            test_api "$*"
            ;;

        "urls")
            show_urls
            ;;

        "cleanup")
            echo -e "${RED}🗑️  WARNING: This will remove ALL data!${NC}"
            read -p "Are you sure? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                docker-compose down -v
                docker volume prune -f
                echo -e "${GREEN}✅ Cleanup completed${NC}"
            else
                echo -e "${YELLOW}Operation cancelled${NC}"
            fi
            ;;

        "help"|*)
            show_help
            ;;
    esac
}

# Execute main function
main "$@"