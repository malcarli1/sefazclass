# Sefazclass

Classe com funções pra Sefaz

Crie e/ou altere \harbour\bin\hbmk.hbc

acrescente

libpaths=pasta do arquivo sefazclass.hbc


# Como funciona o Webservice do governo:

Entregar XML e receber uma resposta.

No geral, a autorização de documentos envolve duas etapas:

1. Entrega o XML que retorna um número de recibo (ou erro)
2. Consulta esse recibo que retorna o protocolo (ou erro)

Já outras etapas: cancelamento, carta de correção, inutilização, etc. envolve apenas uma etapa:

1. Entrega o XML e já obtém o protocolo (ou erro)

# E a Sefazclass:

Tem eventos que tratam cada etapa.

- Autorização de NFE, CTE, MDFE: NfeLoteEnvia(), CteLoteEnvia(), MDFeLoteEnvia()
- Cancelamento:  NfeEventoCancela(), CteEventoCancela(), MDFeEventoCancela()
- Carta de correção: NfeEventoCarta(), CteEventoCarta()
- Inutilização: NfeInutiliza(), CteInutiliza()
- Outros eventos: CteEventoDesacordo(), MdfeEventoEncerramento(), MdfeEventoInclusaoCondutor(), NfeEventoManifestacao()

Verifique o nome dos parâmetros e saberá o que informar.
Dúvidas, consulte o manual da SEFAZ, que contém todos os detalhes.

# Considerações:

- A Sefazclass não trata arquivos XMLs, e sim o conteúdo. cXML representa o conteúdo do XML
- cCertificado é o nome do certificado, veja em propriedades do certificado o CN=

A Sefazclass não inventa nada, tudo está dentro dos manuais do governo.

Para entregar os XMLs, cada UF ou serviço é para um endereço de internet diferente.
Nos fontes da Sefazclass já tem muitos desses endereços, mas não significa que tem todos, ou que estão atualizados.
Cabe ao usuário da classe fazer os testes finais e informar algum endereço errado ou inexistente.

# Atualizada ate:

NFE 4.00
NFCE 4.00
CTE 4.00
MDFE 3.00 / MOC 3.00b
BPE 1.00 / MOC 1.00b

# Build core sem PDF/DANFE:

Foi incluido o arquivo sefazclass_core.hbp para compilar o nucleo fiscal sem os modulos de PDF/DANFE. Use quando a maquina nao tiver hbhpdf, hbzebra ou harupdf.ch instalados.

Com Borland/Harbour:

```
hbmk2 -comp=bcc sefazclass_core.hbp
```

O resultado fica em lib/sefazclass_core.lib e lib/sefazclass_core.hbx.

# Assinatura digital:

A rotina de assinatura foi mantida com o nome publico CapicomAssinaXml() para compatibilidade, mas a implementacao atual nao cria objetos COM CAPICOM. Ela usa CryptoAPI/CNG do Windows para SHA1, atendendo NFe/NFCe/CTe/MDFe/BPe.

Suporte previsto:

- A1 instalado no repositorio do Windows, buscando por CN ou thumbprint.
- A3 instalado/token/cartao, desde que o driver exponha a chave privada via CSP/CNG e a janela de PIN funcione no Windows.
- A1 direto de arquivo .pfx/.p12, usando a senha informada.

Observacao: a validacao final da assinatura deve ser feita com XML real em homologacao, porque canonicalizacao XML e espacos em branco sao pontos sensiveis em SEFAZ.

# Demos de certificado e assinatura:

Na pasta tests foram incluidos exemplos pequenos que nao enviam XML para a SEFAZ:

```
cd tests
hbmk2 -comp=bcc demo_certificado.hbp
hbmk2 -comp=bcc demo_assinatura.hbp
hbmk2 -comp=bcc demo_valida_assinatura.hbp
```

Uso do demo de assinatura:

```
demo_assinatura entrada.xml saida_assinada.xml subject "NOME OU CNPJ DO CERTIFICADO"
demo_assinatura entrada.xml saida_assinada.xml thumbprint "THUMBPRINT_DO_CERTIFICADO"
demo_assinatura entrada.xml saida_assinada.xml pfx "C:\certificados\certificado.pfx" "senha"
demo_valida_assinatura saida_assinada.xml
```

API nova recomendada:

- SefazAssinaXmlSha1( @cXml, cCertSubject, cSenha )
- SefazAssinaXmlSha1Thumbprint( @cXml, cThumbprint, cSenha )
- SefazAssinaXmlSha1Pfx( @cXml, cPfxFile, cSenha )
- SefazCertEscolhe( @dIni, @dFim )
- SefazCertificado( cNome, @dIni, @dFim, lValidaData )

