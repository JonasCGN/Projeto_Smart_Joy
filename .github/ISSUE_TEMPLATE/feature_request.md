name: Solicitar Funcionalidade
description: Sugira uma ideia para melhorar o projeto!
title: "[IDEIA] Descreva a funcionalidade"
labels: [enhancement]
assignees: JonasCGN

body:
  - type: textarea
    id: descricao
    attributes:
      label: O que você gostaria de ver?
      description: Descreva sua ideia ou melhoria
      placeholder: "Seria legal se o app também fizesse..."
    validations:
      required: true

  - type: textarea
    id: motivacao
    attributes:
      label: Por que isso é útil?
      description: Diga como isso melhoraria o app ou resolveria um problema.
