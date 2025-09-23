#!/bin/bash

# DeepSeek Local Setup Script
# Configura e inicia o ambiente DeepSeek com Docker

set -e  # Para na primeira erro

echo "🚀 Configurando DeepSeek Local..."

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não encontrado. Instale o Docker primeiro."
    echo "👉 https://docs.docker.com/engine/install/"
    exit 1
fi

# Verificar se Docker Compose está disponível
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose não encontrado."
    exit 1
fi

# Criar diretório de scripts se não existir
mkdir -p scripts

# Verificar se arquivo .env existe
if [ ! -f .env ]; then
    echo "❌ Arquivo .env não encontrado. Crie-o primeiro!"
    exit 1
fi

# Carregar variáveis do .env
source .env

echo "📦 Subindo containers..."
docker-compose up -d

echo "⏳ Aguardando Ollama inicializar..."
sleep 10

# Verificar se Ollama está funcionando
echo "🔍 Verificando se Ollama está rodando..."
if curl -s http://localhost:${OLLAMA_PORT}/api/tags > /dev/null; then
    echo "✅ Ollama está rodando!"
else
    echo "❌ Ollama não está respondendo. Verifique os logs:"
    echo "   docker-compose logs ollama"
    exit 1
fi

# Instalar modelos padrão se especificado
if [ ! -z "$DEFAULT_MODELS" ]; then
    echo "📥 Instalando modelos: $DEFAULT_MODELS"
    ./scripts/install-models.sh
fi

echo ""
echo "🎉 Setup concluído!"
echo ""
echo "📍 Acesso:"
echo "   API Ollama: http://localhost:${OLLAMA_PORT}"
echo "   Interface Web: http://localhost:${WEBUI_PORT}"
echo ""
echo "🛠️  Comandos úteis:"
echo "   docker-compose logs -f        # Ver logs"
echo "   docker-compose stop           # Parar"
echo "   docker-compose down           # Parar e remover"
echo "   ./scripts/install-models.sh   # Instalar mais modelos"
echo ""