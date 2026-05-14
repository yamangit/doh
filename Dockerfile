FROM node:22-alpine

WORKDIR /app
COPY package.json package-lock.json* ./
COPY src ./src
COPY config ./config
COPY README.md ./

USER node
EXPOSE 53/udp 53/tcp 8080/tcp
ENTRYPOINT ["node", "/app/src/cli.js"]
