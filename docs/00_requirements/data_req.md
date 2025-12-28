# データ要件定義書 (Data Requirements Definition)

## 1. データモデル

### 1.1. ユーザー (users)

ユーザー情報を管理するオブジェクト。

| フィールド名 | 型        | 説明                      |
|:-------------|:----------|:--------------------------|
| `id`         | uuid      | 一意の識別子 (UUIDなど)。 |
| `name`       | string    | ユーザー名。              |
| `email`      | email     | メールアドレス。          |
| `google_id`  | string    | Google アカウントのID。   |
| `status`     | string    | ステータス。              |
| `create_at`  | timestamp | 登録日時。                |
| `update_at`  | timestamp | 更新日時。                |

### 1.2. カテゴリ (categories)

カテゴリ情報を管理するオブジェクト。

| フィールド名  | 型      | 説明                                            |
|:--------------|:--------|:------------------------------------------------|
| `id`          | uuid    | 一意の識別子 (UUIDなど)。                       |
| `user_id`     | uuid    | ユーザーID。                                    |
| `name`        | string  | カテゴリ表示名。                                |
| `icon`        | string  | カテゴリアイコン名。Google Fonts から追加する。 |
| `parent_id`   | string  | 親カテゴリのID (ルートの場合は `null`)。        |
| `depth`       | number  | 深さ。最大 3                                    |
| `is_expanded` | boolean | UI上の展開/折りたたみ状態。                     |
| `order`       | number  | 表示順序を管理するための数値。                  |

### 1.3. チャンネル (channels)

YouTubeチャンネルのキャッシュ情報（API制限回避等のため必要な場合）。

| フィールド名 | 型     | 説明                     |
|:-------------|:-------|:-------------------------|
| `id`         | string | YouTubeチャンネルID。    |
| `title`      | string | チャンネル名。           |
| `thumbnail`  | string | アイコン画像のURL。      |
| `url`        | string | チャンネルページのURL。  |
| `access_at`  | date   | 直近でアクセスした日時。 |

### 1.4. カテゴリチャンネル (r_categories_channels)

| フィールド名  | 型     | 説明           |
|:--------------|:-------|:---------------|
| `user_id`     | uuid   | ユーザーID。   |
| `category_id` | uuid   | カテゴリID。   |
| `channel_id`  | string | チャンネルID。 |

### 1.5. 設定 (settings)

| フィールド名 | 型   | 説明                             |
|:-------------|:-----|:---------------------------------|
| `user_id`    | uuid | ユーザーID。                     |
| `settings`   | json | 設定情報をJSON形式文字列で保存。 |

## 2. データ保存と同期

### 2.1. Chrome Storage Schema

#### 2.1.1. カテゴリ (Categories)

カテゴリ情報を管理するオブジェクト。

| キー           | 型         | 説明                                            |
|:---------------|:-----------|:------------------------------------------------|
| `category`     | Category   | カテゴリ情報。                                  |
| └ `id`         | string     | 一意の識別子 (UUIDなど)。                       |
| └ `name`       | string     | カテゴリ表示名。                                |
| └ `icon`       | string     | カテゴリアイコン名。Google Fonts から追加する。 |
| └ `depth`      | number     | 深さ。最大 3。                                  |
| └ `isExpanded` | boolean    | UI上の展開/折りたたみ状態。                     |
| └ `order`      | number     | 表示順序を管理するための数値。                  |
| └ `channels`   | Channel[]  | このカテゴリに属するチャンネルのリスト。        |
| │└ `id`        | string     | YouTubeチャンネルID。                           |
| │└ `title`     | string     | チャンネル名。                                  |
| │└ `thumbnail` | string     | アイコン画像のURL。                             |
| │└ `url`       | string     | チャンネルページのURL。                         |
| │└ `access_at` | date       | 直近でアクセスした日時。                        |
| └ `categories` | Category[] | 子カテゴリのリスト。深さ 3 まで。               |

#### 2.1.2. 設定 (Settings)

設定情報を管理するオブジェクト。

| キー          | 型     | 説明                     |
|:--------------|:-------|:-------------------------|
| `settings`    | json   | チャンネル情報。         |
| └ `id`        | string | YouTubeチャンネルID。    |
| └ `title`     | string | チャンネル名。           |
| └ `thumbnail` | string | アイコン画像のURL。      |
| └ `url`       | string | チャンネルページのURL。  |
| └ `access_at` | date   | 直近でアクセスした日時。 |

### 2.2. Chrome Storage (Sync/Local) に保存するJSON構造の例。

```json
{
  "categories": [
    {
      "id": "cat_001",
      "name": "Game",
      "icon": "stadia_controller",
      "parentId": null,
      "depth": 1,
      "order": 1,
      "categories": [
        {
          "id": "cat_001_001",
          "name": "Game",
          "icon": "stadia_controller",
          "parentId": "cat_001",
          "depth": 2,
          "order": 1,
          "categories": {
            "cat_id": 
          }
          "channelIds": ["UC_abc123...", "UC_def456..."]
        },
        "cat_001_002": {
          "id": "cat_001_002",
          "name": "Game",
          "icon": "stadia_controller",
          "parentId": "cat_001",
          "depth": 2,
          "order": 2,
          "categories": {
            "cat_id": 
          }
          "channelIds": ["UC_abc123...", "UC_def456..."]
        },
      ]
      "channelIds": ["UC_abc123...", "UC_def456..."]
    },
    {
      "id": "cat_002",
      "name": "Tech",
      "icon": "code",
      "parentId": null,
      "depth": 1,
      "order": 2,
      "channelIds": []
    },
    {
      "id": "cat_003",
      "name": "Music",
      "icon": "music_note",
      "parentId": "cat_002",
      "depth": 1,
      "order": 1,
      "channelIds": ["UC_ghi789..."]
    }
  ],
  "settings": {
    "sidebarWidth": 250,
    "theme": "auto"
  }
}
```

### 2.3. 制約事項
- **Chrome Sync Storageの制限**:
    - 全体容量: 100KB (各アイテム8KB)。カテゴリ構造が肥大化する場合は `storage.local` の利用を検討するか、データ構造を圧縮する。
    - 書き込み頻度制限（1分間にMAX_WRITE_OPERATIONS_PER_MINUTEなど）に注意する。

### 2.4. データ永続化
- 変更が発生したタイミング（カテゴリ移動、名称変更など）で即時にStorageへ書き込む（オートセーブ）。
