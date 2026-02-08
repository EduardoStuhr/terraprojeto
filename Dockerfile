FROM node:20-bookworm-slim

WORKDIR /app

# dependências que o Prisma precisa (openssl + certificados)
RUN apt-get update && apt-get install -y openssl ca-certificates && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci

COPY . .

# gera prisma dentro do linux do container (IMPORTANTÍSSIMO)
RUN npx prisma generate

EXPOSE 3000
CMD ["npm","run","dev"]
