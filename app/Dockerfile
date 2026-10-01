# Instalando dependências
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# Imagem final para rodar
FROM node:20-alpine AS final
WORKDIR /app

# Copiando dependências do estágio anterior e o código
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY src/ ./src/

# Trocando para o usuário sem privilégios de root
USER node

EXPOSE 3000
CMD ["npm", "start"]