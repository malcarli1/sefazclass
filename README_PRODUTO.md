# SefazClass Produto

Esta pasta e uma nova versao organizada da SefazClass.

A pasta original foi preservada. Esta versao reaproveita a `SefazClass` original como motor fiscal e adiciona uma camada nova, modular, com retorno padronizado.

## Objetivo

Manter a cobertura completa da classe original e facilitar a vida do programador.

Em vez de chamar tudo diretamente em uma classe enorme, a nova API separa por area:

```harbour
oSefaz := TSefazProduto():New()
oSefaz:LoadConfigIni( "sefaz.ini" )
oSefaz:UF( "SP" ):Ambiente( "2" ):Transporte( "WINHTTP", .T. )

hRet := oSefaz:NFe():Status()
hRet := oSefaz:CTe():Status()
hRet := oSefaz:MDFe():Status()
hRet := oSefaz:BPe():Status()
```

## Retorno padronizado

Todas as chamadas da API nova retornam hash:

```harbour
hRet[ "ok" ]
hRet[ "operacao" ]
hRet[ "documento" ]
hRet[ "status" ]
hRet[ "codigoReal" ]
hRet[ "motivo" ]
hRet[ "motivoOriginal" ]
hRet[ "motivoTabela" ]
hRet[ "xml" ]
hRet[ "recibo" ]
hRet[ "protocolo" ]
hRet[ "chave" ]
hRet[ "codigoErro" ]
hRet[ "erroFiscal" ]
hRet[ "erroTecnico" ]
hRet[ "transporte" ]
hRet[ "httpStatus" ]
hRet[ "erroTransporte" ]
hRet[ "diagnostico" ]
```

`codigoReal` vem do `cStat`/`cdResposta` do XML. Quando existir tabela local em
`codigos-retorno-nfe.txt` ou `codigos-retorno-cte.txt`, `motivoTabela` recebe a
descricao real da tabela e `motivo` fica normalizado por ela. O texto que veio
literalmente no XML permanece em `motivoOriginal`.

Consulta direta:

```harbour
? SefazRetornoCodigoDescricao( "NFE", 100 )
? SefazRetornoCodigoDescricao( "CTE", 100 )
```

Para lote com varios eventos:

```harbour
nQtd := oSefaz:RetornoEventoCount( hRet )
FOR nI := 1 TO nQtd
   hEvento := oSefaz:RetornoEvento( hRet, nI )
NEXT

? oSefaz:RetornoResumo( hRet )
```

Tambem existe objeto de resposta, para quem prefere metodo em vez de hash:

```harbour
hRet  := oSefaz:NFe():Protocolo( cChave )
oResp := oSefaz:RetornoObjeto( hRet )

IF oResp:Ok()
   ? oResp:Codigo()
   ? oResp:Motivo()
   ? oResp:Protocolo()
ELSE
   ? oResp:CodigoErro()
   ? oResp:ErroFiscal()
   ? oResp:ErroTecnico()
ENDIF

FOR nI := 1 TO oResp:EventoCount()
   hEvento := oResp:Evento( nI )
NEXT
```

Texto pronto para suporte/log:

```harbour
? oResp:Texto()
```

## Validacao XML

A validacao por schema continua usando o motor da classe original, mas agora pode
retornar hash padronizado:

```harbour
hVal := oSefaz:ValidarXmlProduto( cXml, "schemas\nfe_v4.00.xsd", "NFE.VALIDAR" )

IF ! hVal[ "ok" ]
   ? hVal[ "codigoErro" ]   // XML_SCHEMA
   ? hVal[ "motivo" ]       // erro retornado pelo MSXML/schema
ENDIF
```

Para manter compatibilidade, o metodo antigo tambem continua disponivel:

```harbour
cMsg := oSefaz:ValidaXml( cXml, cXsd )
```

## Fila e reprocessamento

A API nova pode salvar cada XML enviado em fila local, com metadados em JSON:

