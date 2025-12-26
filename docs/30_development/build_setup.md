# 環境構築・ビルド手順 (Build Setup)

本プロジェクトでは、開発環境の均一化とセットアップの簡略化のために Docker を利用しています。
Chrome 拡張機能としてのビルド手順も併せて説明します。

## 1. 前提条件 (Prerequisites)

- **Docker Desktop**: コンテナランタイムとして必要です。
- **VS Code** (推奨): エディタとして推奨します。
- **Dev Containers** (推奨): VS Code 拡張機能。コンテナ内での開発をスムーズに行うために推奨します。

## 2. プロジェクトの新規作成 (New Project Creation)

プロジェクトを新規作成する手順です。プロジェクト作成済である場合は不要です。

### プロジェクトディレクトリ 作成

以下のコマンドを実行して、プロジェクトディレクトリを作成します。

```bash
mkdir <project_name>
cd <project_name>
```

### WXT プロジェクト作成

WXTを用いてカレントディレクトリにプロジェクトを作成します。

```bash
docker run --rm -u bun -v ${PWD}/app:/home/bun/app oven/bun bunx wxt@latest init
docker run --rm -u bun -v ${PWD}/app:/home/bun/app oven/bun bun install --lockfile-only
```

### Dockerfile 作成

以下の内容を `Dockerfile` に保存してください。

```dockerfile
FROM oven/bun:1 AS base

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y wget unzip procps chromium

RUN chown -R bun:bun /usr/src/app

USER bun

COPY --chown=bun:bun ./app .
COPY --chown=bun:bun ./setup.sh .

RUN bun install
RUN bun run postinstall

EXPOSE 3000/tcp

ENTRYPOINT ["./setup.sh"]
```

### docker-compose.yaml 作成

```yaml
services:
  extension:
    build:
      context: .
    tty: true
    ports:
      - "3000:3000"
    volumes:
      - ./app:/usr/src/app
      - ./setup.sh:/usr/src/app/setup.sh
      - /usr/src/app/node_modules
    environment:
      - NODE_ENV=development
```

### .dockerignore 作成

```dockerignore
node_modules
Dockerfile*
docker-compose*
.dockerignore
.git
.gitignore
README.md
LICENSE
.vscode
Makefile
helm-charts
.env
.editorconfig
.idea
coverage*
```

### wxt.config.ts 修正

`wxt.config.ts` の内容を以下のように修正してください。

```ts
export default defineConfig({
  modules: ['@wxt-dev/module-react'],
  dev: {
    server: {
      host: '0.0.0.0',
      port: 3000,
    }
  },
  webExt: {
    disabled: true,
  },
  vite: () => ({
    server: {
      host: '0.0.0.0',
      port: 3000,
      strictPort: true,
      hmr: {
        port: 3000,
      }
    }
  }),
  manifest: {
    action: {
      default_title: "AppName",
    },
    web_accessible_resources: [
      {
        matches: ["*://*.google.com/*"],
        resources: ["icon/*.png"],
      },
    ],
  },
});
```

## 3. 開発環境の起動 (Development Setup)

### イメージのビルド

以下のコマンドを実行して、開発用イメージをビルドします。

```bash
docker compose build
```

### コンテナの起動

以下のコマンドを実行して、開発用コンテナを起動します。

```bash
docker compose up
```

- 初回起動時は Docker イメージのビルドと依存ライブラリのインストールが行われるため、時間がかかる場合があります。
- `./app` ディレクトリがボリュームマウントされ、ホスト側でのコード変更がコンテナ内に即座に反映されます。

または、VSCode で `Dev Containers: Reopen in Container` を実行して、Dev Container を起動してください。

### アプリケーションの起動

以下のコマンドを実行して、開発用コンテナを起動します。

```bash
docker compose exec -it app bun run dev
```

Dev Container を起動している場合は、コンテナ上で以下のコマンドを実行してください。

```bash
bun run dev
```

### 動作確認

コンテナ起動後、Vite 開発サーバーが立ち上がります。

`chrome://extensions/` にアクセスして、デベロッパーモードを有効にし、「パッケージ化されていない拡張機能を読み込む」から、`<project_name>/app/.output/chrome-mv3-dev` ディレクトリを選択してください。


### ライブラリの追加

```bash
docker compose exec app bun add <ライブラリ名>
```

## 4. 開発フロー (Development Flow)

- **ホットリロード**: WXT は内部で Viteを採用しており、 `bun run dev` で起動している間、ファイルの変更を検知して自動的に再ビルドが行われます。
