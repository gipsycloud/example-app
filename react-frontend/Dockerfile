FROM node:18-alpine AS build

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci --omit=dev

COPY . .

RUN npm run build

FROM node:18-alpine AS production

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/build /usr/src/app/build

RUN npm install express

RUN echo 'const express = require("express"); const path = require("path"); const port = process.env.PORT || 3000; const app = express(); app.use(express.static(path.join(__dirname, "build"))); app.get("*", (req, res) => { res.sendFile(path.join(__dirname, "build", "index.html")); }); app.listen(port, () => { console.log(`Server is running on port ${port}`); });' > server.js

EXPOSE 3000

CMD ["node", "server.js"]