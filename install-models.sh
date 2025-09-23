#!/bin/bash

# Script para instalar modelos do DeepSeek/Ollama
# Mostra progresso visual durante o download

set -e

# Carregar configurações
if [ -f .env ]; then
    source .env
else
    OLLAMA_PORT=11434
    DEFAULT_MODELS="deepseek-v3,qwen2.5-coder:7b"
fi

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para mostrar spinner durante operações
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

# Função para verificar se modelo já está instalado
model_exists() {
    local model=$1
    docker exec deepseek-ollama ollama list | grep -q "^$model"
}

# Função para instalar um modelo
install_model() {
    local model=$1
    
    echo -e "${BLUE}📥 Instalando modelo: ${YELLOW}$model${NC}"
    
    if model_exists "$model"; then
        echo -e "${GREEN}✅ Modelo $model já está instalado${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}⏳ Download em progresso... (pode demorar alguns minutos)${NC}"
    echo -e "${YELLOW}💡 Dica: Abra outro terminal para monitorar: docker-compose logs -f ollama${NC}"
    
    # Instalar modelo em background e mostrar progresso
    (docker exec deepseek-ollama ollama pull "$model") &
    local pull_pid=$!
    
    # Mostrar spinner enquanto instala
    show_spinner $pull_pid
    
    # Aguardar processo terminar
    wait $pull_pid
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Modelo $model instalado com sucesso!${NC}"
        
        # Mostrar tamanho do modelo
        echo -e "${BLUE}📊 Verificando tamanho...${NC}"
        docker exec deepseek-ollama ollama list | grep "$model"
    else
        echo -e "${RED}❌ Erro ao instalar modelo $model${NC}"
        return 1
    fi
}

# Função para listar modelos disponíveis
list_available_models() {
    echo -e "${BLUE}📋 Modelos recomendados para desenvolvimento:${NC}"
    echo ""
    echo -e "${GREEN}Pequenos (4-8GB):${NC}"
    echo "  • deepseek-coder:6.7b    - Especialista em código"
    echo "  • qwen2.5-coder:7b       - Ótimo para Node/Ruby"
    echo "  • codellama:7b           - Meta Code Llama"
    echo ""
    echo -e "${YELLOW}Médios (15-25GB):${NC}"
    echo "  • deepseek-v3            - Melhor qualidade geral"
    echo "  • qwen2.5-coder:32b      - Especialista avançado"
    echo ""
    echo -e "${RED}Grandes (30GB+):${NC}"
    echo "  • llama3.3:70b           - Máxima qualidade"
    echo ""
}

# Função principal
main() {
    echo -e "${BLUE}🤖 DeepSeek Model Installer${NC}"
    echo ""
    
    # Verificar se Ollama está rodando
    if ! curl -s http://localhost:${OLLAMA_PORT}/api/tags > /dev/null; then
        echo -e "${RED}❌ Ollama não está rodando. Execute 'docker-compose up -d' primeiro.${NC}"
        exit 1
    fi
    
    # Se nenhum argumento foi passado, usar DEFAULT_MODELS
    if [ $# -eq 0 ]; then
        if [ ! -z "$DEFAULT_MODELS" ]; then
            echo -e "${YELLOW}📦 Instalando modelos padrão: $DEFAULT_MODELS${NC}"
            IFS=',' read -ra MODELS <<< "$DEFAULT_MODELS"
            for model in "${MODELS[@]}"; do
                model=$(echo "$model" | xargs) # Remove espaços
                install_model "$model"
                echo ""
            done
        else
            echo -e "${YELLOW}🤔 Nenhum modelo especificado.${NC}"
            list_available_models
            exit 0
        fi
    else
        # Instalar modelos especificados como argumentos
        for model in "$@"; do
            install_model "$model"
            echo ""
        done
    fi
    
    echo -e "${GREEN}🎉 Instalação concluída!${NC}"
    echo ""
    echo -e "${BLUE}📋 Modelos instalados:${NC}"
    docker exec deepseek-ollama ollama list
    echo ""
    echo -e "${YELLOW}💡 Para testar: curl -X POST http://localhost:${OLLAMA_PORT}/api/generate -d '{\"model\":\"deepseek-v3\",\"prompt\":\"Hello world in Node.js\"}'${NC}"
}

# Executar função principal com todos os argumentos
main "$@"