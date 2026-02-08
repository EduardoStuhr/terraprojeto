# 🚀 GUIA DE INSTALAÇÃO E DEPLOY - TRANSJAP DDO

## 📋 Sumário

1. [Pré-requisitos](#pré-requisitos)
2. [Instalação Local (Desenvolvimento)](#instalação-local-desenvolvimento)
3. [Configuração do Banco de Dados](#configuração-do-banco-de-dados)
4. [Deploy em Produção](#deploy-em-produção)
5. [Configurações de Segurança](#configurações-de-segurança)
6. [Monitoramento e Logs](#monitoramento-e-logs)
7. [Backup e Recuperação](#backup-e-recuperação)

---

## 🔧 Pré-requisitos

### Desenvolvimento
- Node.js 20+ (LTS)
- Docker 24+ e Docker Compose
- Git
- PostgreSQL 15+ (se não usar Docker)
- Redis 7+ (se não usar Docker)

### Produção
- Servidor Linux (Ubuntu 22.04 LTS recomendado)
- 4GB RAM mínimo (8GB recomendado)
- 20GB espaço em disco
- Domínio configurado (para HTTPS)
- SSL/TLS certificado (Let's Encrypt recomendado)

---

## 💻 Instalação Local (Desenvolvimento)

### 1. Clonar o Repositório

```bash
git clone https://github.com/transjap/ddo-system.git
cd ddo-system
```

### 2. Configurar Variáveis de Ambiente

#### Backend (.env)

```bash
# Criar arquivo .env na pasta backend
cd backend
cp .env.example .env
```

Arquivo `.env`:

```env
# === APLICAÇÃO ===
NODE_ENV=development
PORT=3000
API_URL=http://localhost:3000

# === BANCO DE DADOS ===
DATABASE_URL=postgresql://transjap_user:transjap_secure_password_2024@localhost:5432/transjap_ddo?schema=public

# === REDIS ===
REDIS_URL=redis://:transjap_redis_password@localhost:6379

# === JWT ===
JWT_SECRET=transjap_jwt_secret_key_very_secure_change_in_production
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_SECRET=transjap_refresh_token_secret_very_secure
REFRESH_TOKEN_EXPIRES_IN=7d

# === AWS S3 / MINIO ===
AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=minioadmin
AWS_REGION=us-east-1
AWS_S3_BUCKET=transjap-ddo
S3_ENDPOINT=http://localhost:9000
USE_S3=true

# === E-MAIL (SMTP) ===
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-app
EMAIL_FROM="TRANSJAP DDO <noreply@transjap.com.br>"

# === SEGURANÇA ===
BCRYPT_ROUNDS=12
RATE_LIMIT_MAX=100
RATE_LIMIT_WINDOW_MS=900000

# === LOGS ===
LOG_LEVEL=debug
LOG_FILE=./logs/app.log
```

#### Frontend (.env)

```bash
cd ../frontend
cp .env.example .env
```

Arquivo `.env`:

```env
VITE_API_URL=http://localhost:3000/api
VITE_APP_NAME=TRANSJAP DDO
VITE_APP_VERSION=1.0.0
VITE_ENABLE_DEVTOOLS=true
```

### 3. Instalar Dependências

#### Backend

```bash
cd backend
npm install
```

#### Frontend

```bash
cd ../frontend
npm install
```

### 4. Iniciar com Docker Compose

```bash
# Na raiz do projeto
docker-compose up -d

# Ver logs
docker-compose logs -f

# Parar containers
docker-compose down
```

### 5. Executar Migrations

```bash
cd backend
npx prisma migrate dev
npx prisma generate
```

### 6. Seed (Dados Iniciais)

```bash
npm run seed
```

O seed cria:
- 1 Empresa (TRANSJAP)
- 1 Proprietário (admin@transjap.com.br / senha: Admin@123)
- 1 Engenheiro
- 1 Supervisor
- 1 Encarregado
- 2 Obras de exemplo
- 5 Máquinas
- 10 Funcionários

### 7. Acessar Aplicação

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3000
- **API Docs (Swagger)**: http://localhost:3000/api-docs
- **Adminer (DB)**: http://localhost:8080
- **MinIO Console**: http://localhost:9001

**Login padrão:**
- Email: `admin@transjap.com.br`
- Senha: `Admin@123`

---

## 🗄️ Configuração do Banco de Dados

### Criar Banco Manualmente (sem Docker)

```bash
# Conectar ao PostgreSQL
psql -U postgres

# Criar usuário
CREATE USER transjap_user WITH PASSWORD 'transjap_secure_password_2024';

# Criar banco
CREATE DATABASE transjap_ddo OWNER transjap_user;

# Conceder privilégios
GRANT ALL PRIVILEGES ON DATABASE transjap_ddo TO transjap_user;

# Conectar ao banco
\c transjap_ddo

# Habilitar extensões
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

# Sair
\q
```

### Executar Migrations

```bash
cd backend
npx prisma migrate deploy
```

### Resetar Banco (CUIDADO!)

```bash
npx prisma migrate reset
```

---

## 🌐 Deploy em Produção

### Opção 1: VPS (DigitalOcean, Linode, AWS EC2)

#### 1. Preparar Servidor

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Instalar Node.js (opcional, para builds)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Instalar Git
sudo apt install git -y

# Criar usuário para aplicação
sudo adduser transjap
sudo usermod -aG docker transjap
```

#### 2. Clonar e Configurar

```bash
# Trocar para usuário transjap
su - transjap

# Clonar repositório
git clone https://github.com/transjap/ddo-system.git
cd ddo-system

# Configurar .env de produção
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env

# IMPORTANTE: Editar arquivos .env com credenciais seguras!
nano backend/.env
nano frontend/.env
```

#### 3. Build e Deploy

```bash
# Build do frontend
cd frontend
npm install
npm run build

# Build do backend (se necessário)
cd ../backend
npm install
npm run build

# Subir containers
cd ..
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

#### 4. Configurar NGINX

```nginx
# /etc/nginx/sites-available/transjap-ddo

server {
    listen 80;
    server_name ddo.transjap.com.br;

    # Redirecionar para HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ddo.transjap.com.br;

    # SSL
    ssl_certificate /etc/letsencrypt/live/ddo.transjap.com.br/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ddo.transjap.com.br/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Frontend
    location / {
        root /home/transjap/ddo-system/frontend/dist;
        try_files $uri $uri/ /index.html;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Limites
    client_max_body_size 50M;
}
```

```bash
# Habilitar site
sudo ln -s /etc/nginx/sites-available/transjap-ddo /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### 5. SSL com Let's Encrypt

```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obter certificado
sudo certbot --nginx -d ddo.transjap.com.br

# Renovação automática (já configurado)
sudo certbot renew --dry-run
```

### Opção 2: Vercel (Frontend) + Railway/Render (Backend)

#### Frontend no Vercel

```bash
# Instalar Vercel CLI
npm i -g vercel

# Deploy
cd frontend
vercel --prod
```

#### Backend no Railway

1. Criar conta em railway.app
2. Conectar repositório GitHub
3. Adicionar serviço PostgreSQL
4. Adicionar serviço Redis
5. Configurar variáveis de ambiente
6. Deploy automático

---

## 🔒 Configurações de Segurança

### 1. Variáveis de Ambiente

**NUNCA commitar .env no Git!**

```bash
# Adicionar ao .gitignore
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore
echo ".env.production" >> .gitignore
```

### 2. Firewall

```bash
# UFW (Ubuntu)
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 3. Fail2Ban (Proteção contra Brute Force)

```bash
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 4. Backup Automático

```bash
# Script de backup (backup.sh)
#!/bin/bash

BACKUP_DIR="/home/transjap/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup do banco
docker exec transjap-postgres pg_dump -U transjap_user transjap_ddo | gzip > "$BACKUP_DIR/db_$DATE.sql.gz"

# Backup de arquivos
tar -czf "$BACKUP_DIR/files_$DATE.tar.gz" /home/transjap/ddo-system

# Manter apenas últimos 30 dias
find $BACKUP_DIR -type f -mtime +30 -delete

echo "Backup concluído: $DATE"
```

```bash
# Tornar executável
chmod +x backup.sh

# Agendar no crontab (todo dia às 2h)
crontab -e
# Adicionar:
0 2 * * * /home/transjap/backup.sh
```

---

## 📊 Monitoramento e Logs

### Ver Logs

```bash
# Backend
docker logs -f transjap-backend

# PostgreSQL
docker logs -f transjap-postgres

# Todos
docker-compose logs -f
```

### PM2 (Gerenciador de Processos)

```bash
# Instalar PM2
npm install -g pm2

# Iniciar aplicação
pm2 start npm --name "transjap-backend" -- start

# Monitorar
pm2 monit

# Logs
pm2 logs

# Reiniciar
pm2 restart transjap-backend

# Auto-start no boot
pm2 startup
pm2 save
```

---

## 📝 Comandos Úteis

```bash
# Reiniciar apenas backend
docker-compose restart backend

# Rebuild backend
docker-compose up -d --build backend

# Ver uso de recursos
docker stats

# Limpar volumes não utilizados
docker volume prune

# Atualizar sistema
git pull origin main
docker-compose down
docker-compose up -d --build
```

---

## 🆘 Troubleshooting

### Backend não conecta ao banco

```bash
# Verificar se PostgreSQL está rodando
docker ps | grep postgres

# Ver logs do PostgreSQL
docker logs transjap-postgres

# Testar conexão
docker exec -it transjap-postgres psql -U transjap_user -d transjap_ddo
```

### Erro de permissão no Docker

```bash
# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
newgrp docker
```

### Reset completo

```bash
docker-compose down -v
docker system prune -a
docker volume prune
# Recriar tudo
docker-compose up -d
```

---

**Sistema TRANSJAP DDO v1.0**  
Documentação criada em 07/02/2026
