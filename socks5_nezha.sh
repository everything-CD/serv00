#!/bin/bash

USER=$(whoami)
WORKDIR="/home/${USER,,}/nezhapanel"
SCRIPT="${WORKDIR}/dashboard"
CRON_SCRIPT="nohup ${SCRIPT} >/dev/null 2>&1 &"

echo "检查并添加 crontab 任务"

if [ -e "${SCRIPT}" ]; then
    echo "添加 nezha 的 crontab 重启任务"

    (crontab -l | grep -F "@reboot pkill -f ${SCRIPT} || ${CRON_SCRIPT}") || \
    (crontab -l; echo "@reboot pkill -f ${SCRIPT} || ${CRON_SCRIPT}") | crontab -

    (crontab -l | grep -F "* * pgrep -f ${SCRIPT} > /dev/null || ${CRON_SCRIPT}") || \
    (crontab -l; echo "*/12 * * * * pgrep -f ${SCRIPT} > /dev/null || ${CRON_SCRIPT}") | crontab -
else
    echo "脚本 ${SCRIPT} 不存在，无法设置 crontab 任务"
fi
