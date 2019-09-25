#!/bin/bash
USER="ncroot"
PASSWORD="OpenMSA"
OPERATOR="BLR"

echo "--------------------------------------------------"
echo "CREATE $OPERATOR TENANT AND Tyrell CUSTOMER"  
echo "--------------------------------------------------"

curl -u $USER:$PASSWORD -XPOST http://127.0.0.1/ubi-api-rest/operator/$OPERATOR?name=BladeRunner
curl -u $USER:$PASSWORD -XPOST -H "Content-Type:application/json" -d'{"name":"Dr Eldon Tyrell"}' http://127.0.0.1/ubi-api-rest/customer/{$OPERATOR}?name=Tyrell&reference=TyrellCorp
curl -u $USER:$PASSWORD -XPOST -H "Content-Type:application/json" http://127.0.0.1/ubi-api-rest/repository/operator?uri=Process/$OPERATOR
curl -u $USER:$PASSWORD -XPOST -H "Content-Type:application/json" http://127.0.0.1/ubi-api-rest/repository/operator?uri=CommandDefinition/$OPERATOR


sleep 1

echo "--------------------------------------------------"
echo "LOAD WORKFLOWS AND MICROSERVICES TO THE $OPERATOR TENANT REPOSITORY"
echo "--------------------------------------------------"

cd /root/OpenMSA_Self_Demo_Setup
cp -r Process/$OPERATOR/* /opt/fmc_repository/Process/$OPERATOR
cp Process/$OPERATOR/.* /opt/fmc_repository/Process/$OPERATOR
cp -r CommandDefinition/$OPERATOR/* /opt/fmc_repository/CommandDefinition/$OPERATOR
cp CommandDefinition/$OPERATOR/.* /opt/fmc_repository/CommandDefinition/$OPERATOR
chown -R ncuser:ncuser /opt/fmc_repository/Process/$OPERATOR
chown -R ncuser:ncuser /opt/fmc_repository/CommandDefinition/$OPERATOR 


CUSTLIST=`curl -u $USER:$PASSWORD -XGET -H "Content-Type:application/json" http://127.0.0.1/ubi-api-rest/lookup/customers`

IFS='"' # set delimiter
read -ra ADDR <<< "$CUSTLIST" # str is read into an array as tokens separated by IFS
for i in "${ADDR[@]}"; do # access each element of array
    if [[ $i == BLRA* ]]  
    then  
	CUSTID=$i
    fi
done

sleep 1


echo "--------------------------------------------------"
echo "ATTACH WORKFLOWS TO CUSTOMER $CUSTID"  
echo "--------------------------------------------------"

curl -u $USER:$PASSWORD -XPOST -H "Content-Type:application/json" http://127.0.0.1/ubi-api-rest/orchestration/$CUSTID/service/attach?uri=Process/$OPERATOR/SelfDemoSetup/SelfDemoSetup.xml
curl -u $USER:$PASSWORD -XPOST -H "Content-Type:application/json" http://127.0.0.1/ubi-api-rest/orchestration/$CUSTID/service/attach?uri=Process/$OPERATOR/Simple_Firewall/Simple_firewall_manager.xml 
curl -u $USER:$PASSWORD -XPOST -H "Content-Type:application/json" http://127.0.0.1/ubi-api-rest/orchestration/$CUSTID/service/attach?uri=Process/$OPERATOR/IMPORT/Import_microservice.xml

sleep 1

echo "--------------------------------------------------"
echo "CREATE DEMO DEVICES"
echo "--------------------------------------------------"

CUSTIDONLY=${CUSTID//BLRA}

curl  -isw 'HTTP_CODE=%{http_code}'  -u $USER:$PASSWORD -H "Content-Type:application/json"  -XPOST 'http://127.0.0.1/ubi-api-rest/orchestration/service/execute/'$CUSTID'/?serviceName=Process/'$OPERATOR'/SelfDemoSetup/SelfDemoSetup&processName=Process%2FBLR%2FSelfDemoSetup%2FProcess_Setup' -d'{"customer_id":"'$CUSTIDONLY'"}'

sleep 3

echo "--------------------------------------------------"
echo "CREATE INTERFACES"
echo "--------------------------------------------------"

ifconfig lo:2 127.0.0.2
ifconfig lo:3 127.0.0.3
ifconfig lo:4 127.0.0.4
ifconfig eth0:1 172.16.1.1 netmask 255.255.255.0
ifconfig eth0:2 172.16.2.1 netmask 255.255.255.0

sleep 3

echo "--------------------------------------------------"
echo "CREATE FIREWALL CHAINS"
echo "--------------------------------------------------"

DEVICES=`curl -u $USER:$PASSWORD -XGET -H "Content-Type:application/json" http://127.0.0.1/ubi-api-rest/lookup/devices`

IFS='"' # set delimiter
read -ra ADDR <<< "$DEVICES" # str is read into an array as tokens separated by IFS
for i in "${ADDR[@]}"; do # access each element of array
    if [[ $i == BLR* ]]  
    then  
	iptables -N $i
    fi
done

