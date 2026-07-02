FROM node:20-slim
WORKDIR /app
COPY package*.json ./
RUN npm install -g pnpm@9 && pnpm install
COPY . .
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /app
USER appuser
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl --fail http://localhost:8000 || exit 1
CMD ["npm", "start"]