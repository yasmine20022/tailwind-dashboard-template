FROM node:18-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends python3 make g++ && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY package*.json /app/
COPY pnpm-lock.yaml /app/
RUN npm i -g pnpm@9 && pnpm install --frozen-lockfile
COPY . /app/

FROM node:18-slim AS runtime
RUN groupadd -r nodeuser && useradd -r -g nodeuser nodeuser && mkdir -p /app && chown nodeuser:nodeuser /app
WORKDIR /app
COPY --from=builder /app /app
USER nodeuser
EXPOSE 8000
HEALTHCHECK CMD curl --fail http://localhost:8000 || exit 1
CMD ["npx","serve","-s","dist","-l","8000"]