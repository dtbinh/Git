

tcpipClient = tcpip('169.254.0.2',5555,'NetworkRole','Client');
set(tcpipClient,'InputBufferSize',7688);
set(tcpipClient,'Timeout',30);
fopen(tcpipClient);


A = [1 2 3 4 5];

fwrite(tcpipClient, 10*A);
pause(1);

fwrite(tcpipClient, 20*A);
pause(1);

fwrite(tcpipClient, 30*A);
pause(1);

fwrite(tcpipClient, 40*A);
pause(1);

fwrite(tcpipClient, 50*A);
pause(1);

fwrite(tcpipClient, 255);



fclose(tcpipClient);