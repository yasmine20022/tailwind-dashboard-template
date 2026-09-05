FROM node:20-slim AS builder
WORKDIR /app
COPY package.json ./
COPY package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN npm install -g pnpm@9; \
    pnpm config set dangerously-allow-all-builds true 2>/dev/null || true; \
    pnpm install --frozen-lockfile || pnpm install --no-frozen-lockfile
COPY . .
RUN pnpm run build
# Normalise the build output directory (Vite/Vue → dist, CRA → build) to /app/dist
RUN if [ -d dist ]; then :; elif [ -d build ]; then mv build dist; fi

FROM nginx:1.27-alpine AS runtime
COPY --from=builder /app/dist /usr/share/nginx/html
RUN printf 'server { listen 8000; root /usr/share/nginx/html; location / { try_files $uri $uri/ /index.html; } }\n' > /etc/nginx/conf.d/default.conf
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -q --spider http://127.0.0.1:8000/ || exit 1
CMD ["nginx", "-g", "daemon off;"]
