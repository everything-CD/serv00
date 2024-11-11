#!/bin/bash

####### nezha #################
USER=$(whoami)
WORKDIR="/home/${USER,,}/nezhapanel"
SCRIPT="${WORKDIR}/start.sh"
CRON_SCRIPT="nohup ${SCRIPT} >/dev/null 2>&1 &"
#### nezha-agent #######################
WORKDIR2="/home/${USER,,}/.nezha-agent"
CRON_NEZHA="nohup ${WORKDIR2}/start.sh >/dev/null 2>&1 &"
################################################
echo "检查并添加 crontab 任务"

# 确认主脚本是否存在
if [ -e "${SCRIPT}" ]; then
    echo "添加 nezha 和 nezha-agent 的 crontab 重启任务"

    # 添加 Nezha Dashboard 的重启任务
    if ! crontab -l | grep -qF "@reboot pkill -f ${SCRIPT} || ${CRON_SCRIPT}"; then
        (crontab -l; echo "@reboot pkill -f ${SCRIPT} || ${CRON_SCRIPT}") | crontab -
    fi

    # 添加 Nezha Agent 的重启任务
    if ! crontab -l | grep -qF "@reboot pkill -kill -u $(whoami) && ${CRON_NEZHA}"; then
        (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_NEZHA}") | crontab -
    fi

    # 每12分钟检查 Nezha Agent 是否运行
    if ! crontab -l | grep -qF "*/12 * * * * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}"; then
        (crontab -l; echo "*/12 * * * * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") | crontab -
    fi

    # 每30分钟检查 Nezha Dashboard 是否运行
    if ! crontab -l | grep -qF "*/30 * * * * pgrep -f ${SCRIPT} > /dev/null || ${CRON_SCRIPT}"; then
        (crontab -l; echo "*/30 * * * * pgrep -f ${SCRIPT} > /dev/null || ${CRON_SCRIPT}") | crontab -
    fi

else
    echo "脚本 ${SCRIPT} 不存在，无法设置 crontab 任务"
fi
