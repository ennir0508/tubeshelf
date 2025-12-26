# 参考: https://bun.com/docs/guides/ecosystem/docker

# 公式Bunイメージを使用
# すべてのバージョンは https://hub.docker.com/r/oven/bun/tags で確認できます
FROM oven/bun:1 AS base
WORKDIR /usr/src/app

# 依存関係を一時ディレクトリにインストール
# これによりキャッシュが効き、将来のビルドが高速化されます
FROM base AS install
RUN mkdir -p /temp/dev
COPY package.json bun.lock /temp/dev/
RUN cd /temp/dev && bun install --frozen-lockfile

# --production 付きでインストール (devDependencies を除外)
RUN mkdir -p /temp/prod
COPY package.json bun.lock /temp/prod/
RUN cd /temp/prod && bun install --frozen-lockfile --production

# 一時ディレクトリから node_modules をコピー
# その後、(無視されていない) すべてのプロジェクトファイルをイメージにコピー
FROM base AS prerelease
COPY --from=install /temp/dev/node_modules node_modules
COPY . .

# [オプション] テストとビルド
ENV NODE_ENV=production
RUN bun test
RUN bun run build

# 本番用の依存関係とソースコードを最終イメージにコピー
FROM base AS release
COPY --from=install /temp/prod/node_modules node_modules
COPY --from=prerelease /usr/src/app/index.ts .
COPY --from=prerelease /usr/src/app/package.json .

# アプリを実行
USER bun

EXPOSE 3000/tcp

ENTRYPOINT [ "bun", "run", "index.ts" ]