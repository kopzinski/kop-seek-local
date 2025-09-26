#!/bin/bash

# DeepSeek Local Client
# A standalone script to communicate with your local DeepSeek server

set -e

# Default configuration
DEEPSEEK_HOST="${DEEPSEEK_HOST:-localhost}"
DEEPSEEK_PORT="${DEEPSEEK_PORT:-11434}"
API_URL="http://${DEEPSEEK_HOST}:${DEEPSEEK_PORT}/api"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
print_banner() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}🤖 DeepSeek Local Client${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

# Check if server is running
check_connection() {
    if curl -s "${API_URL}/tags" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Get available models
get_models() {
    curl -s "${API_URL}/tags" | jq -r '.models[]?.name' 2>/dev/null || echo ""
}

# Get first available model
get_first_model() {
    get_models | head -n 1
}

# List models
list_models() {
    echo -e "\n${BLUE}📦 Available models:${NC}"
    local models=$(get_models)
    if [ -z "$models" ]; then
        echo -e "${RED}❌ No models available${NC}"
        return 1
    fi

    local i=1
    while IFS= read -r model; do
        if [ -n "$model" ]; then
            echo -e "  ${GREEN}$i.${NC} $model"
            ((i++))
        fi
    done <<< "$models"
}

# Send prompt to model
send_prompt() {
    local prompt="$1"
    local model="$2"
    local stream="${3:-false}"

    if [ -z "$model" ]; then
        model=$(get_first_model)
        if [ -z "$model" ]; then
            echo -e "${RED}❌ No models available${NC}"
            return 1
        fi
    fi

    local payload=$(jq -n \
        --arg model "$model" \
        --arg prompt "$prompt" \
        --argjson stream $stream \
        '{model: $model, prompt: $prompt, stream: $stream}')

    if [ "$stream" = "true" ]; then
        echo -e "\n${CYAN}🤖 $model:${NC}"
        curl -s -X POST "${API_URL}/generate" \
            -H "Content-Type: application/json" \
            -d "$payload" | \
        while IFS= read -r line; do
            if [ -n "$line" ]; then
                echo "$line" | jq -r '.response // empty' 2>/dev/null | tr -d '\n'
            fi
        done
        echo ""
    else
        echo -e "\n${CYAN}🤖 $model:${NC}"
        echo -e "${YELLOW}⏳ Generating response...${NC}"
        local response=$(curl -s -X POST "${API_URL}/generate" \
            -H "Content-Type: application/json" \
            -d "$payload" | jq -r '.response' 2>/dev/null)

        if [ -n "$response" ] && [ "$response" != "null" ]; then
            echo "$response"
        else
            echo -e "${RED}❌ Failed to get response${NC}"
            return 1
        fi
    fi
}

# Interactive mode
interactive_mode() {
    echo -e "\n${BLUE}🔄 Interactive mode${NC}"
    echo -e "${YELLOW}Commands: 'models', 'help', 'quit'${NC}"
    echo -e "${CYAN}----------------------------------------${NC}"

    local current_model=$(get_first_model)
    if [ -n "$current_model" ]; then
        echo -e "Using model: ${GREEN}$current_model${NC}"
    fi

    while true; do
        echo -ne "\n${BLUE}>${NC} "
        read -r user_input

        case "${user_input,,}" in
            "quit"|"exit"|"q")
                echo -e "${GREEN}👋 Goodbye!${NC}"
                break
                ;;
            "models")
                list_models
                ;;
            "help")
                show_help
                ;;
            "")
                continue
                ;;
            *)
                if [ -z "$current_model" ]; then
                    echo -e "${RED}❌ No model available${NC}"
                    continue
                fi
                send_prompt "$user_input" "$current_model" true
                ;;
        esac
    done
}

# Show help
show_help() {
    echo -e "\n${YELLOW}Commands:${NC}"
    echo -e "  ${GREEN}models${NC}  - List available models"
    echo -e "  ${GREEN}help${NC}    - Show this help"
    echo -e "  ${GREEN}quit${NC}    - Exit the client"
    echo -e "\n${YELLOW}Usage examples:${NC}"
    echo -e "  ${CYAN}$0${NC}                           # Interactive mode"
    echo -e "  ${CYAN}$0${NC} 'Write hello world in Python'  # Single prompt"
    echo -e "  ${CYAN}$0${NC} --models                   # List models"
    echo -e "  ${CYAN}$0${NC} --help                     # Show full help"
}

# Main function
main() {
    print_banner

    # Check connection
    if ! check_connection; then
        echo -e "${RED}❌ Cannot connect to server at ${DEEPSEEK_HOST}:${DEEPSEEK_PORT}${NC}"
        echo -e "${YELLOW}Make sure the DeepSeek Local server is running:${NC}"
        echo -e "  ${CYAN}./scripts/start.sh start${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Connected to ${DEEPSEEK_HOST}:${DEEPSEEK_PORT}${NC}"

    # Parse arguments
    case "$1" in
        "--help"|"-h")
            show_help
            exit 0
            ;;
        "--models"|"-m")
            list_models
            exit 0
            ;;
        "--interactive"|"-i")
            list_models
            interactive_mode
            exit 0
            ;;
        "")
            list_models
            interactive_mode
            exit 0
            ;;
        *)
            # Single prompt mode
            echo -e "\n${BLUE}📝 Prompt:${NC} $*"
            echo -e "${CYAN}----------------------------------------${NC}"
            send_prompt "$*" "" false
            exit 0
            ;;
    esac
}

# Check dependencies
check_deps() {
    for cmd in curl jq; do
        if ! command -v $cmd >/dev/null 2>&1; then
            echo -e "${RED}❌ Required command not found: $cmd${NC}"
            echo -e "${YELLOW}Please install: $cmd${NC}"
            exit 1
        fi
    done
}

# Run dependency check and main
check_deps
main "$@"