/*
DANFE simplificado - etiqueta em PDF.
Depende de harupdf/hbzebra; por isso fica na build completa.
*/

#include "harupdf.ch"
#include "hbzebra.ch"

FUNCTION SefazDanfeSimplificadoPdf( cXmlOuArquivo, cFilePDF, cLogoFile )

   LOCAL h := SefazDanfeSimplificadoDados( cXmlOuArquivo )
   LOCAL oPdf, oPage, oFont, oBold
   LOCAL nW := 420, nH := 620, y := 610

   IF Empty( cFilePDF )
      cFilePDF := "danfe_simplificado.pdf"
   ENDIF

   IF ! h[ "ok" ]
      RETURN h[ "erro" ]
   ENDIF

   oPdf  := HPDF_New()
   oPage := HPDF_AddPage( oPdf )
   HPDF_Page_SetWidth( oPage, nW )
   HPDF_Page_SetHeight( oPage, nH )

   oFont := HPDF_GetFont( oPdf, "Courier", NIL )
   oBold := HPDF_GetFont( oPdf, "Courier-Bold", NIL )

   DanfePdfBox( oPage, 10, 10, nW - 20, nH - 20 )

   DanfePdfText( oPage, oBold, 16, 10, y - 20, nW - 20, "DANFE simplificado - Etiqueta", "C" )
   DanfePdfLine( oPage, 10, y - 34, nW - 10, y - 34 )
   y -= 50

   DanfePdfText( oPage, oBold, 11, 20, y, 150, "Chave de acesso:", "L" )
   DanfePdfBarcode128( oPage, h[ "chave" ], 30, y - 92, nW - 60, 80 )
   DanfePdfText( oPage, oFont, 9, 20, y - 112, nW - 40, SefazDanfeFormatChave( h[ "chave" ] ), "C" )
   y -= 135
   DanfePdfLine( oPage, 10, y, nW - 10, y )

   IF ! Empty( cLogoFile ) .AND. File( cLogoFile )
      DanfePdfLogo( oPdf, oPage, cLogoFile, 24, y - 92, 95, 75 )
   ENDIF

   DanfePdfLabel( oPage, oBold, oFont, 125, y - 22, 285, "NOME/RAZAO SOCIAL", h[ "emitNome" ] )
   DanfePdfLabel( oPage, oBold, oFont, 125, y - 44, 285, "CNPJ", SefazDanfeFormatDoc( h[ "emitDoc" ] ) )
   DanfePdfLabel( oPage, oBold, oFont, 125, y - 66, 285, "IE", h[ "emitIE" ] )
   DanfePdfLabel( oPage, oBold, oFont, 125, y - 88, 285, "ENDERECO", h[ "emitEnd" ] )
   DanfePdfLabel( oPage, oBold, oFont, 125, y - 110, 285, "CEP/TEL", SefazDanfeFormatCep( h[ "emitCep" ] ) + "  " + SefazDanfeFormatFone( h[ "emitFone" ] ) )
   y -= 125
   DanfePdfLine( oPage, 10, y, nW - 10, y )

   DanfePdfVLine( oPage, 145, y, y - 62 )
   DanfePdfVLine( oPage, 285, y, y - 62 )
   DanfePdfLabel( oPage, oBold, oFont, 20, y - 22, 120, "N", h[ "nNF" ] )
   DanfePdfLabel( oPage, oBold, oFont, 20, y - 44, 120, "SERIE", h[ "serie" ] )
   DanfePdfLabel( oPage, oBold, oFont, 155, y - 32, 120, "DATA DA EMISSAO", h[ "dhEmi" ] )
   DanfePdfLabel( oPage, oBold, oFont, 295, y - 32, 100, "HORA DA EMISSAO", h[ "hEmi" ] )
   y -= 62
   DanfePdfLine( oPage, 10, y, nW - 10, y )

   DanfePdfText( oPage, oBold, 14, 10, y - 20, nW - 20, "DESTINATARIO", "C" )
   y -= 34
   DanfePdfLine( oPage, 10, y, nW - 10, y )

   DanfePdfLabel( oPage, oBold, oFont, 20, y - 26, nW - 40, "NOME/RAZAO SOCIAL", h[ "destNome" ] )
   y -= 50
   DanfePdfLine( oPage, 10, y, nW - 10, y )

   DanfePdfVLine( oPage, 170, y, y - 62 )
   DanfePdfVLine( oPage, 330, y, y - 62 )
   DanfePdfLabel( oPage, oBold, oFont, 20, y - 30, 145, "CNPJ/CPF/ID", SefazDanfeFormatDoc( h[ "destDoc" ] ) )
   DanfePdfLabel( oPage, oBold, oFont, 180, y - 30, 145, "INSCRICAO ESTADUAL", h[ "destIE" ] )
   DanfePdfLabel( oPage, oBold, oFont, 340, y - 30, 60, "UF", h[ "destUF" ] )
   y -= 62
   DanfePdfLine( oPage, 10, y, nW - 10, y )

   DanfePdfLabel( oPage, oBold, oFont, 20, y - 25, 230, "PROTOCOLO DE AUTORIZACAO", h[ "protocolo" ] )
   DanfePdfLabel( oPage, oBold, oFont, 270, y - 25, 120, "VALOR TOTAL DA NOTA", SefazDanfeFormatValor( h[ "valor" ] ) )

   HPDF_SaveToFile( oPdf, cFilePDF )
   HPDF_Free( oPdf )

