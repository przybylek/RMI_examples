::The IP address of this host
SET myIP=192.168.0.10

::The server's codebase URL and port
SET HTTPserverIP=192.168.0.10
SET HTTPserverPort=80

::Logging activity of default RMIClassLoader provider
SET LOG=-Dsun.rmi.loader.logLevel=SILENT
::SET LOG=-Dsun.rmi.loader.logLevel=BRIEF

::Delete all existing .class files
del /S server\*.class
del /S client\*.class

::Start the RMI registry
@echo.
@echo RMIregistry cannot have a CLASSPATH to the bytecode of the remote object
cd server
start rmiregistry -J-Djava.rmi.server.useCodebaseOnly=false -J-Djava.rmi.server.logCalls=true -J%LOG%
cd ..

::Compile the server-side code
javac server/ComputeEngine.java

::Make the server-side bytecode available via the HTTP server
@echo.
@IF "%myIP%"=="%HTTPserverIP%" (
    start /B hfs.exe server
) ELSE (
    @echo Start the HTTP server on %HTTPserverIP%:%HTTPserverPort%
	@echo Upload the server-side bytecode to the HTTP server
)
@echo Wait until the HTTP server is ready before starting ComputeEngine!
@echo.
@pause

::Run the server app
java -Djava.rmi.server.codebase=http://%HTTPserverIP%:%HTTPserverPort%/ -Djava.rmi.server.hostname=%myIP% -Djava.security.policy=java.policy -Djava.rmi.server.useCodebaseOnly=false %LOG% server.ComputeEngine