# -------- Stage 1: Build React app --------
FROM public.ecr.aws/docker/library/node:18-alpine AS build

WORKDIR /app

# Install build dependencies for Alpine
RUN apk add --no-cache python3 make g++ bash

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies with offline fallback
RUN npm ci --no-audit --offline || npm ci --no-audit

# Copy all other source files
COPY . .

# Build React app
RUN npm run build

# -------- Stage 2: Nginx production server --------
FROM public.ecr.aws/docker/library/nginx:alpine

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy built React app from build stage
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
