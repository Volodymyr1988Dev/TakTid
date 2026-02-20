# -----------------------------
# 1️⃣ CLIENT BUILD
# -----------------------------
FROM node:20-alpine AS client-build

WORKDIR /app/client

COPY client/package*.json ./
RUN npm ci

COPY client/ .
RUN npm run build


# -----------------------------
# 2️⃣ SERVER BUILD
# -----------------------------
FROM node:20-alpine AS server-build

WORKDIR /app/server

COPY server/package*.json ./
RUN npm ci

COPY server/ .
RUN npm run build


# -----------------------------
# 3️⃣ PRODUCTION IMAGE
# -----------------------------
FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production

COPY server/package*.json ./
RUN npm ci --omit=dev

COPY --from=server-build /app/server/dist ./dist
COPY --from=client-build /app/client/dist ./public

EXPOSE 8080

CMD ["node", "dist/main.js"]