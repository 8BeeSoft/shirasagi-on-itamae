# shirasagi deploy on Itamae

プロビジョニングツールItamaeでshirasagiの動作する環境を
自動構築できます。
（一部、手動実行コマンドがあります）

### 対応OS
CentOS7

### 構築できる環境
Ruby 2.3.4
mongdb 3.4
nignx
unicorn

### 使い方

```
git clone https://github.com/8BeeSoft/shirasagi-on-itamae.git
bundle install --path vendor/bundle
```

bundle installが終了したら、shirasagiの動作環境を確認し、
適宜、ファイルを編集する。

VPSにSSHログインできる状態で、Itamaeを実行する。

```
bundle exec itamae ssh -h 【ホスト名】 -u root -j nodes/node.json recipe.rb -i 【鍵認証ファイル】
```

実行が終了後、ログインし下記コマンドを実行する

```
$  bundle install --without development test

$ rake db:drop
$ rake db:create_indexes
```

新規サイトの追加

```
$ rake ss:create_site data='{ name: "サイト名", host: "www", domains: "localhost:3000" }'
```

サンプルデータ (自治体サンプル) の投入

```
$ rake db:seed name=demo site=www
```

unicorn起動
```
$  rake unicorn:start
```

### 各ファイルについて
nodes/node.json

***versions***
rbenvにてインストールするRubyバージョン

***global***
rbenvにてグローバルで使用するRubyバージョン


### トラブルシューティング
#### サイトに繋がらない
インストールマニュアルを参照し、セキュリティ設定の項目を見直してください。
firewalldを切ると表示される場合があります。

### Thanks
[Itamae](https://github.com/itamae-kitchen/itamae)

[SHIRASAGI 開発マニュアル](http://shirasagi.github.io/)

[Itamae + rbenvでCentOSにRuby環境を構築](http://qiita.com/fukuiretu/items/337e6ae15c1f01e93ec3)
