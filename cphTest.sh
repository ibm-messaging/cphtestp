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

  readMB=$(awk -F ',' '{print $6}' /tmp/dstat | tail -n +8 | tail -6 |  awk '{total+=$1} END{printf "%0.2f",(NR?((total/NR)/(1024*1024)):-1)}')
  echo "Read=$readMB" >> /home/mqperf/cph/results

  writeMB=$(awk -F ',' '{print $7}' /tmp/dstat | tail -n +8 | tail -6 |  awk '{total+=$1} END{printf "%0.2f",(NR?((total/NR)/(1024*1024)):-1)}')
  echo "Write=$writeMB" >> /home/mqperf/cph/results

  recvGbs=$(awk -F ',' '{print $8}' /tmp/dstat | tail -n +8 | tail -6 |  awk '{total+=$1} END{printf "%0.2f",(NR?((total/NR)/(1024*1024*1024*0.125)):-1)}')
  echo "Recv=$recvGbs" >> /home/mqperf/cph/results

  sendGbs=$(awk -F ',' '{print $9}' /tmp/dstat | tail -n +8 | tail -6 |  awk '{total+=$1} END{printf "%0.2f",(NR?((total/NR)/(1024*1024*1024*0.125)):-1)}')
  echo "Send=$sendGbs" >> /home/mqperf/cph/results

  qmcpu=$(tail -6 /tmp/systemerr | awk -F '=' '{print $2}' | awk '{total+=$1} END{printf "%0.2f",(NR?(total/NR):-1)}')
  echo "QM_CPU=$qmcpu" >> /home/mqperf/cph/results

  echo "" >> /home/mqperf/cph/results

  if [ -n "${MQ_RESULTS_CSV}" ]; then
    echo "$persistent,$msgsize,$threads,$rate,$cpu,$readMB,$writeMB,$recvGbs,$sendGbs,$qmcpu" >> /home/mqperf/cph/results.csv
  fi
}

function getConcurrentClientsArray {
  if  ! [ -z "${MQ_FIXED_CLIENTS}" ]; then
    clientsArray=(${MQ_FIXED_CLIENTS})
  else
    maximumClients=$1
    #maximumClients=`expr ${maximumClients} - 2`
    for (( i=1; i<$maximumClients; i=$i*2 ))
    do
      clientsArray+=($i)
    done
    clientsArray+=($maximumClients)
  fi
}

function setupTLS {
  #Assuming that key.kdb is already present in the default location /opt/mqm/ssl/key.kdb
  #Assuming currently that kdb is CMS - Not tested yet with PKCS12

  #Override mqclient.ini with SSL Key repository location and reuse count
  cp /opt/mqm/ssl/mqclient.ini /var/mqm/mqclient.ini
  
  if [[ -n "${MQ_TLS_SNI_HOSTNAME}" ]]; then
    echo "  OutboundSNI=HOSTNAME" >> /var/mqm/mqclient.ini
  fi

  #Create local CCDT; alternatives are to copy it from Server or host it at http location
  echo "DEFINE CHANNEL('$channel') CHLTYPE(CLNTCONN) CONNAME('$host($port)') SSLCIPH(${MQ_TLS_CIPHER}) QMNAME('$qmname') CERTLABL('${MQ_TLS_CERTLABEL}') REPLACE" | /opt/mqm/bin/runmqsc -n > /home/mqperf/cph/output 2>&1

  #Add certificate label to the mqclient.ini if we are flowing a client cert; adding it the local channel definition above will work in most cases if no CD is flowed from the application
  #Support added to cph for specifying certlabel with -jw parm  
  #echo "  CertificateLabel=${MQ_TLS_CERTLABEL}" >> /var/mqm/mqclient.ini
}

echo "----------------------------------------"
echo "Initialising test environment-----------"
echo "----------------------------------------"
qmname="${MQ_QMGR_NAME:-PERF0}"
host="${MQ_QMGR_HOSTNAME:-localhost}"
port="${MQ_QMGR_PORT:-1420}"
channel="${MQ_QMGR_CHANNEL:-SYSTEM.DEF.SVRCONN}"
msgsizestring="${MQ_MSGSIZE:-2048:20480:204800}"
nonpersistent="${MQ_NON_PERSISTENT:-0}"
responders="${MQ_RESPONDER_THREADS:-200}"
reconnect="${MQ_AUTORECONNECT:-MQCNO_RECONNECT_DISABLED}"

