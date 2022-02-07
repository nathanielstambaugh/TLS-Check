#!/bin/bash

servers=`awk -F, '{print $1}' /home/nstambaugh/Desktop/WW_SADB_Win2008.csv`
compliantcnt=0
noncompliantcnt=0
unreachable=0

for server in $servers
do
	echo $server

	noncompliant=`echo -e "quit\n" | timeout 10s openssl s_client -connect $server:3389 -tls1_2 2>&1 | grep "(NONE)"`
	compliant=`echo -e "quit\n" | timeout 10s openssl s_client -connect $server:3389 -tls1_2 2>&1 | grep "TLSv1/SSLv3"`
	
	if [ -n "$noncompliant" ]; then
		echo $server " = not compliant" >> compliance.txt
		((noncompliantcnt++))
	elif [ -n "$compliant" ]; then
		echo $server " = compliant" >> compliance.txt
		((compliantcnt++))
	else
		echo $server " = not responding/resolving" >> compliance.txt
		((unreachable++))
	fi
done

echo "" >> compliance.txt
echo "" >> compliance.txt
echo "Compliant = " $compliantcnt >> compliance.txt
echo "Non-compliant = " $noncompliantcnt >> compliance.txt
echo "Unreachable = " $unreachable >> compliance.txt
