/*****************************************************************************
 * PROGRAMA : XML_CRYPTO_SHA1.PRG                                            *
 * OBJETIVO : Assinatura XMLDSig RSA-SHA1 para documentos fiscais            *
 *            como NF-e/NFC-e, separado da rotina SHA256 do eSocial.         *
 *****************************************************************************/

FUNCTION FiscalSignSha1Hash( cHashBin, cSubject, cThumbprint )
RETURN __FiscalSignSha1Hash( cHashBin, hb_DefaultValue( cSubject, "" ), hb_DefaultValue( cThumbprint, "" ) )

FUNCTION FiscalCryptoLastError()
RETURN __FiscalCryptoLastError()

FUNCTION FiscalCertDer( cSubject, cThumbprint )
RETURN __FiscalCertDer( hb_DefaultValue( cSubject, "" ), hb_DefaultValue( cThumbprint, "" ) )

FUNCTION XmlSha1AssinarNFe( cXml, cSubject, cThumbprint )
   LOCAL cOut := XmlSha1RemoveSignature( cXml )
   LOCAL nInfStart, nInfEnd, nNFeEnd
   LOCAL cInfNFe, cId, cDigest, cSignedInfo, cSigBin, cSig64, cCertDer, cCert64, cSignature

   nInfStart := hb_At( "<infNFe", cOut )
   IF nInfStart == 0
      RETURN ""
   ENDIF

   nInfEnd := hb_At( "</infNFe>", cOut, nInfStart )
   IF nInfEnd == 0
      RETURN ""
   ENDIF
   nInfEnd += Len( "</infNFe>" ) - 1

   cInfNFe := SubStr( cOut, nInfStart, nInfEnd - nInfStart + 1 )
   cId := XmlSha1AttrValue( cInfNFe, "Id" )
   IF Empty( cId )
      RETURN ""
   ENDIF

   cDigest := hb_Base64Encode( XmlSha1HexToBin( hb_SHA1( cInfNFe ) ) )
   cSignedInfo := XmlSha1SignedInfoCanon( "#" + cId, cDigest )
   cSigBin := FiscalSignSha1Hash( XmlSha1HexToBin( hb_SHA1( cSignedInfo ) ), cSubject, cThumbprint )
   IF Empty( cSigBin )
      RETURN ""
   ENDIF

   cCertDer := FiscalCertDer( cSubject, cThumbprint )
   IF Empty( cCertDer )
      RETURN ""
   ENDIF

   cSig64 := XmlSha1OneLineBase64( hb_Base64Encode( cSigBin ) )
   cCert64 := XmlSha1OneLineBase64( hb_Base64Encode( cCertDer ) )
   cSignature := XmlSha1SignatureNode( "#" + cId, cDigest, cSig64, cCert64 )

   nNFeEnd := hb_RAt( "</NFe>", cOut )
   IF nNFeEnd == 0
      RETURN ""
   ENDIF

RETURN Left( cOut, nNFeEnd - 1 ) + cSignature + SubStr( cOut, nNFeEnd )

FUNCTION XmlSha1SignedInfoCanon( cReferenceUri, cDigest )
   LOCAL cXml
   cXml := '<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">'
   cXml += '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></CanonicalizationMethod>'
   cXml += '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></SignatureMethod>'
   cXml += '<Reference URI="' + cReferenceUri + '">'
   cXml += '<Transforms>'
   cXml += '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></Transform>'
   cXml += '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></Transform>'
   cXml += '</Transforms>'
   cXml += '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></DigestMethod>'
   cXml += '<DigestValue>' + cDigest + '</DigestValue>'
   cXml += '</Reference>'
   cXml += '</SignedInfo>'
RETURN cXml

