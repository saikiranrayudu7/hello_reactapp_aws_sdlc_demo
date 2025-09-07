# -------- Stage 1: Build React app --------
FROM public.ecr.aws/docker/library/node:18-alpine AS build

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++ bash

COPY package*.json ./
RUN npm ci --no-audit --silent

COPY . .
RUN npm run build

# -------- Stage 2: Nginx production server --------
FROM public.ecr.aws/docker/library/nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
