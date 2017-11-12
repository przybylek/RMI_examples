#!/bin/bash

# contributor: Adam Przybylek

# The client's codebase URL and port
HTTPserverIP=192.168.0.16
HTTPserverPort=8080

# The RMI registry's IP address
RMIserverIP=192.168.0.10

# Logging activity of default RMIClassLoader provider
LOG=-Dsun.rmi.loader.logLevel=SILENT
#LOG=-Dsun.rmi.loader.logLevel=BRIEF

# Delete all existing .class files
rm client/*.class &>/dev/null
rm server/*.class &>/dev/null

# Compile the client-side code
javac client/ComputePi.java

# Make the client-side bytecode available via the HTTP server
myIP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
if [ $HTTPserverIP = $myIP ]
then
    python -m SimpleHTTPServer $HTTPserverPort &
else
    echo "Start the HTTP server on $HTTPserverIP:$HTTPserverPort"
    echo "Upload the client-side bytecode to the HTTP server"
fi
echo "Press Enter when the HTTP server is on..."
read

# Run the client app
java -Djava.rmi.server.codebase=http://$HTTPserverIP:$HTTPserverPort/ -Djava.rmi.server.useCodebaseOnly=false -Djava.security.policy=java.policy $LOG client.ComputePi $RMIserverIP 10
