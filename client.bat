::contributor: Adam Przybylek

::The client's codebase URL and port
SET HTTPserverIP=192.168.0.10
SET HTTPserverPort=80

::The RMI registry's IP address
SET RMIserverIP=192.168.0.16

::Logging activity of default RMIClassLoader provider
SET LOG=-Dsun.rmi.loader.logLevel=SILENT
::SET LOG=-Dsun.rmi.loader.logLevel=BRIEF

::Delete all existing .class files
del /S client\*.class
del /S server\*.class

::Compile the client-side code
javac client/ComputePi.java

::Make the client-side bytecode available via the HTTP server
::Getting the IP address works on Windows 7
@FOR /F "tokens=4 delims= " %%i in ('route print ^| find " 0.0.0.0"') do set myIP=%%i

@echo.
@IF "%myIP%"=="%HTTPserverIP%" (
    start /B hfs.exe client
	@echo If you want to use a port number other than 80, adjust your HTTP server configuration.
) ELSE (
    @echo Start the HTTP server on %HTTPserverIP%:%HTTPserverPort%
	@echo Upload the client-side bytecode to the HTTP server
)
@echo Wait until the HTTP server is ready before running ComputePi!
@echo.
@pause

::Run the client app
java -Djava.rmi.server.codebase=http://%HTTPserverIP%:%HTTPserverPort%/ -Djava.security.policy=java.policy -Djava.rmi.server.useCodebaseOnly=false %LOG% client.ComputePi %RMIserverIP% 10

