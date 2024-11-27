# build container
FROM node:18-alpine AS build

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci -omit=dev

COPY . .

# prod container
FROM node:18-alpine AS production

WORKDIR /usr/src/app

COPY --from=build /usr/src/app /usr/src/app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

RUN chown -R appuser:appgroup /usr/src/app

USER appuser

EXPOSE 3000

CMD ["node", "index.js"]