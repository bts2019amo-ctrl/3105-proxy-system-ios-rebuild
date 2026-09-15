# Migração da API de licença iOS

**Data:** 15 de setembro de 2026
**Aplicativo:** 3105
**Escopo:** somente o módulo de validação da licença

## Alteração realizada

A API temporária anteriormente usada pelo aplicativo foi removida. O `LicenseManager`, localizado em `ThreeOneOSFive/App.swift`, passou a consultar a API oficial do Proxy System:

```text
https://proxysystem.org/api/trpc/proxyKeys.publicCheckKey
```

O formato da chamada continua sendo `GET` com o parâmetro tRPC `input`. Nenhuma chave secreta administrativa foi incluída no aplicativo.

O aplicativo agora cria um identificador aleatório e estável para a instalação. Esse identificador é salvo no Keychain do iOS com proteção `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` e enviado como `deviceId` em cada validação. A chave de licença continua sendo salva no Keychain como antes.

## Comportamento esperado

Uma chave iOS criada no painel do Proxy System é validada conforme seu estado e sua data de expiração. Chaves inexistentes, pendentes, expiradas ou revogadas são recusadas. A resposta inclui a data de expiração e o tempo restante.

A proteção de uma chave por dispositivo depende do patch complementar do backend. Esse patch foi preparado localmente, mas não foi publicado na VPS. Depois que ele for publicado, a primeira instalação que validar a chave ficará vinculada ao seu `deviceId`. Uma tentativa posterior em outro aparelho será recusada. O comando existente de redefinição de IP no painel também limpará o vínculo do aparelho.

## Validações executadas

A API oficial respondeu com HTTP `200` e o formato tRPC esperado durante um teste com uma chave fictícia inexistente. O código não contém mais o domínio temporário nem a procedure da plataforma anterior no módulo de licença. O parser existente aceita os campos retornados pela API do Proxy System, incluindo `success`, `status`, `expiresAt`, `daysRemaining`, `daysLeft`, `remainingSeconds`, `secondsLeft`, `message` e `reason`.

## Limitação do pacote recebido

O ZIP recebido não continha um arquivo `.ipa`, `.app` ou `.xcarchive`. Ele continha o projeto-fonte Xcode. O próprio `BUILD_REPORT.md` informa que a compilação não foi feita porque o ambiente original era Linux. Esta entrega contém, portanto, o **código-fonte atualizado**, não uma IPA assinada.

Para produzir a IPA instalável, o projeto deve ser compilado em um Mac com Xcode e assinado com um certificado/perfil apropriado. Nenhum arquivo foi enviado ao site ou à VPS durante esta alteração.
