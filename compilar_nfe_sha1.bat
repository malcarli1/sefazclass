@echo off
set PATH=C:\Borland\bcc58\Bin;C:\MiniGUI\Harbour\bin;%PATH%
set HB_COMPILER=bcc
C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc nfe_sha1_demo.hbp
pause
