#!/bin/bash

SCRIPT_DIR=$(cd `dirname $0`; pwd)

EXEC_NAME=$(basename $0 .sh)
EXEC_DATE=$(date "+%Y%m%d_%H%M%S")

TOOL_DIR=/opt/filebeat_support
BIN_DIR=${TOOL_DIR}/bin
DATA_DIR=${TOOL_DIR}/data
LOG_DIR=${TOOL_DIR}/logs
LOG_FILE=${LOG_DIR}/${EXEC_DATE}_${EXEC_NAME}.log

logger () {
    message=$1
    log_file=$2
    echo "[$(date +'%F %T')] ${message}" 2>&1 | tee -a ${log_file}
}

mkdir -p ${LOG_DIR}


START_TIME=`date '+%s'`
logger "Kibanaのセットアップ処理を開始します。" ${LOG_FILE}
logger "  接続先：${KIBANA_HOST}:${KIBANA_PORT}" ${LOG_FILE}

logger "Kibana起動状態チェック開始" ${LOG_FILE}
while true; do
    elastic_status=$(curl --noproxy ${KIBANA_HOST} -s -X GET http://${KIBANA_HOST}:${KIBANA_PORT}/status -I  | grep "200" | wc -l )
    # 正常に起動した場合にチェック処理を終了
    if [ ${elastic_status} -eq 1 ]; then
        break
    fi
    logger "Waiting for kibana..." ${LOG_FILE}
    sleep 10s
done
sleep 30s
logger "Kibana起動状態チェック終了" ${LOG_FILE}

logger "Kibanaの各種定義の投入開始" ${LOG_FILE}
curl --noproxy kibana ${KIBANA_HOST}:${KIBANA_PORT}/api/saved_objects/_import -H "kbn-xsrf: true" \
     --form file=@${DATA_DIR}/nginx-dashboard.ndjson 2>&1 | tee -a ${LOG_FILE}
echo "" | tee -a  ${LOG_FILE}
logger "Kibanaの各種定義の投入終了" ${LOG_FILE}

END_TIME=`date '+%s'`
PROCESSING_TIME=$((END_TIME - START_TIME))
logger "Kibanaのセットアップ処理を終了します。(${PROCESSING_TIME}秒)" ${LOG_FILE}
