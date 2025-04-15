name: Reportar Bug
description: Algo não está funcionando como esperado? Relate aqui!
title: "[BUG] Descreva o problema"
labels: [bug]
assignees: JonasCGN

body:
  - type: textarea
    id: descreva-o-bug
    attributes:
      label: Descrição do bug
      description: Descreva claramente o problema.
      placeholder: "O que está acontecendo..."
    validations:
      required: true

  - type: textarea
    id: passos
    attributes:
      label: Passos para reproduzir
      description: Como podemos reproduzir o problema?
      placeholder: |
        1. Vá até...
        2. Clique em...
        3. Veja o erro...
      value: ""
    validations:
      required: true

  - type: input
    id: sistema
    attributes:
      label: Sistema Operacional
      placeholder: ex: Windows 11, Android 13
    validations:
      required: true

  - type: input
    id: versao
    attributes:
      label: Versão do app
      placeholder: ex: v1.0.2