if [ "${nonpersistent}" = "1" ]; then
  persistent=0
else
  persistent=1
fi

#Write results header
echo $(date) | tee /home/mqperf/cph/results

if [ "${nonpersistent}" -eq 1 ]; then
  echo "Running Non Persistent Messaging Tests" | tee -a /home/mqperf/cph/results
else
  echo "Running Persistent Messaging Tests" | tee -a /home/mqperf/cph/results
fi
echo "----------------------------------------"

echo "Testing QM: $qmname on host: $host using port: $port and channel: $channel" | tee -a /home/mqperf/cph/results
echo "Clients using auto reconnect option: $reconnect" | tee -a /home/mqperf/cph/results

echo "Using the following message sizes:" | tee -a /home/mqperf/cph/results
for messageSize in ${msgsizestring}; do
  echo "$messageSize" | tee -a /home/mqperf/cph/results 
done

#Temp check to kill pod if same IP address assigned to test harness than that used for QM
#OCP/multus doesnt track issued IPs in 4.2
if [ -n "${MQ_IP_CHECK}" ]; then
  ipclash=`ip a | grep ${MQ_QMGR_HOSTNAME} | awk '{print $2}'`
  if [ -n "${ipclash}" ]; then
    echo "IP Assigned to QM is the same as assigned to test harness: $ipclash" 
    exit
  fi
fi

if [ -n "${MQ_CPH_EXTRA}" ]; then
  echo "Extra CPH flags: ${MQ_CPH_EXTRA}" | tee -a /home/mqperf/cph/results
fi

if [ -n "${MQ_TLS_CIPHER}" ]; then
  echo "TLS Cipher: ${MQ_TLS_CIPHER}" | tee -a /home/mqperf/cph/results
  # Need to complete TLS setup before we try to attach monitors
  setupTLS
fi

#Clear queues
if [ -n "${MQ_TLS_CIPHER}" ]; then
  #Dont configure MQSERVER envvar for TLS scenarios, will use CCDT
  #We do need to specify the Key repository location as runmqsc doesnt use mqclient.ini
  export MQSSLKEYR=/opt/mqm/ssl/key
else
  #Configure MQSERVER envvar
  export MQSERVER="$channel/TCP/$host($port)"
fi

#Only avoid clearing queues if parm is defined and set to N
if ! ( [ -n "{MQ_CLEAR_QUEUES}" ] && [ "${MQ_CLEAR_QUEUES}" = "N" ] ); then
  if [ -n "${MQ_USERID}" ]; then
    # Need to flow userid and password to runmqsc
    echo "Using userid: ${MQ_USERID}" | tee -a /home/mqperf/cph/results
    echo ${MQ_PASSWORD} > /tmp/clearq.mqsc
    cat /home/mqperf/cph/clearq.mqsc >> /tmp/clearq.mqsc  
    cat /tmp/clearq.mqsc | /opt/mqm/bin/runmqsc -c -u ${MQ_USERID} -w 60 $qmname > /home/mqperf/cph/output 2>&1
    rm -f /tmp/clearq.mqsc
  else
    cat /home/mqperf/cph/clearq.mqsc | /opt/mqm/bin/runmqsc -c $qmname > /home/mqperf/cph/output 2>&1
  fi
fi

