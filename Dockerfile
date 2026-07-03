FROM node:20-slim
WORKDIR /app
COPY package*.json ./
RUN npm install -g pnpm@9 && pnpm install
COPY . .
USER 1001
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl --fail http://localhost:8000 || exit 1
CMD ["npm", "start"]