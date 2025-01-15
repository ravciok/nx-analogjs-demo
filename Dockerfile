FROM node:22-slim AS base
WORKDIR /usr/src/app
RUN corepack enable

FROM base AS install
RUN mkdir -p /temp/dev
COPY package.json pnpm-lock.yaml /temp/dev/
RUN cd /temp/dev && pnpm install --frozen-lockfile

FROM base AS prerelease
COPY --from=install /temp/dev/node_modules node_modules
COPY . .
RUN pnpm nx build app

FROM base AS release
COPY --from=prerelease /usr/src/app/dist/app .
WORKDIR /usr/src/app/analog/server
EXPOSE 3000/tcp
ENTRYPOINT ["node", "index.mjs" ]