Os nomes antigos CapicomAssinaXml(), CapicomCertificado(), CapicomEscolheCertificado(), CapicomInstalaPFX() e CapicomInstalaCER() continuam existindo apenas para compatibilidade.

# Retorno padronizado:

A classe agora interpreta o retorno da SEFAZ em um hash padronizado. Depois de qualquer chamada SOAP, a instancia passa a preencher:

- ::nStatus
- ::cMotivo
- ::cRecibo
- ::oRetorno
- ::aRetornoEventos

Funcoes disponiveis:

- SefazRetornoParse( cXml )
- SefazRetornoEventoCount( xRet )
- SefazRetornoEvento( xRet, nIndex )
- SefazRetornoSucesso( xRet )
- SefazRetornoResumo( xRet )

Campos principais do hash:

- status
- motivo
- codigoErro
- ok
- recibo
- protocolo
- chave
- eventCount
- eventos

O parser entende retorno de lote, consulta de recibo/protocolo, retorno de evento, protocolos autorizados, rejeicoes por evento e SOAP Fault. Para testar um XML de retorno sem enviar nada:

```
cd tests
hbmk2 -comp=bcc demo_retorno.hbp
demo_retorno retorno.xml
```

# Builds por compilador:

O build validado nesta maquina foi o Borland/BCC:

```
hbmk2 -comp=bcc sefazclass_core.hbp
```

Tambem foram adicionados arquivos de partida para outros compiladores Windows:

```
hbmk2 sefazclass_core_mingw.hbp
hbmk2 sefazclass_core_msvc.hbp
```

A assinatura usa APIs padrao do Windows, com crypt32, cryptui, advapi32 e ncrypt, entao nao depende conceitualmente do BCC. Pode ser necessario ajustar ambiente Harbour/SDK conforme a instalacao de cada compilador.

# Transporte alternativo via curl.exe:

A classe agora possui transporte SOAP alternativo por curl.exe, sem MSXML2.ServerXMLHTTP. O uso e opcional; por padrao continua MSXML para manter compatibilidade.

Exemplo com PFX/P12 sem instalar no Windows:

```
oSefaz := SefazClass():New()
oSefaz:CertificadoPfx( "C:\certificados\empresa.pfx", "senha" )
oSefaz:UseCurl( .T., "C:\certificados\empresa.pfx", "senha", "P12" )
```

Exemplo com certificado/chave PEM:

```
oSefaz:UseCurl( .T., "C:\certificados\cert.pem", "senha_chave", "PEM", "C:\certificados\key.pem" )
```

Campos relacionados:

- lUseCurl
- cCurlExe
- cCurlCertFile
- cCurlKeyFile
- cCurlCertType
- cCurlCertPassword
- cCurlCAInfo
- lCurlInsecure
- nCurlHttpStatus
- cCurlLastError
- lCurlKeepTemp
- cCurlTempBase

Observacoes:

- O transporte curl grava request/response em arquivos temporarios e apaga ao final.
- Para depuracao, use oSefaz:lCurlKeepTemp := .T.; a base dos arquivos fica em oSefaz:cCurlTempBase.
- O exemplo tests\demo_curl_config.hbp mostra a configuracao sem enviar nada para a SEFAZ.
- Para PFX/P12, o curl recebe `cert = arquivo:senha` no arquivo temporario de configuracao.
- A assinatura XML continua usando a rotina nativa da classe; o curl cuida apenas do envio HTTPS/mTLS.
- Esta parte compilou, mas precisa teste real em homologacao para validar comportamento de mTLS da SEFAZ com o certificado do cliente.
# Transporte nativo via WinHTTP:

A classe tambem possui transporte SOAP nativo por WinHTTP, sem MSXML e sem curl.exe. Este e o caminho recomendado para reduzir dependencias externas.

Exemplo com A1 PFX/P12 sem instalar no Windows:

```
oSefaz := SefazClass():New()
oSefaz:CertificadoPfx( "C:\certificados\empresa.pfx", "senha" )
oSefaz:UseWinHttp( .T., "C:\certificados\empresa.pfx", "senha" )
```

Exemplo com A3 ou certificado ja instalado no CurrentUser\MY:

```
oSefaz := SefazClass():New()
oSefaz:cCertificado := "NOME OU THUMBPRINT DO CERTIFICADO"
oSefaz:UseWinHttp( .T. )
```

Campos relacionados:

- lUseWinHttp
- lWinHttpInsecure
- nWinHttpStatus
- cWinHttpLastError

Observacoes:

