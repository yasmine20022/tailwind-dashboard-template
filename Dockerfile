FROM node:20-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends python3 make g++ gcc curl && rm -rf /var/lib/apt/lists/*
COPY package*.json ./
RUN npm i -g pnpm@9 && pnpm install
COPY . .
RUN npm run build

FROM node:20-slim AS runtime
WORKDIR /app
COPY --from=builder /app ./
RUN groupadd -g 1001 app && useradd -u 1001 -g app -s /bin/bash -m app
USER app
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD curl --fail http://localhost:8000 || exit 1
CMD ["npx", "serve", "-s", "build", "-l", "8000"]
