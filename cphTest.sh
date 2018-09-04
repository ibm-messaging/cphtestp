#!/bin/bash

#Functions
function runclients {
  threads=$1
  msgsize=$2
  echo "threads=$threads" >> /home/mqperf/cph/results
  echo "Starting test with $threads requesters" >> /home/mqperf/cph/output
  rate=$(./cphreq.sh $threads $msgsize | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }') 
  rate=$(echo $rate | awk -F '=' '{print $2}')
  echo "avgRate=$rate" >> /home/mqperf/cph/results

  cpu=$(awk '{print $12}' /tmp/mpstat | tail -6 |  awk '{total+=$1} END{printf "%0.2f",(NR?100-(total/NR):-1)}') 
  echo "CPU=$cpu" >> /home/mqperf/cph/results

  readMB=$(awk -F ',' '{print $7}' /tmp/dstat | tail -n +8 | tail -6 |  awk '{total+=$1} END{printf "%0.2f",(NR?((total/NR)/(1024*1024)):-1)}')
  echo "Read=$readMB" >> /home/mqperf/cph/results

  writeMB=$(awk -F ',' '{print $8}' /tmp/dstat | tail -n +8 | tail -6 |  awk '{total+=$1} END{printf "%0.2f",(NR?((total/NR)/(1024*1024)):-1)}')
  echo "Write=$writeMB" >> /home/mqperf/cph/results

  recvGbs=$(awk -F ',' '{print $9}' /tmp/dstat | tail -n +8 | tail -6 |  awk '{total+=$1} END{printf "%0.2f",(NR?((total/NR)/(1024*1024*1024*0.125)):-1)}')
  echo "Recv=$recvGbs" >> /home/mqperf/cph/results

  sendGbs=$(awk -F ',' '{print $10}' /tmp/dstat | tail -n +8 | tail -6 |  awk '{total+=$1} END{printf "%0.2f",(NR?((total/NR)/(1024*1024*1024*0.125)):-1)}')
  echo "Send=$sendGbs" >> /home/mqperf/cph/results

  qmcpu=$(tail -6 /tmp/systemerr | awk -F '=' '{print $2}' | awk '{total+=$1} END{printf "%0.2f",(NR?(total/NR):-1)}')
  echo "QM_CPU=$qmcpu" >> /home/mqperf/cph/results

  echo "" >> /home/mqperf/cph/results

  if [ -n "${MQ_RESULTS_CSV}" ]; then
    msgsize=${msgsize:-2048}
    echo "$persistent,$msgsize,$threads,$rate,$cpu,$readMB,$writeMB,$recvGbs,$sendGbs,$qmcpu" >> /home/mqperf/cph/results.csv
  fi
}



echo "----------------------------------------"
echo "Initialising test environment-----------"
echo "----------------------------------------"
qmname="${MQ_QMGR_NAME:-PERF0}"
host="${MQ_QMGR_HOSTNAME:-localhost}"
port="${MQ_QMGR_PORT:-1420}"
channel="${MQ_QMGR_CHANNEL:-SYSTEM.DEF.SVRCONN}"
msgsize=${msgsize:-2048}
nonpersistent="${MQ_NON_PERSISTENT:-0}"
if [ $nonpersistent eq 0 ]; then
  persistent=1
else
  persistent=0
fi
 

echo $(date)
echo $(date) > /home/mqperf/cph/results

if [ "${nonpersistent}" -eq 1 ]; then
  echo "Running Non Persistent Messaging Tests"
  echo "Running Non Persistent Messaging Tests" >> /home/mqperf/cph/results
else
  echo "Running Persistent Messaging Tests"
  echo "Running Persistent Messaging Tests" >> /home/mqperf/cph/results
fi
echo "----------------------------------------"

echo "Testing QM: $qmname on host: $host using port: $port and channel: $channel" 
echo "Testing QM: $qmname on host: $host using port: $port and channel: $channel" >> /home/mqperf/cph/results

