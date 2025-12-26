# 開発用 Dockerfile
# 参考: https://bun.com/docs/guides/ecosystem/docker

# 公式Bunイメージを使用
FROM oven/bun:1 AS base

ENV TZ=Asia/Tokyo
ENV LANG=ja_JP.UTF-8

WORKDIR /usr/src/app

# 必要なツールのインストール (wgetはAntigravity Serverのインストールに必須)
RUN apt-get update && apt-get install -y wget unzip procps chromium

# 作業ディレクトリの所有権をbunユーザーに変更
RUN chown -R bun:bun /usr/src/app

# 以降のコマンドをbunユーザーで実行
USER bun

# ソースコードをコピー
COPY --chown=bun:bun ./extension .
COPY --chown=bun:bun ./docker/setup.sh .

# 依存関係をインストール
RUN bun install
RUN bun run postinstall

# 開発用サーバー起動
EXPOSE 3000

ENTRYPOINT ["./setup.sh"]