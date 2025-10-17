# -------- Stage 1: Build React app --------
FROM public.ecr.aws/docker/library/node:18-alpine AS build

# Set working directory
WORKDIR /app

# Install dependencies only if package.json changes (better caching)
COPY package*.json ./
RUN npm ci --no-audit --silent

# Copy everything else and build
COPY . .
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

