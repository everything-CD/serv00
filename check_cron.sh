#!/bin/bash

USER=$(whoami)
WORKDIR="/home/${USER,,}/.nezha-agent"
FILE_PATH="/home/${USER,,}/.s5"
CRON_S5="nohup ${FILE_PATH}/s5 -c ${FILE_PATH}/config.json >/dev/null 2>&1 &"
CRON_NEZHA="nohup ${WORKDIR}/start.sh >/dev/null 2>&1 &"

echo "检查并添加 crontab 任务"

if [ -e "${WORKDIR}/start.sh" ] && [ -e "${FILE_PATH}/config.json" ]; then
  echo "添加 nezha & socks5 的 crontab 重启任务"
  (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_S5} ${CRON_NEZHA}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_S5} ${CRON_NEZHA}") | crontab -
  (crontab -l | grep -F "*/12 * * * * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") || (crontab -l; echo "*/12 * * * * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") | crontab -
  (crontab -l | grep -F "*/12 * * * * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") || (crontab -l; echo "*/12 * * * * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") | crontab -
elif [ -e "${WORKDIR}/start.sh" ]; then
  echo "添加 nezha 的 crontab 重启任务"
  (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_NEZHA}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_NEZHA}") | crontab -
  (crontab -l | grep -F "*/12 * * * * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") || (crontab -l; echo "*/12 * * * * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") | crontab -
elif [ -e "${FILE_PATH}/config.json" ]; then
  echo "添加 socks5 的 crontab 重启任务"
  (crontab -l | grep -F "@reboot pkill -kill -u $(whoami) && ${CRON_S5}") || (crontab -l; echo "@reboot pkill -kill -u $(whoami) && ${CRON_S5}") | crontab -
  (crontab -l | grep -F "*/12 * * * * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") || (crontab -l; echo "*/12 * * * * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") | crontab -
fi
