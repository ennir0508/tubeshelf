# データ要件定義書 (Data Requirements Definition)

## 1. データモデル

### 1.1. カテゴリ (Category)
カテゴリ情報を管理するオブジェクト。

| フィールド名 | 型      | 説明                                       |
| :----------- | :------ | :----------------------------------------- |
| `id`         | string  | 一意の識別子 (UUIDなど)。                  |
| `name`       | string  | カテゴリ表示名。                           |
| `parentId`   | string  | 親カテゴリのID (ルートの場合は `null`)。   |
| `isExpanded` | boolean | UI上の展開/折りたたみ状態。                |
| `order`      | number  | 表示順序を管理するための数値。             |
| `channelIds` | array   | このカテゴリに属するチャンネルIDのリスト。 |

### 1.2. チャンネル (Channel)
YouTubeチャンネルのキャッシュ情報（API制限回避等のため必要な場合）。

| フィールド名 | 型     | 説明                                   |
| :----------- | :----- | :------------------------------------- |
| `id`         | string | YouTubeチャンネルID (例: UCxxxxxxxx)。 |
| `title`      | string | チャンネル名。                         |
| `thumbnail`  | string | アイコン画像のURL。                    |
| `url`        | string | チャンネルページのURL。                |

## 2. データ保存と同期

### 2.1. Chrome Storage Schema
Chrome Storage (Sync/Local) に保存するJSON構造の例。

```json
{
  "categories": {
    "cat_001": {
      "id": "cat_001",
      "name": "Game",
      "parentId": null,
      "order": 1,
      "channelIds": ["UC_abc123...", "UC_def456..."]
    },
    "cat_002": {
      "id": "cat_002",
      "name": "Tech",
      "parentId": null,
      "order": 2,
      "channelIds": []
    },
    "cat_003": {
      "id": "cat_003",
      "name": "Gadgets",
      "parentId": "cat_002",
      "order": 1,
      "channelIds": ["UC_ghi789..."]
    }
  },
  "uncategorized": ["UC_jkl012...", "UC_mno345..."],
  "settings": {
    "sidebarWidth": 250,
    "theme": "auto"
  }
}
```

### 2.2. 制約事項
- **Chrome Sync Storageの制限**:
    - 全体容量: 100KB (各アイテム8KB)。カテゴリ構造が肥大化する場合は `storage.local` の利用を検討するか、データ構造を圧縮する。
    - 書き込み頻度制限（1分間にMAX_WRITE_OPERATIONS_PER_MINUTEなど）に注意する。

### 2.3. データ永続化
- 変更が発生したタイミング（カテゴリ移動、名称変更など）で即時にStorageへ書き込む（オートセーブ）。
