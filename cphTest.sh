#!/bin/bash
echo "----------------------------------------"
echo "Initialising test environment-----------"
echo "----------------------------------------"
qmname="${MQ_QMGR_NAME:-PERF0}"
host="${MQ_QMGR_HOSTNAME:-localhost}"
port="${MQ_QMGR_PORT:-1420}"
channel="${MQ_QMGR_CHANNEL:-SYSTEM.DEF.SVRCONN}"
nonpersistent="${MQ_NON_PERSISTENT:-0}"

if [ "${nonpersistent}" -eq 1 ]; then
  echo "Running Non Persistent Messaging Tests"
  echo "Running Non Persistent Messaging Tests" > /home/mqperf/cph/results
else
  echo "Running Persistent Messaging Tests"
  echo "Running Persistent Messaging Tests" > /home/mqperf/cph/results
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

echo "----------------------------------------"
echo "Starting cph tests----------------------"
echo "----------------------------------------"
./cphresp.sh ${MQ_RESPONDER_THREADS} >> /home/mqperf/cph/output &
#Wait for responders to start
sleep 30
echo "CPH Test Results" >> /home/mqperf/cph/results
echo "2K" >> /home/mqperf/cph/results
export threads=1
echo "$threads thread " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=8
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=16
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=32
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=64
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=128
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=200
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
echo "" >> /home/mqperf/cph/results
echo "20K" >> /home/mqperf/cph/results
export threads=1
echo "$threads thread " >> /home/mqperf/cph/results
./cphreq.sh $threads 20480 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=8
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 20480 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=16
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 20480 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=32
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 20480 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=64
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 20480 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=128
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 20480 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=200
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 20480 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
echo "" >> /home/mqperf/cph/results
echo "200K" >> /home/mqperf/cph/results
export threads=1
echo "$threads thread " >> /home/mqperf/cph/results
./cphreq.sh $threads 204800 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=8
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 204800 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=16
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 204800 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=32
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 204800 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=64
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 204800 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=128
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 204800 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
export threads=200
echo "$threads threads " >> /home/mqperf/cph/results
./cphreq.sh $threads 204800 | tee -a /home/mqperf/cph/output | grep avgRate | awk -F ',' '{ print $3 }' >> /home/mqperf/cph/results
cat /home/mqperf/cph/results
echo "----------------------------------------"
echo "cph testing finished--------------------"
echo "----------------------------------------"
