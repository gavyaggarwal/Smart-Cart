:loop

findclient.exe -s http://192.168.43.11:8003 -g plushpygmy -c 1 2>out.txt
bash -c "./format.sh"

goto loop
