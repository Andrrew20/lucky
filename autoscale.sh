#!bin/bash
TARGET_CPU=${TARGET_CPU:-30}
SERVICE_NAME=${SERVICE_NAME:-webapp_webapp}
MIN_INSTANCES=1
MAX_INSTANCES=2
COOLDOWN=120

while true; do
  CPU=$(docker stats --no-stream --format "{{.CPUPerc}}" $(docker ps -q --filter name=$SERVICE_NAME) | sed 's/%//')
  CURRENT_REPLICAS=$(docker-compose ps -q webapp | wc -l)
  
  # Сравнение через awk
  if (( $(awk -v cpu="$CPU" -v target="$TARGET_CPU" 'BEGIN {print (cpu > target)}') )); then
    if [ $CURRENT_REPLICAS -lt $MAX_INSTANCES ]; then
      echo "CPU ${CPU}% > ${TARGET_CPU}%. Scaling up to $((CURRENT_REPLICAS + 1))"
      docker-compose up-d --scale webapp=$((CURRENT_REPLICAS + 1)) --no-recreate sleep 
     $COOLDOWN
    fi
  else
    if [ $CURRENT_REPLICAS -gt $MIN_INSTANCES ]; then
      echo "CPU ${CPU}% < ${TARGET_CPU}%. Scaling down to $((CURRENT_REPLICAS - 1))"
      docker-compose up-d --scale webapp=$((CURRENT_REPLICAS - 1)) --no-recreate
      sleep $COOLDOWN
    fi
  fi
  sleep 10
done