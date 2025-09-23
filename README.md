# DeepSeek Local 🤖

Execute modelos de IA localmente para desenvolvimento sem limitações de tokens ou conexão com internet.

## O que é?

Um setup Docker completo para rodar **DeepSeek V3** e outros modelos de IA localmente no seu servidor. Ideal para:

- ✅ **Desenvolvimento sem limites** - Sem tokens ou rate limits
- ✅ **Privacidade total** - Tudo roda na sua rede
- ✅ **Sempre disponível** - Funciona offline
- ✅ **Múltiplos modelos** - DeepSeek, Qwen, Code Llama, etc.

## Requisitos Mínimos

- **32GB RAM** (recomendado para DeepSeek V3)
- **20GB espaço livre** em disco
- **Docker** e **Docker Compose** instalados
- **Ubuntu Server/Desktop** ou similar

## Instalação Rápida

### 1. Baixar o projeto

```bash
git clone https://github.com/seuusuario/deepseek-local.git
cd deepseek-local
```

### 2. Dar permissões aos scripts

```bash
chmod +x scripts/*.sh
```

### 3. Configurar e instalar

```bash
# Instala tudo automaticamente
./scripts/setup.sh
```

**Pronto!** Em alguns minutos você terá:
- 🌐 **API local**: `http://localhost:11434`
- 🖥️ **Interface web**: `http://localhost:3000`

### 4. Testar se funcionou

```bash
# Testa a API
./scripts/start.sh test

# Ou acesse a interface web no navegador
# http://localhost:3000
```

## Comandos Essenciais

```bash
# ⚡ Comandos rápidos do dia a dia
./scripts/start.sh start     # Iniciar tudo
./scripts/start.sh stop      # Parar tudo
./scripts/start.sh status    # Ver se está rodando
./scripts/start.sh test      # Testar com exemplo

# 📦 Gerenciar modelos
./scripts/start.sh models                    # Listar instalados
./scripts/start.sh install deepseek-v3       # Instalar modelo
./scripts/start.sh install qwen2.5-coder:7b  # Modelo menor
```

## Modelos Recomendados

| Modelo | Tamanho | Melhor para | RAM necessária |
|--------|---------|-------------|----------------|
| `qwen2.5-coder:7b` | ~5GB | Código rápido | 16GB |
| `deepseek-v3` | ~14GB | Melhor qualidade | 32GB |
| `deepseek-coder:6.7b` | ~4GB | Só programação | 16GB |

## Usar via API

### cURL
```bash
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-v3",
    "prompt": "Crie uma função Node.js para ler CSV",
    "stream": false
  }'
```

### Node.js
```javascript
const response = await fetch('http://localhost:11434/api/generate', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    model: 'deepseek-v3',
    prompt: 'Explique async/await em JavaScript',
    stream: false
  })
});
const data = await response.json();
console.log(data.response);
```

### Ruby
```ruby
require 'net/http'
require 'json'

uri = URI('http://localhost:11434/api/generate')
request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request.body = {
  model: 'deepseek-v3',
  prompt: 'Como usar gems no Ruby?',
  stream: false
}.to_json

response = Net::HTTP.start(uri.hostname, uri.port) do |http|
  http.request(request)
end

puts JSON.parse(response.body)['response']
```

## Acesso Remoto

Para usar de outros computadores na rede:

1. **Descobrir IP do servidor:**
```bash
./scripts/start.sh urls
```

2. **Acessar de outros dispositivos:**
- API: `http://IP-DO-SERVIDOR:11434`  
- Interface: `http://IP-DO-SERVIDOR:3000`

## Personalização

### Trocar portas
Edite o arquivo `.env`:
```bash
OLLAMA_PORT=11434
WEBUI_PORT=3000
```

### Modelos padrão
Modifique no `.env` quais modelos instalar automaticamente:
```bash
DEFAULT_MODELS=deepseek-v3,qwen2.5-coder:7b,codellama:7b
```

## Troubleshooting

### Container não inicia
```bash
# Ver logs
./scripts/start.sh logs

# Verificar recursos
docker system df
free -h
```

### Modelo não responde
```bash
# Verificar se está instalado
./scripts/start.sh models

# Reinstalar modelo
./scripts/start.sh install deepseek-v3
```

### Limpar tudo e recomeçar
```bash
# ⚠️ Remove todos os modelos baixados
./scripts/start.sh cleanup
./scripts/setup.sh
```

## Estrutura do Projeto

```
deepseek-local/
├── docker-compose.yml    # Configuração Docker
├── .env                 # Variáveis de ambiente
├── scripts/
│   ├── setup.sh        # Instalação inicial
│   ├── start.sh        # Comandos diários
│   └── install-models.sh # Gerenciar modelos
└── README.md           # Esta documentação
```

## Suporte

- **Logs detalhados**: `./scripts/start.sh logs`
- **Status completo**: `./scripts/start.sh status`  
- **Teste da API**: `./scripts/start.sh test "seu prompt aqui"`

---

**🎉 Agora você tem IA local ilimitada para desenvolvimento!**