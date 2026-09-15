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

O workflow do GitHub Actions usa um runner `macos-14`, seleciona o Xcode estável mais recente e executa uma compilação `Release` para `generic/platform=iOS` com `CODE_SIGNING_ALLOWED=NO` e `CODE_SIGNING_REQUIRED=NO`. Se a compilação for concluída, o workflow publica como artefatos o bundle `.app` e um pacote `.ipa` sem assinatura.

O `.ipa` produzido sem assinatura é um artefato de validação e não é instalável em um dispositivo. Para obter uma IPA instalável, é necessário compilar em um Mac com certificado e provisioning profile válidos, sem expor esses arquivos no repositório.

## Resultado observado

Foram feitas tentativas nos runners `macos-15` e `macos-14`. Ambas terminaram em aproximadamente dez segundos, antes do primeiro step, com `runner_id: 0`, `runner_name` vazio e nenhum step executado. Isso indica que o GitHub não alocou um runner macOS para este repositório/conta; portanto, o código não chegou a ser compilado pelo Actions. A execução mais recente é [34925829888](https://github.com/bts2019amo-ctrl/3105-proxy-system-ios-rebuild/actions/runs/34925829888).

## Resultado esperado

O resultado final da compilação automatizada ficará na aba **Actions** do novo repositório. Uma execução verde confirma que o código compila com o SDK iOS disponível no runner; ela não substitui a assinatura nem a validação em um dispositivo físico.
