#!/bin/bash

## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

cd /var/lib/ocarun

HELIDON_APP_NAME=$(ls *.jar | grep oci-mp)
pid=$(ps -fe | grep ${HELIDON_APP_NAME} | grep -v grep | awk '{print $2}')
if [ ! -z "$pid" ]; then
  echo "Stopping ${HELIDON_APP_NAME} with pid $pid"
fi
echo "Starting ${HELIDON_APP_NAME} from helidon-app.service"
sudo systemctl restart helidon-app.service

# Check if Helidon is ready in 60 seconds using the readiness healthcheck endpoint of the app.
TIMEOUT_SEC=60
start_time="$(date -u +%s)"
while true; do
curl -s http://localhost:8080/health/ready | grep -q '"status":"UP"'
if [ $? -eq 0 ]; then
  echo "Helidon app is now running with pid $(ps -fe | grep ${HELIDON_APP_NAME} | grep -v grep | awk '{print $2}')!"
  break
fi
current_time="$(date -u +%s)"
elapsed_seconds=$(($current_time-$start_time))
if [ $elapsed_seconds -gt $TIMEOUT_SEC ]; then
  echo "Error: Helidon app failed to run successfully. Printing the logs..."
  cat helidon-app.log
  exit 1
fi
  sleep 1
done