RETURN cFilePDF

STATIC FUNCTION DanfePdfText( oPage, oFont, nSize, x, y, w, cText, cAlign )

   LOCAL nAlign := HPDF_TALIGN_LEFT

   DO CASE
   CASE cAlign == "C" ; nAlign := HPDF_TALIGN_CENTER
   CASE cAlign == "R" ; nAlign := HPDF_TALIGN_RIGHT
   ENDCASE

   HPDF_Page_SetFontAndSize( oPage, oFont, nSize )
   HPDF_Page_BeginText( oPage )
   HPDF_Page_TextRect( oPage, x, y + 12, x + w, y, hb_DefaultValue( cText, "" ), nAlign, NIL )
   HPDF_Page_EndText( oPage )

RETURN Nil

STATIC FUNCTION DanfePdfLabel( oPage, oBold, oFont, x, y, w, cLabel, cValue )
   DanfePdfText( oPage, oBold, 7, x, y + 8, w, cLabel + ":", "L" )
   DanfePdfText( oPage, oBold, 11, x, y - 5, w, hb_DefaultValue( cValue, "" ), "L" )
RETURN Nil

STATIC FUNCTION DanfePdfBox( oPage, x, y, w, h )
   HPDF_Page_Rectangle( oPage, x, y, w, h )
   HPDF_Page_Stroke( oPage )
RETURN Nil

STATIC FUNCTION DanfePdfLine( oPage, x1, y1, x2, y2 )
   HPDF_Page_MoveTo( oPage, x1, y1 )
   HPDF_Page_LineTo( oPage, x2, y2 )
   HPDF_Page_Stroke( oPage )
RETURN Nil

STATIC FUNCTION DanfePdfVLine( oPage, x, y1, y2 )
RETURN DanfePdfLine( oPage, x, y1, x, y2 )

STATIC FUNCTION DanfePdfBarcode128( oPage, cCode, x, y, w, h )

   LOCAL hZebra

   hZebra := hb_zebra_create_code128( cCode, NIL )
   IF hb_zebra_geterror( hZebra ) == 0
      hb_zebra_draw( hZebra, { | bx, by, bw, bh | HPDF_Page_Rectangle( oPage, bx, by, bw, bh ) }, x, y, w / 540, h )
      HPDF_Page_Fill( oPage )
      hb_zebra_destroy( hZebra )
   ENDIF

RETURN Nil

STATIC FUNCTION DanfePdfLogo( oPdf, oPage, cLogoFile, x, y, w, h )

   LOCAL oImage

   IF Lower( Right( cLogoFile, 4 ) ) == ".jpg" .OR. Lower( Right( cLogoFile, 5 ) ) == ".jpeg"
      oImage := HPDF_LoadJpegImageFromFile( oPdf, cLogoFile )
      HPDF_Page_DrawImage( oPage, oImage, x, y, w, h )
   ENDIF

