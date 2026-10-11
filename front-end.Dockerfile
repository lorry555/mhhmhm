FROM node:24-alpine

WORKDIR /app

COPY front-end/ .

RUN npm install

EXPOSE 8505

ENTRYPOINT [ "npm", "run", "dev" ]