FUNCTION XmlSha1SignedInfoNode( cReferenceUri, cDigest )
   LOCAL cXml
   cXml := '<SignedInfo>'
   cXml += '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
   cXml += '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>'
   cXml += '<Reference URI="' + cReferenceUri + '">'
   cXml += '<Transforms>'
   cXml += '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>'
   cXml += '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
   cXml += '</Transforms>'
   cXml += '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>'
   cXml += '<DigestValue>' + cDigest + '</DigestValue>'
   cXml += '</Reference>'
   cXml += '</SignedInfo>'
RETURN cXml

FUNCTION XmlSha1SignatureNode( cReferenceUri, cDigest, cSignature, cCert )
RETURN '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">' + XmlSha1SignedInfoNode( cReferenceUri, cDigest ) + '<SignatureValue>' + cSignature + '</SignatureValue><KeyInfo><X509Data><X509Certificate>' + cCert + '</X509Certificate></X509Data></KeyInfo></Signature>'

FUNCTION XmlSha1RemoveSignature( cXml )
   LOCAL nStart, nEnd, cOut := cXml
   DO WHILE ( nStart := hb_At( '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#"', cOut ) ) > 0
      nEnd := hb_At( "</Signature>", cOut, nStart )
      IF nEnd == 0
         EXIT
      ENDIF
      nEnd += Len( "</Signature>" ) - 1
      cOut := Left( cOut, nStart - 1 ) + SubStr( cOut, nEnd + 1 )
   ENDDO
RETURN cOut

FUNCTION XmlSha1AttrValue( cXml, cAttr )
   LOCAL nStart, nEnd
   nStart := hb_At( cAttr + '="', cXml )
   IF nStart == 0
      RETURN ""
   ENDIF
   nStart += Len( cAttr ) + 2
   nEnd := hb_At( '"', cXml, nStart )
RETURN SubStr( cXml, nStart, nEnd - nStart )

FUNCTION XmlSha1HexToBin( cHex )
   LOCAL cBin := "", nI
   FOR nI := 1 TO Len( cHex ) STEP 2
      cBin += Chr( hb_HexToNum( SubStr( cHex, nI, 2 ) ) )
   NEXT
RETURN cBin

FUNCTION XmlSha1OneLineBase64( cText )
RETURN StrTran( StrTran( AllTrim( cText ), Chr( 13 ), "" ), Chr( 10 ), "" )

#pragma BEGINDUMP

#include "hbapi.h"
#include "hbapiitm.h"

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <wincrypt.h>

#ifndef CRYPT_ACQUIRE_ALLOW_NCRYPT_KEY_FLAG
#define CRYPT_ACQUIRE_ALLOW_NCRYPT_KEY_FLAG 0x00010000
#endif

#ifndef CRYPT_ACQUIRE_PREFER_NCRYPT_KEY_FLAG
#define CRYPT_ACQUIRE_PREFER_NCRYPT_KEY_FLAG 0x00020000
#endif

#ifndef CERT_NCRYPT_KEY_SPEC
#define CERT_NCRYPT_KEY_SPEC 0xFFFFFFFF
#endif

#ifndef NCRYPT_PAD_PKCS1_FLAG
#define NCRYPT_PAD_PKCS1_FLAG 0x00000002
#endif

#ifndef ERROR_SUCCESS
#define ERROR_SUCCESS 0
#endif

typedef ULONG_PTR HB_FISCAL_NCRYPT_KEY_HANDLE;

typedef struct _HB_FISCAL_BCRYPT_PKCS1_PADDING_INFO
{
   LPCWSTR pszAlgId;
} HB_FISCAL_BCRYPT_PKCS1_PADDING_INFO;

typedef LONG HB_FISCAL_SECURITY_STATUS;
typedef HB_FISCAL_SECURITY_STATUS ( WINAPI * HB_FISCAL_NCRYPT_SIGN_HASH )( HB_FISCAL_NCRYPT_KEY_HANDLE, void *, BYTE *, DWORD, BYTE *, DWORD, DWORD *, DWORD );
typedef HB_FISCAL_SECURITY_STATUS ( WINAPI * HB_FISCAL_NCRYPT_FREE_OBJECT )( HB_FISCAL_NCRYPT_KEY_HANDLE );

