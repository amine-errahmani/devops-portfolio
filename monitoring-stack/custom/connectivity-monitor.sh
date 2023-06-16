#!/bin/bash
log=connection.log
debuglog=debugConnection.log
status="OK"
while IFS=, read -r host port
do
    if [[ $host != "HOST" ]]; then
        date=$(date '+%d/%m/%Y %H:%M:%S')
        echo "Testing $host on $port" | tee -a $debuglog
        latencyline=`nping --tcp -p $port $host | tee -a $debuglog | grep 'Avg rtt:'`
        read -ra ADDR1 <<< $latencyline
        latency=${ADDR1[10]}
        if [[ $latency == "N/A" ]]; then
            status="ERROR"
        fi
        echo "time=$date status=$status target=$host port=$port averageMs=$latency" | tee -a $log
    fi
done < hosts.csv