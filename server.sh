#!/bin/bash

# contributor: Adam Przybylek

# The IP address of this host
myIP=192.168.0.16

# The server's codebase URL and port
HTTPserverIP=$myIP
HTTPserverPort=8080

# Logging activity of default RMIClassLoader provider
LOG=-Dsun.rmi.loader.logLevel=SILENT
# LOG=-Dsun.rmi.loader.logLevel=BRIEF

# Delete all existing .class files
rm server/*.class &>/dev/null
rm client/*.class &>/dev/null

# Start the RMI registry
echo "RMIregistry cannot have a CLASSPATH to the bytecode of the remote object"
cd server
rmiregistry -J-Djava.rmi.server.useCodebaseOnly=false -J$LOG &
cd ..

# Compile the server-side code
javac server/ComputeEngine.java
#rmic server.ComputeEngine

# Make the server-side bytecode available via the HTTP server
if [ $HTTPserverIP = $myIP ]
then
    python -m SimpleHTTPServer $HTTPserverPort &
else
    echo "Start the HTTP server on $HTTPserverIP:$HTTPserverPort"
    echo "Upload the server-side bytecode to the HTTP server"
fi
echo "Press Enter when the HTTP server is on..."
read

# Run the server app
java -Djava.rmi.server.codebase=http://$HTTPserverIP:$HTTPserverPort/ -Djava.rmi.server.hostname=$myIP -Djava.rmi.server.useCodebaseOnly=false -Djava.security.policy=java.policy $LOG server.ComputeEngine

# ps
# kill -TERM 1490