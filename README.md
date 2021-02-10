# nginx-log-monitor
## 概要
nginxが出力するログファイル（access.log, error.log）を収集し、Elasticsearch＋Kibanaで可視化するためのコンテナ群を提供します。

次に示す４つのコンテナを、docker-composeで一括起動・停止します。

1. filebeat_logcollect
   - nginxのログを収集し、Elasticsearchに投入するFilebeat
1. filebeat_support
   - 投入したログを可視化するためのindex patternやダッシュボードの定義をKibanaに投入する（投入完了後、コンテナは終了します）
1. elasticsearch_logcollect
   - Filebeatから受信したログ情報を蓄積するElasticsearch
1. kibana_logcollect
   - Elasticsearchに蓄積されているログ情報を可視化するKibana

## 利用手順
### 前提条件
1. docker および docker-compose が使用できること
1. nginx のログファイルが、docker のホスト側（コンテナの外）に出力されていること（後述のfilebeatコンテナから参照できること）

### 事前準備
1. このディレクトリ配下を、nginxログが出力されているサーバに配置する
1. 各種ログ出力先ディレクトリを作成する
   ```
   # cd (配置先ディレクトリ)
   # mkdir -p kibana_logcollect/logs
   # chmod 777 kibana_logcollect/logs
   # mkdir -p es_logcollect/logs
   # chmod 777 es_logcollect/logs
   # mkdir -p es_logcollect/data
   # chmod 777 es_logcollect/data
   # mkdir -p filebeat_support/logs
   # chmod 777 filebeat_support/logs
   ```
1. docker-compose_logcollect.yml をテキストエディタで開き、nginxログ出力ディレクトリのパスを設定する
   - 75行目から抜粋 - 以下の `/path/to/nginx/logs` 部分を書き換えて保存する
      ```
       volumes:
         - ./filebeat_logcollect/conf/filebeat.yml:/usr/share/filebeat/filebeat.yml
         - /path/to/nginx/logs:/data/nginx/logs
      ```

### 実行／停止
※docker-compose_logcollect.ymlがあるディレクトリに移動して行ってください。

#### logcollect用コンテナを起動
```
# docker-compose -f docker-compose_logcollect.yml up -d
```
#### logcollect用コンテナの停止／削除
※Elasticseachのデータ、および出力されているログは消えません。
```
# docker-compose -f docker-compose_logcollect.yml down
```
#### logcollect用コンテナの再起動
```
# docker-compose -f docker-compose_logcollect.yml restart
```
#### logcollect用コンテナの再起動（特定のコンテナのみ）
`restart`の後ろにコンテナ名を与えると、特定のコンテナのみ再起動できます

例：filebeatコンテナのみ再起動する場合
```
# docker-compose -f docker-compose_logcollect.yml restart filebeat_logcollect
```

## 注意事項
### ダッシュボード定義の入れ替えをする場合
既存のダッシュボード定義（Index Pattern含む）が投入済みの場合、再投入する前に削除してください。
削除は、Kibanaの画面から行ってください。

## 参考情報
- filebeatのログディレクトリ
  - <配置先ディレクトリ>/filebeat_logcollect/logs
- filebeat_supportのログディレクトリ
  - <配置先ディレクトリ>/filebeat_support/logs