if [ -n "${MQ_CPH_EXTRA}" ]; then
  echo "Extra CPH flags: ${MQ_CPH_EXTRA}" 
  echo "Extra CPH flags: ${MQ_CPH_EXTRA}" >> /home/mqperf/cph/results
fi

export MQSERVER="$channel/TCP/$host($port)";
if [ -n "${MQ_USERID}" ]; then
  # Need to flow userid and password to runmqsc
  echo "Using userid: ${MQ_USERID}" 
  echo "Using userid: ${MQ_USERID}" >> /home/mqperf/cph/results
  echo ${MQ_PASSWORD} > /tmp/clearq.mqsc;
  cat /home/mqperf/cph/clearq.mqsc >> /tmp/clearq.mqsc;  
  cat /tmp/clearq.mqsc | /opt/mqm/bin/runmqsc -c -u ${MQ_USERID} -w 60 $qmname > /home/mqperf/cph/output;
  rm -f /tmp/clearq.mqsc;
else
  cat /home/mqperf/cph/clearq.mqsc | /opt/mqm/bin/runmqsc -c $qmname > /home/mqperf/cph/output 2>&1;
fi

#Launch monitoring processes
mpstat 10 > /tmp/mpstat &
dstat --output /tmp/dstat 10 > /dev/null 2>&1 &
if [ -n "${MQ_USERID}" ]; then
  ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c CPU -t SystemSummary -u ${MQ_USERID} -v ${MQ_PASSWORD} >/tmp/system 2>/tmp/systemerr &
  ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c DISK -t Log -u ${MQ_USERID} -v ${MQ_PASSWORD} >/tmp/disklog 2>/tmp/disklogerr &
else
  ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c CPU -t SystemSummary >/tmp/system 2>/tmp/systemerr &
  ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c DISK -t Log >/tmp/disklog 2>/tmp/disklogerr &
fi

#Write CSV header if required
if [ -n "${MQ_RESULTS_CSV}" ]; then
  msgsize=${msgsize:-2048}
  echo $(date) > /home/mqperf/cph/results.csv
  echo "# Persistence, Msg Size, Threads, Rate (RT/s), Client CPU, IO Read (MB/s), IO Write (MB/s), Net Recv (Gb/s), Net Send (Gb/s), QM CPU" >> /home/mqperf/cph/results.csv
fi


echo "----------------------------------------"
echo "Starting cph tests----------------------"
echo "----------------------------------------"
./cphresp.sh ${MQ_RESPONDER_THREADS} >> /home/mqperf/cph/output &
#Wait for responders to start
sleep 30
echo "CPH Test Results" >> /home/mqperf/cph/results
echo $(date) >> /home/mqperf/cph/results
echo "2K" >> /home/mqperf/cph/results
runclients 1
runclients 8
runclients 16
runclients 32
runclients 64
runclients 128
runclients 200
echo "----" >> /home/mqperf/cph/results
echo $(date) >> /home/mqperf/cph/results
echo "20K" >> /home/mqperf/cph/results
runclients 1 20480
runclients 8 20480
runclients 16 20480
runclients 32 20480
runclients 64 20480
runclients 128 20480
runclients 200 20480
echo "----" >> /home/mqperf/cph/results
echo $(date) >> /home/mqperf/cph/results
echo "200K" >> /home/mqperf/cph/results
runclients 1 204800
runclients 8 204800
runclients 16 204800
runclients 32 204800
runclients 64 204800
runclients 128 204800
runclients 200 204800
echo "" >> /home/mqperf/cph/results

if ! [ ${MQ_RESULTS} == "FALSE" ]; then
  cat /home/mqperf/cph/results
fi

if [ -n "${MQ_RESULTS_CSV}" ]; then
  cat /home/mqperf/cph/results.csv
fi

if [ -n "${MQ_DATA}" ]; then
  cat /tmp/system
  cat /tmp/disklog
  cat /home/mqperf/cph/output
fi

echo "----------------------------------------"
echo "cph testing finished--------------------"
echo "----------------------------------------"