- O WinHTTP usa APIs nativas do Windows e faz mTLS sem MSXML2.ServerXMLHTTP.
- Para A1, o PFX e carregado por PFXImportCertStore em store temporario de memoria e passado ao WinHTTP, sem CertAddCertificateContextToStore.
- Para A3, continua necessario o driver/token do fornecedor instalado no Windows; a classe localiza o certificado no CurrentUser\MY por nome ou thumbprint e usa a chave privada via CryptoAPI/CNG.
- O exemplo tests\demo_winhttp_config.hbp mostra a configuracao sem enviar nada para a SEFAZ.
- O transporte antigo por MSXML e o alternativo por curl continuam disponiveis para compatibilidade e diagnostico.
# Modo produto: fallback, logs e diagnostico

Para uso em cliente, a classe agora pode trabalhar com fallback automatico de transporte e log tecnico:

```
oSefaz := SefazClass():New()
oSefaz:SetTransporte( "AUTO", .T. )      // WINHTTP, depois MSXML, depois CURL quando for erro de comunicacao
oSefaz:SetDebug( .T., "C:\logs\sefaz" )
oSefaz:SetCertificadoA1( "C:\certificados\empresa.pfx", "senha" )
```

Ou com A3:

```
oSefaz:SetCertificadoA3( "NOME OU THUMBPRINT DO CERTIFICADO" )
oSefaz:SetTransporte( "WINHTTP", .T. )
```

Metodos novos:

- SetCertificadoA1( cPfxFile, cPassword )
- SetCertificadoA3( cNomeOuThumbprint )
- SetTransporte( cTransporte, lFallback )
- SetDebug( lDebug, cLogDir )
- ValidarCertificado()
- Diagnostico()

Campos novos:

- cTransportePreferido
- lFallbackAutomatico
- cUltimoTransporte
- cUltimoErroTransporte
- nTempoUltimoEnvio
- lDebug
- cLogDir

O fallback so troca de transporte quando o erro aparenta ser comunicacao/TLS/cliente HTTP. Se a SEFAZ responder uma rejeicao normal de schema, regra ou autorizacao, a classe nao tenta outro transporte.

Quando debug esta ativo, a classe grava arquivos .log, _soap.xml e _retorno.xml na pasta configurada. O XML e passado por SefazXmlSanitize() antes de salvar, removendo BOM e caracteres invalidos XML 1.0.

O exemplo tests\demo_diagnostico.hbp mostra a configuracao sem enviar nada para a SEFAZ.

# Configuracao por INI e demos de status

Foi incluido um carregador simples de INI para facilitar entrega a cliente/tester:

```
oSefaz := SefazClass():New()
oSefaz:LoadConfigIni( "sefaz.ini" )
```

Modelo:

```
tests\sefaz.ini.example
```

Demos reais de status de servico, usando certificado e ambiente do INI:

```
tests\demo_nfe_status.exe sefaz.ini
tests\demo_cte_status.exe sefaz.ini
tests\demo_mdfe_status.exe sefaz.ini
```

Arquivos gerados:

- ret_nfe_status.xml
- ret_cte_status.xml
- ret_mdfe_status.xml

Tambem foram incluidos:

- docs\MANUAL_CORE.md
- docs\CHECKLIST_HOMOLOGACAO.md
- docs\CHANGELOG_CORE.md

# Pacote core

Para gerar o pacote limpo:

```
powershell -ExecutionPolicy Bypass -File scripts\package_core.ps1
```

O script gera:

- dist\sefazclass_core_package
- dist\sefazclass_core_package.zip
- dist\sefazclass_core_package.zip.sha256.txt
- dist\sefazclass_core_package_AAAAMMDD_HHMMSS.zip
- dist\sefazclass_core_package_AAAAMMDD_HHMMSS.zip.sha256.txt# Facilidade para programadores

Foram incluidos arquivos para reduzir o tempo de integracao:

- tests\demo_teste_rapido.prg / .hbp / .exe: diagnostico + status NFe/CTe/MDFe em um comando.
- tests\compilar_demos_core.bat: recompila biblioteca core e demos principais.
- docs\GUIA_PROGRAMADOR.md: passo a passo curto para integrar por INI.

Uso rapido:

```
copy tests\sefaz.ini.example sefaz.ini
notepad sefaz.ini
cd tests
demo_teste_rapido.exe ..\sefaz.ini
```

<div align="center">

<b>Marcelo A. L. Carli</b><br>
Malc Informática — Gestão em Saúde Ocupacional<br>
📍 Marília/SP — Capital Nacional do Alimento ®<br>
🌐 <a href="https://malc-informatica.ueniweb.com" target="_blank">malc-informatica.ueniweb.com</a><br>
📧 <a href="mailto:marceloalcarli@gmail.com">marceloalcarli@gmail.com</a><br>
📱 Instagram: <a href="https://instagram.com/malcarli25" target="_blank">@malcarli25</a>

</div>
