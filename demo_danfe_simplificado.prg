PROCEDURE Main()

   LOCAL cXml, cHtmlFile := "danfe_simplificado.html", cPdfFile := "danfe_simplificado.pdf"
   LOCAL cRet

   IF hb_ArgC() >= 1
      cXml := [43140589237911000140550000002823061795732230-procnfe.xml] //hb_ArgV( 1 )
   ELSE
      ? "Informe o XML autorizado nfeProc/NFe."
      ? "Exemplo: demo_danfe_simplificado.exe nfe_autorizada.xml"
      RETURN
   ENDIF

   SefazDanfeSimplificadoSalvarHtml( cXml, cHtmlFile )
   ? "HTML gerado:", cHtmlFile

   cRet := SefazDanfeSimplificadoPdf( cXml, cPdfFile )
   IF cRet == cPdfFile
      ? "PDF gerado.:", cPdfFile
   ELSE
      ? "PDF erro..:", cRet
   ENDIF
   wait
RETURN

