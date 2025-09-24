# DeepSeek Local - Contexto para Claude Code

## Sobre o Projeto

Este projeto configura um ambiente Docker para executar modelos de IA (DeepSeek V3, Qwen, Code Llama) localmente, eliminando dependência de APIs externas e limitações de tokens.

## Arquitetura

- **Docker Compose**: Orquestra containers Ollama + Interface Web
- **Ollama**: Runtime para modelos LLM locais
- **Open WebUI**: Interface web para interação
- **Scripts bash**: Automação de setup e gerenciamento

## Estrutura de Arquivos

```
deepseek-local/
├── docker-compose.yml     # Configuração dos containers
├── .env                  # Variáveis de ambiente e configurações
├── scripts/
│   ├── setup.sh         # Script de instalação inicial
│   ├── start.sh         # Comandos para uso diário
│   └── install-models.sh # Gerenciamento de modelos
├── README.md            # Documentação para usuários
└── CLAUDE.md           # Este arquivo (contexto para Claude Code)
```

## Configurações Principais

### Docker Compose (`docker-compose.yml`)
- **ollama**: Container principal rodando na porta 11434
- **open-webui**: Interface web na porta 3000
- **Volumes persistentes**: Para armazenar modelos baixados
- **Limitação de recursos**: Configurável via .env
- **Health checks**: Para garantir funcionamento

### Variáveis de Ambiente (`.env`)
- `OLLAMA_PORT`: Porta da API (padrão: 11434)
- `WEBUI_PORT`: Porta da interface web (padrão: 3000)
- `MEMORY_LIMIT`: Limite de RAM para o container
- `DEFAULT_MODELS`: Modelos instalados automaticamente

## Scripts de Automação

### `setup.sh`
- Verifica dependências (Docker, Docker Compose)
- Sobe containers
- Instala modelos padrão
- Mostra URLs de acesso

### `start.sh`
Gerenciador principal com comandos:
- `start/stop/restart`: Controle dos serviços
- `status`: Verifica saúde dos containers
- `models`: Lista modelos instalados
- `install`: Instala novos modelos
- `test`: Testa API com prompt
- `logs`: Visualiza logs em tempo real

### `install-models.sh`
- Download com progresso visual
- Verifica se modelo já existe
- Suporte a múltiplos modelos
- Lista modelos recomendados por tamanho

## Modelos Suportados

### Pequenos (4-8GB RAM)
- `qwen2.5-coder:7b`: Otimizado para código
- `deepseek-coder:6.7b`: Especialista em programação
- `codellama:7b`: Meta Code Llama

### Médios (15-25GB RAM)
- `deepseek-v3`: Melhor qualidade geral (~14B parâmetros)
- `qwen2.5-coder:32b`: Especialista avançado

### Grandes (30GB+ RAM)
- `llama3.3:70b`: Máxima qualidade (quantizado)

## API Usage

### Endpoint Principal
`POST http://localhost:11434/api/generate`

### Payload Exemplo
```json
{
  "model": "deepseek-v3",
  "prompt": "Crie uma função Node.js para ler CSV",
  "stream": false
}
```

### Response Format
```json
{
  "response": "conteúdo gerado pelo modelo",
  "done": true
}
```

## Casos de Uso Comuns

1. **Desenvolvimento sem limites**: Code completion, refactoring, debugging
2. **Prototipagem rápida**: Geração de código inicial
3. **Code review**: Análise e sugestões de melhorias
4. **Documentação**: Geração automática de docs
5. **Tradução de código**: Entre linguagens (Node.js ↔ Ruby)

## Requisitos de Hardware

### Mínimo
- 16GB RAM (para modelos 7B)
- 10GB espaço disco
- CPU multi-core

### Recomendado  
- 32GB RAM (para DeepSeek V3)
- 50GB espaço disco
- Apple M-series ou CPU x86 moderna

### Ideal
- 64GB+ RAM (múltiplos modelos grandes)
- SSD rápido
- GPU dedicada (futuro suporte)

## Troubleshooting Comum

### Container não inicia
- Verificar RAM disponível
- Checar portas em uso
- Validar permissões Docker

### Modelo não responde
- Confirmar instalação: `./scripts/start.sh models`
- Verificar logs: `./scripts/start.sh logs`
- Testar API: `./scripts/start.sh test`

### Performance lenta
- Aumentar `MEMORY_LIMIT` no .env
- Usar modelos menores (7B vs 70B)
- Fechar aplicações desnecessárias

## Desenvolvimento e Contribuição

### Padrões do Código
- Scripts bash com verificação de erros (`set -e`)
- Códigos coloridos para melhor UX
- Funções modulares e reutilizáveis
- Documentação inline nos scripts

### Extensões Possíveis
- Suporte GPU (NVIDIA/AMD)
- Múltiplos modelos simultâneos
- Interface CLI personalizada
- Integração com VSCode/IDEs
- API proxy com load balancing

## Considerações de Segurança

- **Rede local apenas**: Não expor publicamente sem autenticação
- **Firewall**: Configurar regras apropriadas
- **Updates**: Manter Docker e imagens atualizados
- **Backup**: Volumes contêm modelos valiosos (GBs)

## Performance Tips

1. **SSD**: Modelos carregam mais rápido
2. **RAM**: Mais RAM = modelos maiores + melhor cache
3. **CPU**: Mais cores = inferência mais rápida
4. **Swap**: Desabilitar ou configurar adequadamente para evitar slowdowns
