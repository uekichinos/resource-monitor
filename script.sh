#!/bin/sh
TOKEN=XXXXXXX:XXXXXXXXXXXXXXXXXXXXXX
CHAT_ID=XXXXXXX
SERVER="SERVER_NAME"

MEMORY_LIMIT=25.00
CPU_LIMIT=25.00
HTTPD_LIMIT=60
DISK_LIMIT=60

MEMORY_TOTAL=$(free -m | awk 'NR==2{printf "%s", $2}')
MEMORY_USED=$(free -m | awk 'NR==3{printf "%s", $3}')
MEMORY_USAGE=$(awk -v total="$MEMORY_TOTAL" -v used="$MEMORY_USED" 'BEGIN {printf "%.2f", used*100/total}')
echo "Memory Usage: ${MEMORY_USAGE}%"

DISK_USEPERCENT=$(df -h | awk '$NF=="/usr"{printf "%s", $4}' | sed -e "s/%//g")
DISK_TOTAL=$(df -h | awk '$NF=="/usr"{printf "%d", $1}')
DISK_USED=$(df -h | awk '$NF=="/usr"{printf "%d", $2}')
echo "Disk Usage: ${DISK_USEPERCENT}%"

CPU_USAGE=$(mpstat | awk 'NR==4{printf "%s", 100-$12}')
echo "CPU Usage: ${CPU_USAGE}%"

HTTPD_USAGE=$(ps -ef | grep httpd | grep nobody | wc -l)
echo "HTTPD processes: ${HTTPD_USAGE}"

if [ 1 -eq "$(echo "${MEMORY_USAGE} >= ${MEMORY_LIMIT}" | bc)" ]; then
    MSG="[$SERVER] Memory usage ${MEMORY_USAGE}% exceed limit ${MEMORY_LIMIT}";
    URL="https://api.telegram.org/bot$TOKEN/sendMessage"
    curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MSG"
fi
if [ 1 -eq "$(echo "${CPU_USAGE} >= ${CPU_LIMIT}" | bc)" ]; then
    MSG="[$SERVER] CPU usage ${CPU_USAGE}% exceed limit ${CPU_LIMIT}";
    URL="https://api.telegram.org/bot$TOKEN/sendMessage"
    curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MSG"
fi
if [ 1 -eq "$(echo "${HTTPD_USAGE} >= ${HTTPD_LIMIT}" | bc)" ]; then
    MSG="[$SERVER] HTTPD process ${HTTPD_USAGE} exceed limit ${HTTPD_LIMIT}";
    URL="https://api.telegram.org/bot$TOKEN/sendMessage"
    curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MSG"
fi
if [ 1 -eq "$(echo "${DISK_USEPERCENT} >= ${DISK_LIMIT}" | bc)" ]; then
    MSG="[$SERVER] Disk usage(/usr): ${DISK_USEPERCENT}% exceed limit ${DISK_LIMIT}";
    URL="https://api.telegram.org/bot$TOKEN/sendMessage"
    curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MSG"
fi