static DWORD s_dwFiscalLastError = 0;
static char s_szFiscalLastStage[ 64 ] = "";

static void hb_fiscal_set_error( const char * pszStage )
{
   s_dwFiscalLastError = GetLastError();
   lstrcpynA( s_szFiscalLastStage, pszStage, sizeof( s_szFiscalLastStage ) );
}

static BOOL hb_fiscal_ncrypt_sign_sha1( HB_FISCAL_NCRYPT_KEY_HANDLE hKey, const BYTE * pbHash, DWORD cbHash )
{
   HMODULE hNCrypt = LoadLibraryA( "ncrypt.dll" );
   HB_FISCAL_NCRYPT_SIGN_HASH pNCryptSignHash;
   HB_FISCAL_BCRYPT_PKCS1_PADDING_INFO padding;
   DWORD cbSig = 0;
   BYTE * pbSig = NULL;
   HB_FISCAL_SECURITY_STATUS status;

   if( ! hNCrypt )
   {
      hb_fiscal_set_error( "LoadLibrary-ncrypt" );
      return FALSE;
   }

   pNCryptSignHash = ( HB_FISCAL_NCRYPT_SIGN_HASH ) GetProcAddress( hNCrypt, "NCryptSignHash" );
   if( ! pNCryptSignHash )
   {
      hb_fiscal_set_error( "GetProcAddress-NCryptSignHash" );
      FreeLibrary( hNCrypt );
      return FALSE;
   }

   padding.pszAlgId = L"SHA1";
   status = pNCryptSignHash( hKey, &padding, ( PBYTE ) pbHash, cbHash, NULL, 0, &cbSig, NCRYPT_PAD_PKCS1_FLAG );
   if( status != ERROR_SUCCESS || cbSig == 0 )
   {
      s_dwFiscalLastError = ( DWORD ) status;
      lstrcpynA( s_szFiscalLastStage, "NCryptSignHash-size", sizeof( s_szFiscalLastStage ) );
      FreeLibrary( hNCrypt );
      return FALSE;
   }

   pbSig = ( BYTE * ) hb_xgrab( cbSig );
   status = pNCryptSignHash( hKey, &padding, ( PBYTE ) pbHash, cbHash, pbSig, cbSig, &cbSig, NCRYPT_PAD_PKCS1_FLAG );
   if( status == ERROR_SUCCESS )
   {
      hb_retclen( ( const char * ) pbSig, cbSig );
      hb_xfree( pbSig );
      FreeLibrary( hNCrypt );
      return TRUE;
   }

   hb_xfree( pbSig );
   s_dwFiscalLastError = ( DWORD ) status;
   lstrcpynA( s_szFiscalLastStage, "NCryptSignHash-data", sizeof( s_szFiscalLastStage ) );
   FreeLibrary( hNCrypt );
   return FALSE;
}

static int hb_fiscal_hexval( char c )
{
   if( c >= '0' && c <= '9' ) return c - '0';
   if( c >= 'a' && c <= 'f' ) return c - 'a' + 10;
   if( c >= 'A' && c <= 'F' ) return c - 'A' + 10;
   return -1;
}

static int hb_fiscal_thumbprint_to_bytes( const char * pszHex, BYTE * out, DWORD * pcbOut )
{
   DWORD n = 0;
   int hi = -1;

   while( pszHex && *pszHex )
   {
      int v = hb_fiscal_hexval( *pszHex++ );
      if( v < 0 )
         continue;

      if( hi < 0 )
         hi = v;
      else
      {
         if( n >= *pcbOut )
            return 0;
         out[ n++ ] = ( BYTE ) ( ( hi << 4 ) | v );
         hi = -1;
      }
   }

   if( hi >= 0 )
      return 0;

   *pcbOut = n;
   return n > 0;
}