#Launch monitoring processes
mpstat 10 > /tmp/mpstat &
dstat --output /tmp/dstat 10 > /dev/null 2>&1 &
if [ -n "${MQ_USERID}" ]; then
  if [ -n "${MQ_TLS_CIPHER}" ]; then
    ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c CPU -t SystemSummary -u ${MQ_USERID} -v ${MQ_PASSWORD} -l ${MQ_TLS_CIPHER} -w ${MQ_TLS_CERTLABEL} >/tmp/system 2>/tmp/systemerr &
    ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c DISK -t Log -u ${MQ_USERID} -v ${MQ_PASSWORD} -l ${MQ_TLS_CIPHER} -w ${MQ_TLS_CERTLABEL} >/tmp/disklog 2>/tmp/disklogerr &
    ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c NHAREPLICA -t REPLICATION -o + -u ${MQ_USERID} -v ${MQ_PASSWORD} -l ${MQ_TLS_CIPHER} -w ${MQ_TLS_CERTLABEL} >/tmp/nhalog 2>/tmp/nhalogerr &
  else
    ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c CPU -t SystemSummary -u ${MQ_USERID} -v ${MQ_PASSWORD} >/tmp/system 2>/tmp/systemerr &
    ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c DISK -t Log -u ${MQ_USERID} -v ${MQ_PASSWORD} >/tmp/disklog 2>/tmp/disklogerr &
    ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c NHAREPLICA -t REPLICATION -o + -u ${MQ_USERID} -v ${MQ_PASSWORD} >/tmp/nhalog 2>/tmp/nhalogerr &
  fi
else
  if [ -n "${MQ_TLS_CIPHER}" ]; then
    ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c CPU -t SystemSummary -l ${MQ_TLS_CIPHER} -w ${MQ_TLS_CERTLABEL} >/tmp/system 2>/tmp/systemerr &
    ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c DISK -t Log -l ${MQ_TLS_CIPHER} -w ${MQ_TLS_CERTLABEL} >/tmp/disklog 2>/tmp/disklogerr &
    ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c NHAREPLICA -t REPLICATION -o + -l ${MQ_TLS_CIPHER} -w ${MQ_TLS_CERTLABEL} >/tmp/nhalog 2>/tmp/nhalogerr &
  else
    ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c CPU -t SystemSummary >/tmp/system 2>/tmp/systemerr &
    ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c DISK -t Log >/tmp/disklog 2>/tmp/disklogerr &
    ./qmmonitor2 -m $qmname -p $port -s $channel -h $host -c NHAREPLICA -t REPLICATION -o + >/tmp/nhalog 2>/tmp/nhalogerr &
  fi
fi

#Write CSV header if required
if [ -n "${MQ_RESULTS_CSV}" ]; then
  echo "# CSV Results" > /home/mqperf/cph/results.csv
  echo "# TLS Cipher: ${MQ_TLS_CIPHER}" >> /home/mqperf/cph/results.csv
  printf "# " >> /home/mqperf/cph/results.csv
  echo $(date) >> /home/mqperf/cph/results.csv
  echo "# Persistence, Msg Size, Threads, Rate (RT/s), Client CPU, IO Read (MB/s), IO Write (MB/s), Net Recv (Gb/s), Net Send (Gb/s), QM CPU" >> /home/mqperf/cph/results.csv
fi


echo "----------------------------------------"
echo "Starting cph tests----------------------"
echo "----------------------------------------"
./cphresp.sh ${responders} >> /home/mqperf/cph/output & disown
#Wait for responders to start
sleep 30
#Determine sequence of requester clients to use based of number of responder clients
getConcurrentClientsArray ${responders}
echo "Using the following progression of concurrent connections: ${clientsArray[@]}" | tee -a /home/mqperf/cph/results
echo "Using ${responders} responder threads" | tee -a /home/mqperf/cph/results

IFS=:
echo "CPH Test Results" >> /home/mqperf/cph/results
for messageSize in ${msgsizestring}; do
  unset IFS
  echo $(date) >> /home/mqperf/cph/results
  IFS=:
  echo "$messageSize" >> /home/mqperf/cph/results
  for concurrentConnections in ${clientsArray[@]}
  do
    runclients $concurrentConnections $messageSize
  done
done
unset IFS

if ! [ "${MQ_RESULTS}" = "FALSE" ]; then
  cat /home/mqperf/cph/results
fi

if [ -n "${MQ_DATA}" ] && [ ${MQ_DATA} -eq 1 ]; then
  cat /tmp/system
  cat /tmp/disklog
  cat /tmp/nhalog
  cat /home/mqperf/cph/output
fi

if [ -n "${MQ_ERRORS}" ]; then
  cat /var/mqm/errors/AMQERR01.LOG
fi

if [ -n "${MQ_RESULTS_CSV}" ]; then
  cat /home/mqperf/cph/results.csv
fi

echo "----------------------------------------"
echo "cph testing finished--------------------"
echo "----------------------------------------"
