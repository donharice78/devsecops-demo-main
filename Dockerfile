# Build stage (Node.js with locked Alpine version)
FROM node:20-alpine3.21 AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev && \
    apk upgrade --no-cache libexpat libxml2 libxslt  # Patch critical CVEs
COPY . .
RUN npm run build

# Production stage (Nginx with locked Alpine version)
FROM nginx:1.27-alpine3.21
RUN apk upgrade --no-cache libexpat libxml2 libxslt  # Patch CVEs
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]