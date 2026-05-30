FROM node:20-alpine AS builder
WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

FROM node:20-alpine AS runner
WORKDIR /usr/src/app

ENV NODE_ENV=production
ENV PORT=80

COPY --from=builder /usr/src/app/package*.json ./
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/src ./src

USER node

EXPOSE 80

CMD ["node", "src/index.js"]
