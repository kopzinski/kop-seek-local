# DeepSeek Local 🤖

Run AI models locally for development without token limitations or internet connection.

## What is it?

A complete Docker setup to run **DeepSeek V3** and other AI models locally on your server. Ideal for:

- ✅ **Unlimited development** - No tokens or rate limits
- ✅ **Total privacy** - Everything runs on your network
- ✅ **Always available** - Works offline
- ✅ **Multiple models** - DeepSeek, Qwen, Code Llama, etc.

## Minimum Requirements

- **32GB RAM** (recommended for DeepSeek V3)
- **20GB free space** on disk
- **Docker** and **Docker Compose** installed
- **Ubuntu Server/Desktop** or similar

## Quick Installation

### 1. Download the project

```bash
git clone https://github.com/yourusername/deepseek-local.git
cd deepseek-local
```

### 2. Give permissions to scripts

```bash
chmod +x scripts/*.sh
```

### 3. Configure and install

```bash
# Installs everything automatically
./scripts/setup.sh
```

**Done!** In a few minutes you'll have:
- 🌐 **Local API**: `http://localhost:11434`
- 🖥️ **Web interface**: `http://localhost:3000`

### 4. Test if it worked

```bash
# Test the API
./scripts/start.sh test

# Or access the web interface in browser
# http://localhost:3000
```

## Essential Commands

```bash
# ⚡ Quick daily commands
./scripts/start.sh start     # Start everything
./scripts/start.sh stop      # Stop everything
./scripts/start.sh status    # Check if running
./scripts/start.sh test      # Test with example

# 📦 Manage models
./scripts/start.sh models                    # List installed
./scripts/start.sh install deepseek-v3       # Install model
./scripts/start.sh install qwen2.5-coder:7b  # Smaller model
```

## Recommended Models

| Model | Size | Best for | Required RAM |
|-------|------|----------|--------------|
| `qwen2.5-coder:7b` | ~5GB | Fast code | 16GB |
| `deepseek-v3` | ~14GB | Best quality | 32GB |
| `deepseek-coder:6.7b` | ~4GB | Programming only | 16GB |

## Use via API

### cURL
```bash
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-v3",
    "prompt": "Create a Node.js function to read CSV",
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
    prompt: 'Explain async/await in JavaScript',
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
  prompt: 'How to use gems in Ruby?',
  stream: false
}.to_json

response = Net::HTTP.start(uri.hostname, uri.port) do |http|
  http.request(request)
end

puts JSON.parse(response.body)['response']
```

## Remote Access

To use from other computers on the network:

1. **Find server IP:**
```bash
./scripts/start.sh urls
```

2. **Access from other devices:**
- API: `http://SERVER-IP:11434`
- Interface: `http://SERVER-IP:3000`

## Customization

### Change ports
Edit the `.env` file:
```bash
OLLAMA_PORT=11434
WEBUI_PORT=3000
```

### Default models
Modify in `.env` which models to install automatically:
```bash
DEFAULT_MODELS=deepseek-v3,qwen2.5-coder:7b,codellama:7b
```

## Troubleshooting

### Container won't start
```bash
# View logs
./scripts/start.sh logs

# Check resources
docker system df
free -h
```

### Model not responding
```bash
# Check if installed
./scripts/start.sh models

# Reinstall model
./scripts/start.sh install deepseek-v3
```

### Clean everything and restart
```bash
# ⚠️ Removes all downloaded models
./scripts/start.sh cleanup
./scripts/setup.sh
```

## Project Structure

```
deepseek-local/
├── docker-compose.yml    # Docker configuration
├── .env                 # Environment variables
├── scripts/
│   ├── setup.sh        # Initial installation
│   ├── start.sh        # Daily commands
│   └── install-models.sh # Manage models
└── README.md           # This documentation
```

## Support

- **Detailed logs**: `./scripts/start.sh logs`
- **Complete status**: `./scripts/start.sh status`
- **API test**: `./scripts/start.sh test "your prompt here"`

---

**🎉 Now you have unlimited local AI for development!**