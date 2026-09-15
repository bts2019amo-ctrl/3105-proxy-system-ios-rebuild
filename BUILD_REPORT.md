# Relatório de compilação

## Estado desta cópia

- Projeto: `3105` / `ThreeOneOSFive.xcodeproj`
- Plataforma: iOS
- Target de implantação: iOS 16.0
- Scheme: `3105`
- Código de assinatura: não incluído
- Workflow: `.github/workflows/build-ios.yml`

## Verificação local

A inspeção foi executada em um ambiente Linux sem `xcodebuild`, Swift ou SDKs Apple instalados. Por isso, não é possível gerar localmente um `.app`, `.ipa` ou `.xcarchive` neste ambiente. A compilação iOS precisa ser executada em macOS com Xcode.

## Compilação automatizada

O workflow do GitHub Actions usa um runner `macos-15`, seleciona o Xcode estável mais recente e executa uma compilação `Release` para `generic/platform=iOS` com `CODE_SIGNING_ALLOWED=NO` e `CODE_SIGNING_REQUIRED=NO`. Quando a compilação é concluída, o workflow publica como artefatos o bundle `.app` e um pacote `.ipa` sem assinatura.

O `.ipa` produzido sem assinatura é um artefato de validação e não é instalável em um dispositivo. Para obter uma IPA instalável, é necessário compilar em um Mac com certificado e provisioning profile válidos, sem expor esses arquivos no repositório.

## Resultado observado

A compilação foi concluída com sucesso no runner `macos-15` em aproximadamente 1 minuto e 53 segundos. Todos os steps passaram: seleção do Xcode, detecção do projeto, listagem do scheme, build sem assinatura, empacotamento da IPA e upload dos artefatos. A execução está disponível em [34925989420](https://github.com/bts2019amo-ctrl/3105-proxy-system-ios-rebuild/actions/runs/34925989420).

Artefatos gerados:

- `3105-unsigned.ipa`
- `3105.app`

Os artefatos não possuem assinatura de distribuição. A IPA precisa ser assinada com certificado e provisioning profile válidos antes da instalação em um dispositivo físico.

## Resultado esperado

Uma execução verde confirma que o código compila com o SDK iOS disponível no runner; ela não substitui a assinatura nem a validação em um dispositivo físico.
