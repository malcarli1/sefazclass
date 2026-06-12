/*****************************************************************************
 * DEMO     : DEMO_NFE_SHA1.PRG                                              *
 * OBJETIVO : Exemplo isolado de assinatura XMLDSig RSA-SHA1 para NF-e/NFC-e *
 *****************************************************************************/

PROCEDURE Main()
   LOCAL cSubject := "15527739000123"
   LOCAL cThumbprint := ""
   LOCAL cXml, cAssinado

   /*
      Ajuste cSubject para parte do nome/CNPJ do certificado instalado
      no repositório "Pessoal" do usuário atual, ou informe cThumbprint.
   */

   cXml := DemoNFeXml()
   hb_MemoWrit( "nfe_sha1_original.xml", cXml )

   cAssinado := XmlSha1AssinarNFe( cXml, cSubject, cThumbprint )
   IF Empty( cAssinado )
      hb_MemoWrit( "demo_nfe_sha1.log", "ERRO assinatura SHA1: " + FiscalCryptoLastError() + hb_Eol() )
      ? "ERRO assinatura SHA1: " + FiscalCryptoLastError()
      RETURN
   ENDIF

   hb_MemoWrit( "nfe_sha1_assinado.xml", cAssinado )
   hb_MemoWrit( "demo_nfe_sha1.log", "OK assinatura SHA1" + hb_Eol() )
   ? "OK assinatura SHA1"
   ? "Gerado: nfe_sha1_assinado.xml"
RETURN

STATIC FUNCTION DemoNFeXml()
   LOCAL cXml := ""

   cXml += '<NFe xmlns="http://www.portalfiscal.inf.br/nfe">'
   cXml += '<infNFe Id="NFe35260615527739000123550010000000011000000010" versao="4.00">'
   cXml += '<ide>'
   cXml += '<cUF>35</cUF><cNF>00000001</cNF><natOp>VENDA</natOp><mod>55</mod><serie>1</serie><nNF>1</nNF>'
   cXml += '<dhEmi>2026-06-03T10:00:00-03:00</dhEmi><tpNF>1</tpNF><idDest>1</idDest><cMunFG>3550308</cMunFG>'
   cXml += '<tpImp>1</tpImp><tpEmis>1</tpEmis><cDV>0</cDV><tpAmb>2</tpAmb><finNFe>1</finNFe><indFinal>1</indFinal><indPres>1</indPres><procEmi>0</procEmi><verProc>HARBOUR-SHA1</verProc>'
   cXml += '</ide>'
   cXml += '<emit><CNPJ>15527739000123</CNPJ><xNome>EMITENTE TESTE</xNome><enderEmit><xLgr>RUA TESTE</xLgr><nro>1</nro><xBairro>CENTRO</xBairro><cMun>3550308</cMun><xMun>SAO PAULO</xMun><UF>SP</UF><CEP>01001000</CEP><cPais>1058</cPais><xPais>BRASIL</xPais></enderEmit><IE>123456789012</IE><CRT>3</CRT></emit>'
   cXml += '<dest><CPF>11144477735</CPF><xNome>DESTINATARIO TESTE</xNome><indIEDest>9</indIEDest></dest>'
   cXml += '<det nItem="1"><prod><cProd>1</cProd><cEAN>SEM GTIN</cEAN><xProd>PRODUTO TESTE</xProd><NCM>99999999</NCM><CFOP>5102</CFOP><uCom>UN</uCom><qCom>1.0000</qCom><vUnCom>1.00</vUnCom><vProd>1.00</vProd><cEANTrib>SEM GTIN</cEANTrib><uTrib>UN</uTrib><qTrib>1.0000</qTrib><vUnTrib>1.00</vUnTrib><indTot>1</indTot></prod><imposto><ICMS><ICMS00><orig>0</orig><CST>00</CST><modBC>3</modBC><vBC>1.00</vBC><pICMS>18.00</pICMS><vICMS>0.18</vICMS></ICMS00></ICMS><PIS><PISAliq><CST>01</CST><vBC>1.00</vBC><pPIS>1.65</pPIS><vPIS>0.02</vPIS></PISAliq></PIS><COFINS><COFINSAliq><CST>01</CST><vBC>1.00</vBC><pCOFINS>7.60</pCOFINS><vCOFINS>0.08</vCOFINS></COFINSAliq></COFINS></imposto></det>'
   cXml += '<total><ICMSTot><vBC>1.00</vBC><vICMS>0.18</vICMS><vICMSDeson>0.00</vICMSDeson><vFCP>0.00</vFCP><vBCST>0.00</vBCST><vST>0.00</vST><vFCPST>0.00</vFCPST><vFCPSTRet>0.00</vFCPSTRet><vProd>1.00</vProd><vFrete>0.00</vFrete><vSeg>0.00</vSeg><vDesc>0.00</vDesc><vII>0.00</vII><vIPI>0.00</vIPI><vIPIDevol>0.00</vIPIDevol><vPIS>0.02</vPIS><vCOFINS>0.08</vCOFINS><vOutro>0.00</vOutro><vNF>1.00</vNF></ICMSTot></total>'
   cXml += '<transp><modFrete>9</modFrete></transp>'
   cXml += '<pag><detPag><tPag>01</tPag><vPag>1.00</vPag></detPag></pag>'
   cXml += '</infNFe>'
   cXml += '</NFe>'

RETURN cXml