static PCCERT_CONTEXT hb_fiscal_find_cert( HCERTSTORE hStore, const char * pszSubject, const char * pszThumb )
{
   PCCERT_CONTEXT pCert = NULL;

   if( pszThumb && pszThumb[ 0 ] )
   {
      BYTE hash[ 64 ];
      DWORD cbHash = sizeof( hash );
      CRYPT_HASH_BLOB blob;

      if( ! hb_fiscal_thumbprint_to_bytes( pszThumb, hash, &cbHash ) )
         return NULL;

      blob.cbData = cbHash;
      blob.pbData = hash;
      return CertFindCertificateInStore( hStore, X509_ASN_ENCODING | PKCS_7_ASN_ENCODING, 0,
                                         CERT_FIND_HASH, &blob, NULL );
   }

   while( ( pCert = CertEnumCertificatesInStore( hStore, pCert ) ) != NULL )
   {
      char subject[ 2048 ];
      DWORD cbInfo = 0;
      DWORD len = CertGetNameStringA( pCert, CERT_NAME_SIMPLE_DISPLAY_TYPE, 0, NULL, subject, sizeof( subject ) );
      CertGetCertificateContextProperty( pCert, CERT_KEY_PROV_INFO_PROP_ID, NULL, &cbInfo );
      if( len > 1 && cbInfo > 0 )
      {
         if( pszSubject && pszSubject[ 0 ] )
         {
            if( strstr( subject, pszSubject ) != NULL )
               return CertDuplicateCertificateContext( pCert );
         }
         else if( strstr( subject, "LTDA" ) != NULL ||
                  strstr( subject, "CNPJ" ) != NULL ||
                  strstr( subject, "e-CNPJ" ) != NULL ||
                  strstr( subject, "E-CNPJ" ) != NULL )
            return CertDuplicateCertificateContext( pCert );
      }
   }

   return NULL;
}

