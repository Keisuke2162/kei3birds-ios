# Kei3Birds iOS

日本の野鳥をポケモン図鑑のように記録・発見できるiOSアプリ。

## セットアップ

### 1. XcodeGen でプロジェクト生成

```bash
cd Kei3Birds
xcodegen generate
```

### 2. 接続情報の設定（必須・手動）

以下の2ファイルにあるプレースホルダーを実際の値に書き換える。

#### `AppTarget/DI/DependencyContainer.swift`

```swift
let supabaseURL = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
```

- `YOUR_PROJECT_ID.supabase.co` → Supabase ダッシュボード > Settings > API の **Project URL**
- `YOUR_SUPABASE_ANON_KEY` → 同画面の **Publishable Key**（`sb_publishable_xxx...`）

#### `Packages/Infra/Sources/Infra/Endpoint/BirdEndpoint.swift`

```swift
let apiBaseURL = URL(string: "https://kei3birds-api.railway.app")!
```

- Railway ダッシュボード > サービス > Settings > Networking で発行された公開URL

### 3. Xcode でプロジェクトを開いてビルド

```bash
open Kei3Birds.xcodeproj
```

SPM の依存解決（Supabase, GoogleSignIn）が自動で走る。

## アーキテクチャ

Clean Architecture + Multi-Module（SPM Local Packages）

```
Packages/
  Domain/    Entity + Repository Protocol（依存なし）
  UseCase/   ビジネスロジック（→ Domain）
  Infra/     API通信・Supabase認証・DTO（→ Domain + Supabase SDK）

AppTarget/
  DI/        DependencyContainer（依存の組み立て）
  ViewModels/ @Observable ViewModel
  Views/     SwiftUI 画面
  Utility/   EXIFHelper, ImagePickerView
```

## project.yml の運用

`.xcodeproj` は XcodeGen で `project.yml` から生成している。`project.yml` を変更したら必ず再生成すること。

```bash
cd Kei3Birds
xcodegen generate
```

Xcode 上でターゲット追加・SDK追加・ビルド設定変更をしても、`project.yml` を更新しないと次回の `xcodegen generate` で消える。
