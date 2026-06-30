# Build stage
FROM node:18-alpine as builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

# Production stage
FROM node:18-alpine

RUN npm install -g serve

WORKDIR /app

COPY --from=builder /app/build ./build

EXPOSE 3000

ENV REACT_APP_USER_API=http://user-service:3001
ENV REACT_APP_PRODUCT_API=http://product-service:3002

CMD ["serve", "-s", "build", "-l", "3000"]