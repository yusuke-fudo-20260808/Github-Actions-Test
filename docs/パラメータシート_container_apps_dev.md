# パラメータシート（Azure Container Apps）

## 1. Container Apps環境（Managed Environment）

| 項目 | 値 | 備考 |
|---|---|---|
| Envリソース名 | caenv-psynaps-dev |  |
| リージョン | Japan East |  |
| リソースグループ | rg-psynaps-dev |  |
| 環境タイプ | Workload profiles (v2) |  |
| ワークロードプロファイル |consumption |  |
| ワークロード上限 |  最大 4 vCPU / 8 GiB |  |
| パブリックネットワークアクセス | 無効 |
| VNet統合 | 有効 | |
| 専用サブネット |snet-ca-psynaps-dev |  |
| ゾーン冗長 | 無効 |  |
| アプリ | ca-dwfpdf-psynaps-dev |

## 2. プライベートエンドポイント

| 項目 | 値 | 備考 |
|---|---|---|
| リソース名 | pep-ca-psynaps-dev |  |
| プライベートIPアドレス |10.14.167.18 |  |
| サブネット | snet-ca-psynaps-dev |  |
| リージョン | Japan East | |
| Private DNS Zone | privatelink.japaneast.azurecontainerapps.io | 

## 3. Azure Container Apps

| 項目 | 開発 | 備考 |
|---|---|---|
| リージョン | Japan East |  |
| リソースグループ | rg-psynaps-dev |  |
| 認証方式（コンテナーアプリ） | マネージドID |  |
| ACR認証方式 | マネージドID |  |
| イングレス | 有効 |  |
| イングレストラフィック | どこからでもトラフィックを受け入れる |  |
| イングレスタイプ | HTTP |  |
| セキュリティで保護されていない接続 | 無効 |  |
| クライアント証明書モード | 無視 |  |
| ターゲットポート | 80 |
|エンドポイント | `https://ca-dwfpdf-psynaps-dev.graypond-758b242f.japaneast.azurecontainerapps.io` |
| セッションアフィニティ | 無効 |  |
| IP制限 | すべてのトラフィックを許可する |  |
| CPU | 1 vCPU |  |
| メモリ | 2 GiB |  |
| minReplicas | 0 |  |
| maxReplicas | 1 |  |
| イメージのソース | Azure Container Registry |  |
| レジストリ認証方式 | マネージドID |  |
| レジストリ | acrpsynapsdev.azurecr.io |  |

## 4. タグ

| 項目 | 値 |
|---|---|
| Env | Development |
| Owner | Power Systems Production |
| DataClassification | Confidential |
| CostCenter | Power Systems Production |
| System | PSYNAPS |
| Criticality | High |
