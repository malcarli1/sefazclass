@echo off
setlocal
set "PATH=C:\Borland\bcc58\Bin;C:\MiniGUI\Harbour\bin;%PATH%"
set "HB_COMPILER=bcc"

C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc ..\sefazclass_core.hbp || exit /b 1
C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc demo_diagnostico.hbp || exit /b 1
C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc demo_teste_rapido.hbp || exit /b 1
C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc demo_danfe_simplificado_html.hbp || exit /b 1
C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc demo_danfe_simplificado.hbp || exit /b 1
pause
C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc demo_nfe_status.hbp || exit /b 1
C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc demo_cte_status.hbp || exit /b 1
C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc demo_mdfe_status.hbp || exit /b 1
C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc demo_certificado.hbp || exit /b 1
C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc demo_assinatura.hbp || exit /b 1
C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc demo_valida_assinatura.hbp || exit /b 1
C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc demo_retorno.hbp || exit /b 1
C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc demo_winhttp_config.hbp || exit /b 1
C:\MiniGUI\Harbour\bin\hbmk2 -comp=bcc demo_curl_config.hbp || exit /b 1

pause
echo.
echo Demos core compilados com sucesso.
endlocal
