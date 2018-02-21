#! /bin/bash 

echo -e "\nStart initiated at $(date +%Y-%m-%d\ %H-%M-%S)\n" | tee -a ${DERBY_LOG}/start.log 

export DERBY_HOME=/opt/derby/db-derby-${version}-bin

# Start Derby in Server Mode
java -Dderby.drda.logConnections=true \
     -Dderby.infolog.append=true \
     -Dderby.stream.error.file=${DERBY_LOG}/derby.log \
     -Dderby.system.home=${DERBY_HOME}/dbs \
     -cp ${DERBY_HOME}/lib/derbynet.jar org.apache.derby.drda.NetworkServerControl start \
     -h 0.0.0.0 -p ${dbport} > /dev/null & 

echo -n "Waiting for Derby start"
while [[ $(cat ${DERBY_LOG}/derby.log > /dev/null 2>&1;echo $?) -ne 0 ]];
do
    echo -n ".";
    sleep 1;
done
echo -e "\nDerby is ready"

echo "JPS output:"
jps | tee -a ${DERBY_LOG}/start.log 
${DERBY_HOME}/bin/sysinfo | tee -a ${DERBY_LOG}/start.log 2>&1

firstStart=true
executing=true

if [[ -d "${DERBY_HOME}/dbs" && -n $(ls -A ${DERBY_HOME}/dbs) ]]; then
    firstStart=false
fi

# Create DB with the first start
if [[ ${firstStart} == true ]]; then
	echo "First start, creating DB ${dbname}" | tee -a ${DERBY_LOG}/derby.log
    echo "connect 'jdbc:derby://localhost:${dbport}/${dbname};create=true;user=${dbuser};password=${dbpass}';" | java -cp ${DERBY_HOME}/lib/derbyclient.jar:${DERBY_HOME}/lib/derbytools.jar:. org.apache.derby.tools.ij | tee -a ${DERBY_LOG}/start.log
fi

while [[ ${executing} == true ]]; do
	sleep 1 
	trap 'echo "kill signal handled, stopping processes..."; executing=false' SIGINT SIGTERM
done 

echo "Stopping NetworkServerControl ..." | tee -a ${DERBY_LOG}/derby.log

java -cp ${DERBY_HOME}/lib/derbynet.jar org.apache.derby.drda.NetworkServerControl shutdown -h 0.0.0.0 -p ${dbport} &