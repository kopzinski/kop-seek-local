#!/bin/bash

# Script para gerenciar o DeepSeek Local
# Comandos rápidos para uso diário

set -e

# Carregar configurações
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

# Função para mostrar ajuda
show_help() {
    echo -e "${BLUE}🤖 DeepSeek Local Manager${NC}"
    echo ""
    echo -e "${YELLOW}Uso: $0 [comando]${NC}"
    echo ""
    echo -e "${GREEN}Comandos disponíveis:${NC}"
    echo "  start       - Inicia os serviços"
    echo "  stop        - Para os serviços"
    echo "  restart     - Reinicia os serviços"
    echo "  status      - Mostra status dos containers"
    echo "  logs        - Mostra logs em tempo real"
    echo "  models      - Lista modelos instalados"
    echo "  install     - Instala novos modelos"
    echo "  test        - Testa a API com exemplo"
    echo "  urls        - Mostra URLs de acesso"
    echo "  cleanup     - Remove containers e volumes"
    echo ""
    echo -e "${CYAN}Exemplos:${NC}"
    echo "  $0 start                    # Iniciar tudo"
    echo "  $0 install deepseek-v3      # Instalar modelo"
    echo "  $0 test 'Hello in Python'   # Testar com prompt"
    echo ""
}

# Função para verificar status
check_status() {
    echo -e "${BLUE}📊 Status dos serviços:${NC}"
    echo ""
    
    if docker-compose ps | grep -q "deepseek-ollama.*Up"; then
        echo -e "${GREEN}✅ Ollama: Rodando${NC}"
        if curl -s http://localhost:${OLLAMA_PORT}/api/tags > /dev/null; then
            echo -e "${GREEN}✅ API: Respondendo${NC}"
        else
            echo -e "${YELLOW}⚠️  API: Não responde${NC}"
        fi
    else
        echo -e "${RED}❌ Ollama: Parado${NC}"
    fi
    
    if docker-compose ps | grep -q "deepseek-webui.*Up"; then
        echo -e "${GREEN}✅ Interface Web: Rodando${NC}"
    else
        echo -e "${YELLOW}⚠️  Interface Web: Parado${NC}"
    fi
    
    echo ""
}

# Função para mostrar URLs
show_urls() {
    echo -e "${BLUE}🌐 URLs de Acesso:${NC}"
    echo ""
    echo -e "${GREEN}API Ollama:${NC}"
    echo "  http://localhost:${OLLAMA_PORT}"
    echo "  http://$(hostname -I | awk '{print $1}'):${OLLAMA_PORT}"
    echo ""
    echo -e "${GREEN}Interface Web:${NC}"
    echo "  http://localhost:${WEBUI_PORT}"
    echo "  http://$(hostname -I | awk '{print $1}'):${WEBUI_PORT}"
    echo ""
}

# Função para testar API
test_api() {
    local prompt="${1:-Escreva um Hello World em Node.js}"
    
    echo -e "${BLUE}🧪 Testando API com prompt: ${YELLOW}\"$prompt\"${NC}"
    echo ""
    
    # Verificar se há modelos instalados
    local models=$(docker exec deepseek-ollama ollama list 2>/dev/null | tail -n +2)
    if [ -z "$models" ]; then
        echo -e "${RED}❌ Nenhum modelo instalado. Execute: $0 install${NC}"
        return 1
    fi
    
    # Pegar primeiro modelo da lista
    local first_model=$(echo "$models" | head -n 1 | awk '{print $1}')
    
    echo -e "${YELLOW}📡 Usando modelo: $first_model${NC}"
    echo -e "${YELLOW}⏳ Gerando resposta...${NC}"
    echo ""
    
    curl -s -X POST http://localhost:${OLLAMA_PORT}/api/generate \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$first_model\",
            \"prompt\": \"$prompt\",
            \"stream\": false
        }" | jq -r '.response' 2>/dev/null || {
        echo -e "${RED}❌ Erro na API. Verifique os logs: $0 logs${NC}"
        return 1
    }
    
    echo ""
    echo -e "${GREEN}✅ Teste concluído!${NC}"
}

# Função principal
main() {
    case "${1:-help}" in
        "start")
            echo -e "${BLUE}🚀 Iniciando DeepSeek Local...${NC}"
            docker-compose up -d
            sleep 3
            check_status
            show_urls
            ;;
            
        "stop")
            echo -e "${YELLOW}⏸️  Parando serviços...${NC}"
            docker-compose stop
            echo -e "${GREEN}✅ Serviços parados${NC}"
            ;;
            
        "restart")
            echo -e "${YELLOW}🔄 Reiniciando serviços...${NC}"
            docker-compose restart
            sleep 3
            check_status
            ;;
            
        "status")
            check_status
            ;;
            
        "logs")
            echo -e "${BLUE}📋 Logs em tempo real (Ctrl+C para sair):${NC}"
            docker-compose logs -f
            ;;
            
        "models")
            echo -e "${BLUE}📦 Modelos instalados:${NC}"
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
            echo -e "${RED}🗑️  ATENÇÃO: Isso vai remover TODOS os dados!${NC}"
            read -p "Tem certeza? (s/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Ss]$ ]]; then
                docker-compose down -v
                docker volume prune -f
                echo -e "${GREEN}✅ Limpeza concluída${NC}"
            else
                echo -e "${YELLOW}Operação cancelada${NC}"
            fi
            ;;
            
        "help"|*)
            show_help
            ;;
    esac
}

# Executar função principal
main "$@"