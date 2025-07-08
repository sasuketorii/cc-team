# ベースイメージ
FROM node:18-alpine AS base

# 開発環境用イメージ
FROM base AS development
WORKDIR /app
RUN apk add --no-cache git python3 make g++
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# ビルドステージ
FROM base AS builder
WORKDIR /app
RUN apk add --no-cache git python3 make g++
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# 本番環境用イメージ
FROM base AS production
WORKDIR /app
RUN apk add --no-cache dumb-init
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/public ./public
USER node
EXPOSE 3000
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]