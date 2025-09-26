#!/bin/bash

# Script to install DeepSeek/Ollama models
# Shows visual progress during download

set -e

# Load configurations
if [ -f .env ]; then
    source .env
else
    OLLAMA_PORT=11434
    DEFAULT_MODELS="deepseek-v3,qwen2.5-coder:7b"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show spinner during operations
show_spinner() {
    local -r pid="${1}"
    local -r delay='0.1'
    local spinstr='\|/-'
    local temp
    
    while ps a | awk '{print $1}' | grep -q "${pid}"; do
        temp="${spinstr#?}"
        printf " [%c]  " "${spinstr}"
        spinstr=${temp}${spinstr%"${temp}"}
        sleep "${delay}"
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to check if model is already installed
model_exists() {
    local model=$1
    docker exec deepseek-ollama ollama list | grep -q "^$model"
}

# Function to install a model
install_model() {
    local model=$1

    echo -e "${BLUE}📥 Installing model: ${YELLOW}$model${NC}"

    if model_exists "$model"; then
        echo -e "${GREEN}✅ Model $model is already installed${NC}"
        return 0
    fi

    echo -e "${YELLOW}⏳ Download in progress... (may take several minutes)${NC}"
    echo -e "${YELLOW}💡 Tip: Open another terminal to monitor: docker-compose logs -f ollama${NC}"

    # Install model in background and show progress
    (docker exec deepseek-ollama ollama pull "$model") &
    local pull_pid=$!

    # Show spinner while installing
    show_spinner $pull_pid

    # Wait for process to finish
    wait $pull_pid

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Model $model installed successfully!${NC}"

        # Show model size
        echo -e "${BLUE}📊 Checking size...${NC}"
        docker exec deepseek-ollama ollama list | grep "$model"
    else
        echo -e "${RED}❌ Error installing model $model${NC}"
        return 1
    fi
}

# Function to list available models
list_available_models() {
    echo -e "${BLUE}📋 Recommended models for development:${NC}"
    echo ""
    echo -e "${GREEN}Small (4-8GB):${NC}"
    echo "  • deepseek-coder:6.7b    - Code specialist"
    echo "  • qwen2.5-coder:7b       - Great for Node/Ruby"
    echo "  • codellama:7b           - Meta Code Llama"
    echo ""
    echo -e "${YELLOW}Medium (15-25GB):${NC}"
    echo "  • deepseek-v3            - Best overall quality"
    echo "  • qwen2.5-coder:32b      - Advanced specialist"
    echo ""
    echo -e "${RED}Large (30GB+):${NC}"
    echo "  • llama3.3:70b           - Maximum quality"
    echo ""
}

# Main function
main() {
    echo -e "${BLUE}🤖 DeepSeek Model Installer${NC}"
    echo ""

    # Check if Ollama is running
    if ! curl -s http://localhost:${OLLAMA_PORT}/api/tags > /dev/null; then
        echo -e "${RED}❌ Ollama is not running. Run 'docker-compose up -d' first.${NC}"
        exit 1
    fi

    # If no argument was passed, use DEFAULT_MODELS
    if [ $# -eq 0 ]; then
        if [ ! -z "$DEFAULT_MODELS" ]; then
            echo -e "${YELLOW}📦 Installing default models: $DEFAULT_MODELS${NC}"
            IFS=',' read -ra MODELS <<< "$DEFAULT_MODELS"
            for model in "${MODELS[@]}"; do
                model=$(echo "$model" | xargs) # Remove spaces
                install_model "$model"
                echo ""
            done
        else
            echo -e "${YELLOW}🤔 No model specified.${NC}"
            list_available_models
            exit 0
        fi
    else
        # Install models specified as arguments
        for model in "$@"; do
            install_model "$model"
            echo ""
        done
    fi

    echo -e "${GREEN}🎉 Installation completed!${NC}"
    echo ""
    echo -e "${BLUE}📋 Installed models:${NC}"
    docker exec deepseek-ollama ollama list
    echo ""
    echo -e "${YELLOW}💡 To test: curl -X POST http://localhost:${OLLAMA_PORT}/api/generate -d '{\"model\":\"deepseek-v3\",\"prompt\":\"Hello world in Node.js\"}'${NC}"
}

# Execute main function with all arguments
main "$@"