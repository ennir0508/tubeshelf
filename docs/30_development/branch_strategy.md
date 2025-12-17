# ブランチ運用ルール (Branch Strategy)

本プロジェクトでは、シンプルかつ継続的なインテグレーションを重視し、**GitHub Flow** をベースとしたブランチ運用を採用します。

## 1. ブランチ戦略 (GitHub Flow)

- **`main` ブランチ**: 常にデプロイ可能な状態を保つメインブランチです。直接のコミットは禁止し、必ずPull Request (PR) を介してマージします。
- **Feature ブランチ**: 新機能開発やバグ修正を行うための作業用ブランチです。`main` ブランチから派生し、作業完了後に `main` へマージします。

## 2. ブランチ命名規則

ブランチ名は、作業の種類と内容が一目でわかるように以下の形式で命名してください。

`[prefix]/[issue-id]-[description]`

- **Prefix**:
    - `feat`: 新機能の開発 (例: `feat/12-add-sidebar`)
    - `fix`: バグ修正 (例: `fix/15-login-error`)
    - `docs`: ドキュメントのみの変更 (例: `docs/20-update-readme`)
    - `refactor`: リファクタリング (例: `refactor/22-user-component`)
    - `test`: テスト関連 (例: `test/25-unit-test-setup`)
    - `chore`: その他ビルドツールや設定の変更 (例: `chore/28-bump-deps`)
- **Issue ID**: 課題管理ツール（GitHub Issues等）のチケット番号（任意ですが推奨）。
- **Description**: ケバブケース（ハイフン区切り）で簡潔な説明。

**例**:
- `feat/101-auth-page`
- `fix/button-layout`

## 3. コミットメッセージの形式

[Conventional Commits](https://www.conventionalcommits.org/) に準拠することを推奨します。

`[type]: [subject]`

- **Type**: ブランチのPrefixと同様 (`feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`)。
- **Subject**: 日本語推奨。変更内容を簡潔に記述。

**例**:
- `feat: ログイン機能の実装`
- `fix: ヘッダーのレイアウト崩れを修正`
- `docs: ブランチ運用ルールの追加`

## 4. Pull Request (PR) ルール

- **タイトル**: コミットメッセージと同様、変更内容がわかるように記述する。
- **説明**:
    - **変更の概要**: 何をしたか。
    - **関連Issue**: `Closes #123` のようにIssue番号をリンクする。
    - **確認方法**: どのように動作確認すればよいか。
- **レビュー**: 原則として1名以上のレビュアーの承認を得てからマージする。
- **マージ**: マージ後はFeatureブランチを削除する。

## 5. 生成AIとの協業について

AIエージェントによるコード生成やドキュメント作成のコミットも、上記のルールに従います。
AIが作成したPRであっても、人間の開発者がレビューと動作確認を行った上でマージしてください。