RETURN Nil

FUNCTION SefazDanfeSimplificadoDados( cXmlOuArquivo )

   LOCAL h := {=>}, cXml, cNFe, cInfNFe, cIde, cEmit, cDest, cTotal, cICMSTot
   LOCAL cEnderEmit, cEnderDest, cInfProt, cId, cDhEmi

   h[ "ok" ]   := .F.
   h[ "erro" ] := ""

   cXml := SefazDanfeLoadXml( cXmlOuArquivo )
   IF Empty( cXml )
      h[ "erro" ] := "XML vazio"
      RETURN h
   ENDIF

   cNFe := XmlNode( cXml, "NFe", .T. )
   IF Empty( cNFe )
      cNFe := cXml
   ENDIF

   cInfNFe := XmlNode( cNFe, "infNFe", .T. )
   IF Empty( cInfNFe )
      h[ "erro" ] := "Nao localizou infNFe. Informe XML autorizado nfeProc/NFe completo."
      RETURN h
   ENDIF

   cId       := XmlElement( cInfNFe, "Id" )
   cIde      := XmlNode( cInfNFe, "ide", .T. )
   cEmit     := XmlNode( cInfNFe, "emit", .T. )
   cDest     := XmlNode( cInfNFe, "dest", .T. )
   cTotal    := XmlNode( cInfNFe, "total", .T. )
   cICMSTot  := XmlNode( cTotal, "ICMSTot", .T. )
   cInfProt  := XmlNode( cXml, "infProt", .T. )
   cEnderEmit := XmlNode( cEmit, "enderEmit", .T. )
   cEnderDest := XmlNode( cDest, "enderDest", .T. )

   h[ "chave" ]     := SefazDanfeOnlyDigits( IIf( Left( cId, 3 ) == "NFe", SubStr( cId, 4 ), cId ) )
   h[ "emitNome" ]  := XmlNode( cEmit, "xNome" )
   h[ "emitDoc" ]   := IIf( Empty( XmlNode( cEmit, "CNPJ" ) ), XmlNode( cEmit, "CPF" ), XmlNode( cEmit, "CNPJ" ) )
   h[ "emitIE" ]    := XmlNode( cEmit, "IE" )
   h[ "emitEnd" ]   := AllTrim( XmlNode( cEnderEmit, "xLgr" ) + " " + XmlNode( cEnderEmit, "nro" ) + " " + XmlNode( cEnderEmit, "xBairro" ) + " " + XmlNode( cEnderEmit, "xMun" ) + " UF: " + XmlNode( cEnderEmit, "UF" ) )
   h[ "emitCep" ]   := XmlNode( cEnderEmit, "CEP" )
   h[ "emitFone" ]  := XmlNode( cEnderEmit, "fone" )
   h[ "nNF" ]       := XmlNode( cIde, "nNF" )
   h[ "serie" ]     := XmlNode( cIde, "serie" )
   cDhEmi           := IIf( Empty( XmlNode( cIde, "dhEmi" ) ), XmlNode( cIde, "dEmi" ), XmlNode( cIde, "dhEmi" ) )
   h[ "dhEmi" ]     := SefazDanfeData( cDhEmi )
   h[ "hEmi" ]      := SefazDanfeHora( cDhEmi )
   h[ "destNome" ]  := XmlNode( cDest, "xNome" )
   h[ "destDoc" ]   := SefazDanfeDestDoc( cDest )
   h[ "destIE" ]    := XmlNode( cDest, "IE" )
   h[ "destUF" ]    := IIf( Empty( XmlNode( cEnderDest, "UF" ) ), XmlNode( cDest, "UF" ), XmlNode( cEnderDest, "UF" ) )
   h[ "protocolo" ] := XmlNode( cInfProt, "nProt" )
   h[ "valor" ]     := XmlNode( cICMSTot, "vNF" )
   h[ "ok" ]        := ! Empty( h[ "chave" ] )

   IF ! h[ "ok" ]
      h[ "erro" ] := "Nao localizou chave de acesso no Id da infNFe"
   ENDIF

RETURN h