```harbour
hFila := oSefaz:FilaSalvar( "fila_sefaz", "NFE.ENVIO", cXml )

// depois do envio/consulta:
hRet := oSefaz:NFe():Enviar( cXml )
oSefaz:FilaAtualizarRetorno( "fila_sefaz", hFila[ "id" ], hRet )

aFila := oSefaz:FilaListar( "fila_sefaz" )
hItem := oSefaz:FilaCarregar( "fila_sefaz", hFila[ "id" ] )
```

Para reprocessar pendentes/erros, a classe recebe um codeblock. Isso deixa o
programador decidir se vai reenviar NF-e, consultar recibo, protocolo etc.:

```harbour
aPendentes := oSefaz:FilaPendentes( "fila_sefaz" )

FOR nI := 1 TO Len( aPendentes )
   hItem := aPendentes[ nI ]

   hRet := oSefaz:FilaReprocessar( "fila_sefaz", hItem[ "id" ], ;
      { | hFila, cXml, oProd | oProd:NFe():Enviar( cXml ) } )
NEXT
```

Cada item grava:

```text
ID.json
ID.xml
ID_retorno.xml
```

O JSON guarda situacao, tentativas, codigo, motivo, protocolo e caminho dos XMLs.
Isso facilita reprocessamento, auditoria e suporte sem obrigar banco de dados.

## Logs tecnicos

O log tecnico original continua disponivel via `SetDebug()`/`LogTecnico()`.
A camada nova adiciona `LogProduto()`, que grava tambem um resumo legivel da
resposta padronizada quando o debug estiver ativo:

```harbour
oSefaz:Debug( .T., "logs" )
hRet := oSefaz:NFe():Status()
oSefaz:LogProduto( "status_nfe", hRet )
```

## Checklist e suporte

Antes do envio, use `Checklist()` para descobrir configuracao faltante:

```harbour
hCheck := oSefaz:Checklist()

IF ! hCheck[ "ok" ]
   FOR nI := 1 TO Len( hCheck[ "itens" ] )
      ? hCheck[ "itens" ][ nI ][ "codigo" ]
      ? hCheck[ "itens" ][ nI ][ "mensagem" ]
   NEXT
ENDIF
```

Para atendimento/suporte, salve um conjunto simples com resumo, diagnostico,
retorno XML e retorno JSON:

```harbour
hRet := oSefaz:NFe():Protocolo( cChave )
hSup := oSefaz:SuporteSalvar( "suporte_sefaz", hRet, "cliente_001_nfe" )
```

Arquivos gerados:

```text
cliente_001_nfe_resumo.txt
cliente_001_nfe_diagnostico.txt
cliente_001_nfe_retorno.xml
cliente_001_nfe_retorno.json
```

## Configuracao rapida

```harbour
oSefaz:UF( "SP" )
oSefaz:Ambiente( "1" )              // producao
oSefaz:Ambiente( "2" )              // homologacao
oSefaz:CertificadoNome( "NOME DO CERTIFICADO" )
oSefaz:TempoEspera( 10 )
oSefaz:SoapTimeout( 15000 )
oSefaz:NFCe( .T., "000001", "CSC..." )
oSefaz:Contingencia( .T. )
oSefaz:Debug( .T., "logs" )
```

Transportes:

```harbour
oSefaz:Transporte( "WINHTTP", .T. )
oSefaz:WinHttp( .T., "C:\certificados\empresa.pfx", "senha", .F. )

oSefaz:Transporte( "CURL", .T. )
oSefaz:Curl( .T., "C:\certificados\empresa.pfx", "senha", "P12" )
```

## Certificado

```harbour
hCert := oSefaz:Certificado():A1( "C:\certificados\empresa.pfx", "senha" )
hCert := oSefaz:Certificado():A3( "NOME OU THUMBPRINT" )
hCert := oSefaz:Certificado():Validar()
```

## Documentos

Cada modulo de documento tem metodos padrao:

```harbour
oSefaz:NFe():Status()
oSefaz:NFe():Enviar( cXml )
oSefaz:NFe():RetEnvio( cRecibo )
oSefaz:NFe():Protocolo( cChave )
oSefaz:NFe():Cancelar( ... )
oSefaz:NFe():CartaCorrecao( ... )
oSefaz:NFe():Inutilizar( ... )
oSefaz:NFe():Distribuicao( ... )
oSefaz:NFe():Cadastro( ... )
oSefaz:NFe():Manifestacao( ... )
oSefaz:NFe():GTIN( ... )
oSefaz:NFe():Contingencia( ... )
oSefaz:NFe():Destinadas( ... )
oSefaz:NFe():Download( ... )
oSefaz:NFe():AutorizarXml( ... )
oSefaz:NFe():CancelarSubstituicao( ... )
oSefaz:NFe():DataEntrega( ... )
oSefaz:NFe():AddCancelamento( ... )
oSefaz:NFe():GeraAutorizado( ... )
oSefaz:NFe():GeraEventoAutorizado( ... )
```

Tambem existem:

```harbour
oSefaz:CTe()
oSefaz:MDFe()
oSefaz:BPe()
```

Metodos especiais por documento:

```harbour
oSefaz:CTe():Entrega( ... )
oSefaz:CTe():InsucessoEntrega( ... )
oSefaz:CTe():CancelarEntrega( ... )
oSefaz:CTe():CancelarInsucessoEntrega( ... )
oSefaz:CTe():Desacordo( ... )

oSefaz:MDFe():EmAberto( ... )
oSefaz:MDFe():Encerramento( ... )
oSefaz:MDFe():Condutor( ... )
oSefaz:MDFe():Pagamento( ... )
```

Se existir algum metodo antigo que o programador queira chamar literalmente, use:

```harbour
hRet := oSefaz:NFe():Call( "NFeEventoDataEntrega", { ... } )
```

Isso garante que a cobertura completa da `SefazClass` original continue acessivel, mesmo para apelidos/compatibilidade.

## DANFE simplificado

```harbour
cHtml := oSefaz:Danfe():SimplificadoHtml( cXml )
cTxt  := oSefaz:Danfe():SimplificadoTexto( cXml )
oSefaz:Danfe():SimplificadoSalvarHtml( "danfe_simplificado.html", cXml )
```

## NT 2026.004 - CNPJ alfanumerico

Esta pasta inclui a NT `NT_2026.004_v1.00_AlteraSchemaNFCeNFeCNPJAlfa.pdf`.

A classe foi ajustada para NF-e/NFC-e aceitar CNPJ e chave de acesso
alfanumericos onde o schema novo altera campos de numerico para `char`:

```harbour
? ValidCnpj( "12ABC34501DE35" )
? FormatCnpj( "12ABC34501DE35" )
? SefazDanfeFormatChave( "35260612ABC34501DE3555002000000011000000010" )
```

O calculo de digito usa modulo 11 com valor `ASCII - 48`, conforme regra do
CNPJ alfanumerico. CPF continua numerico.

## Build

```bat
set PATH=C:\xbase\bcc582\Bin;C:\xbase\harbour_1608\bin;%PATH%
set HB_COMPILER=bcc
hbmk2 -comp=bcc sefazclass_produto_core.hbp
```

Ou:

```bat
tests\compilar_produto.bat
```

## Demos

```bat
tests\demo_produto_diagnostico.exe
tests\demo_produto_danfe.exe nfe_teste_danfe_simplificado.xml
tests\demo_produto_codigos_retorno.exe
tests\demo_produto_resposta_fila.exe
tests\demo_produto_checklist_suporte.exe
tests\demo_produto_status.exe sefaz.ini
```

`demo_produto_status` faz chamada real e precisa de certificado/ambiente configurado.

## Importante

Esta versao e uma camada nova. A `SefazClass` original continua disponivel em:

```harbour
oOriginal := oSefaz:Base()
```

Assim nada da cobertura original fica perdido.
