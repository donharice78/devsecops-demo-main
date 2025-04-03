# Build stage - Node.js with explicit package handling
FROM node:20-alpine3.21 AS build
WORKDIR /app

# 1. First copy package files
COPY package*.json ./

# 2. Install dependencies (without devDependencies)
RUN npm ci --omit=dev

# 3. Upgrade system packages WITHOUT affecting Node.js
RUN apk upgrade --no-cache && \
    apk add --no-cache --upgrade libexpat libxml2 libxslt

# 4. Copy source and build
COPY . .
RUN npm run build

# Production stage - Nginx with security updates
FROM nginx:1.27-alpine3.21
RUN apk upgrade --no-cache libexpat libxml2 libxslt
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"] # Run Nginx in the foreground