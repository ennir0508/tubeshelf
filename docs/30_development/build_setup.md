# 環境構築・ビルド手順 (Build Setup)

本プロジェクトでは、開発環境の均一化とセットアップの簡略化のために Docker を利用しています。
Chrome 拡張機能としてのビルド手順も併せて説明します。

## 1. 前提条件 (Prerequisites)

- **Docker Desktop**: コンテナランタイムとして必要です。
- **VS Code** (推奨): エディタとして推奨します。
- **Dev Containers** (推奨): VS Code 拡張機能。コンテナ内での開発をスムーズに行うために推奨します。

## 2. プロジェクトの新規作成 (New Project Creation)

### プロジェクトディレクトリ 作成

### Vite プロジェクト作成

以下のコマンドを実行して、Vite プロジェクトを作成してください。

```bash
docker run --rm -v ${PWD}/app:/home/bun/app oven/bun bun create vite . --template react-ts   
```

### Dockerfile 作成

以下の内容を `Dockerfile` に保存してください。

```dockerfile
FROM oven/bun:1 AS base
WORKDIR /usr/src/app

RUN chown -R bun:bun /usr/src/app

USER bun

COPY --chown=bun:bun package.json bun.lock ./

RUN bun install

COPY --chown=bun:bun . .

EXPOSE 5173/tcp
ENTRYPOINT [ "bun", "run", "dev" ]
```

### docker-compose.yaml 作成

```yaml
services:
  app:
    build:
      context: ./app
      dockerfile: Dockerfile.dev
    ports:
      - "5173:5173"
    volumes:
      # ソースコードをホストと同期（ホットリロード用）
      - ./app:/usr/src/app
      # コンテナ内の node_modules をホストで上書きしないようにボリューム化
      - /usr/src/app/node_modules
    environment:
      - NODE_ENV=development
    tty: true
```

### package.json 修正

`package.json` の `scripts` セクションを以下のように修正してください。

```json
"scripts": {
    "dev": "bunx --bun vite --host",
    "build": "tsc -b && vite build",
    "lint": "eslint .",
    "preview": "vite preview"
}
```

## 3. 開発環境の起動 (Development Setup)

### コンテナの起動

以下のコマンドを実行して、開発用コンテナを起動します。

```bash
docker compose up
```

- 初回起動時は Docker イメージのビルドと依存ライブラリのインストールが行われるため、時間がかかる場合があります。
- `./app` ディレクトリがボリュームマウントされ、ホスト側でのコード変更がコンテナ内に即座に反映されます。

### 動作確認

コンテナ起動後、Vite 開発サーバーが立ち上がります。
ブラウザで `http://localhost:5173` にアクセスできるか確認してください。
（※Chrome 拡張機能特有の API を使用している部分は、通常のブラウザページでは動作しない場合があります）

## 4. 拡張機能のビルド (Build Extension)

Chrome に読み込ませるための製品ビルド（`dist` ディレクトリの生成）を行います。

### コンテナ内でビルドする場合（推奨）

```bash
docker compose exec app bun run build
```

### ローカル環境でビルドする場合

ローカルに `bun` がインストールされている場合は、以下のように直接ビルドすることも可能です。

```bash
cd app
bun install
bun run build
```

ビルドが完了すると、`app/dist` ディレクトリに成果物が出力されます。

### ライブラリの追加

```bash
docker compose exec app bun add <ライブラリ名>
```

## 5. Chrome への読み込み (Load in Chrome)

1. Chrome ブラウザを開き、アドレスバーに `chrome://extensions` と入力して移動します。
2. 画面右上の **「デベロッパーモード」 (Developer mode)** トグルを ON にします。
3. 左上の **「パッケージ化されていない拡張機能を読み込む」 (Load unpacked)** ボタンをクリックします。
4. 本プロジェクトの `extension/dist` ディレクトリを選択します。

これで拡張機能がインストールされます。

## 6. 開発フロー (Development Flow)

- **ホットリロード**: `docker compose up` で起動している間は、ファイルの変更を検知して自動的に再ビルドが行われます (HMR)。
- **拡張機能の更新**: ポップアップやオプションページの変更は HMR で反映されますが、`manifest.json` や `content script`、`background script` に変更を加えた場合は、`chrome://extensions` ページで**更新ボタン**（回転矢印アイコン）を押して拡張機能を再読み込みする必要があります。
