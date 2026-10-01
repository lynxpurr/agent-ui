# Agent UI (agno-agi/agent-ui) — ANF deployment build
# Standalone Next.js build with two ANF tweaks applied at build time:
#   1. output: 'standalone' injected into next.config.ts
#   2. default endpoint preset to local AgentOS (http://127.0.0.1:8767)
# NOTE: pnpm pinned to v10 (corepack-latest v11 publishedAt age-check crashes
# against npmmirror abbreviated metadata — Invalid URL in getAuthHeaderValueByURI)
ARG NPM_REGISTRY=https://registry.npmjs.org

FROM node:22-alpine AS deps
WORKDIR /app
ARG NPM_REGISTRY
RUN npm install -g pnpm@10
COPY package.json pnpm-lock.yaml ./
RUN echo "registry=${NPM_REGISTRY:-https://registry.npmjs.org}" > .npmrc && pnpm install --frozen-lockfile

FROM node:22-alpine AS build
WORKDIR /app
RUN npm install -g pnpm@10
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN sed -i "s/devIndicators: false/devIndicators: false, output: 'standalone'/" next.config.ts \
 && sed -i "s#http://localhost:7777#http://127.0.0.1:8767#g" src/store.ts src/components/chat/Sidebar/Sidebar.tsx
ENV NEXT_TELEMETRY_DISABLED=1
RUN pnpm build

FROM node:22-alpine AS run
WORKDIR /app
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 PORT=3000 HOSTNAME=0.0.0.0
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
EXPOSE 3000
CMD ["node", "server.js"]