HB_FUNC( __FISCALSIGNSHA1HASH )
{
   const BYTE * pbHash = ( const BYTE * ) hb_parc( 1 );
   DWORD cbHash = ( DWORD ) hb_parclen( 1 );
   const char * pszSubject = hb_parc( 2 );
   const char * pszThumb = hb_parc( 3 );
   HCERTSTORE hStore = NULL;
   PCCERT_CONTEXT pCert = NULL;
   ULONG_PTR hKey = 0;
   DWORD dwKeySpec = 0;
   BOOL fCallerFree = FALSE;
   HCRYPTHASH hHash = 0;
   DWORD cbSig = 0;
   BYTE * pbSig = NULL;
   BOOL ok = FALSE;

   if( cbHash != 20 )
   {
      s_dwFiscalLastError = 0;
      lstrcpynA( s_szFiscalLastStage, "hash-size", sizeof( s_szFiscalLastStage ) );
      hb_retc_null();
      return;
   }

   hStore = CertOpenStore( CERT_STORE_PROV_SYSTEM_A, 0, 0,
                           CERT_SYSTEM_STORE_CURRENT_USER | CERT_STORE_READONLY_FLAG, "MY" );
   if( ! hStore )
   {
      hb_fiscal_set_error( "CertOpenStore" );
      hb_retc_null();
      return;
   }

   pCert = hb_fiscal_find_cert( hStore, pszSubject, pszThumb );
   if( ! pCert )
      hb_fiscal_set_error( "find-cert" );
   if( pCert &&
       CryptAcquireCertificatePrivateKey( pCert, CRYPT_ACQUIRE_COMPARE_KEY_FLAG | CRYPT_ACQUIRE_ALLOW_NCRYPT_KEY_FLAG | CRYPT_ACQUIRE_PREFER_NCRYPT_KEY_FLAG,
                                          NULL, ( HCRYPTPROV * ) &hKey, &dwKeySpec, &fCallerFree ) )
   {
      if( dwKeySpec == CERT_NCRYPT_KEY_SPEC )
      {
         ok = hb_fiscal_ncrypt_sign_sha1( ( HB_FISCAL_NCRYPT_KEY_HANDLE ) hKey, pbHash, cbHash );
      }
      else
      {
         HCRYPTPROV hProv = ( HCRYPTPROV ) hKey;
         if( CryptCreateHash( hProv, CALG_SHA1, 0, 0, &hHash ) )
         {
            if( CryptSetHashParam( hHash, HP_HASHVAL, ( BYTE * ) pbHash, 0 ) )
            {
               if( CryptSignHashA( hHash, dwKeySpec, NULL, 0, NULL, &cbSig ) && cbSig > 0 )
               {
                  pbSig = ( BYTE * ) hb_xgrab( cbSig );
                  if( CryptSignHashA( hHash, dwKeySpec, NULL, 0, pbSig, &cbSig ) )
                  {
                     DWORD i;
                     for( i = 0; i < cbSig / 2; ++i )
                     {
                        BYTE tmp = pbSig[ i ];
                        pbSig[ i ] = pbSig[ cbSig - 1 - i ];
                        pbSig[ cbSig - 1 - i ] = tmp;
                     }
                     hb_retclen( ( const char * ) pbSig, cbSig );
                     ok = TRUE;
                  }
                  else
                     hb_fiscal_set_error( "CryptSignHash-data" );
                  hb_xfree( pbSig );
               }
               else
                  hb_fiscal_set_error( "CryptSignHash-size" );
            }
            else
               hb_fiscal_set_error( "CryptSetHashParam" );
            CryptDestroyHash( hHash );
         }
         else
            hb_fiscal_set_error( "CryptCreateHash-SHA1" );
      }
   }
   else if( pCert )
      hb_fiscal_set_error( "CryptAcquireCertificatePrivateKey" );

   if( fCallerFree && hKey )
   {
      if( dwKeySpec == CERT_NCRYPT_KEY_SPEC )
      {
         HMODULE hNCrypt = LoadLibraryA( "ncrypt.dll" );
         if( hNCrypt )
         {
            HB_FISCAL_NCRYPT_FREE_OBJECT pNCryptFreeObject = ( HB_FISCAL_NCRYPT_FREE_OBJECT ) GetProcAddress( hNCrypt, "NCryptFreeObject" );
            if( pNCryptFreeObject )
               pNCryptFreeObject( ( HB_FISCAL_NCRYPT_KEY_HANDLE ) hKey );
            FreeLibrary( hNCrypt );
         }
      }
      else
         CryptReleaseContext( ( HCRYPTPROV ) hKey, 0 );
   }

   if( pCert )
      CertFreeCertificateContext( pCert );
   if( hStore )
      CertCloseStore( hStore, 0 );

   if( ! ok )
      hb_retc_null();
}

HB_FUNC( __FISCALCRYPTOLASTERROR )
{
   char buffer[ 128 ];
   wsprintfA( buffer, "%s:%lu", s_szFiscalLastStage, ( unsigned long ) s_dwFiscalLastError );
   hb_retc( buffer );
}

HB_FUNC( __FISCALCERTDER )
{
   const char * pszSubject = hb_parc( 1 );
   const char * pszThumb = hb_parc( 2 );
   HCERTSTORE hStore = CertOpenStore( CERT_STORE_PROV_SYSTEM_A, 0, 0,
                                      CERT_SYSTEM_STORE_CURRENT_USER | CERT_STORE_READONLY_FLAG, "MY" );
   PCCERT_CONTEXT pCert = NULL;

   if( ! hStore )
   {
      hb_fiscal_set_error( "CertOpenStore" );
      hb_retc_null();
      return;
   }

   pCert = hb_fiscal_find_cert( hStore, pszSubject, pszThumb );
   if( pCert )
   {
      hb_retclen( ( const char * ) pCert->pbCertEncoded, pCert->cbCertEncoded );
      CertFreeCertificateContext( pCert );
   }
   else
   {
      hb_fiscal_set_error( "find-cert" );
      hb_retc_null();
   }

   CertCloseStore( hStore, 0 );
}

#pragma ENDDUMP
