# Projeto Principal - Joy System

Este projeto reúne dois aplicativos Flutter:

- **controle_smart_joy**: O cliente que envia comandos.
- **smart_joy**: O servidor Bluetooth que responde aos comandos.

## Estrutura

```
main_project/
├── controle_smart_joy/   # Cliente Flutter
├── smart_joy/            # Servidor Bluetooth Flutter
```

## Requisitos

- Android SDK
- Flutter SDK
- Dispositivos Android com suporte a Bluetooth

## Como Usar

1. Compile e instale `smart_joy` em um dispositivo servidor.
2. Compile e instale `controle_smart_joy` no dispositivo cliente.
3. Emparelhe os dispositivos via Bluetooth.
4. Use o app cliente para escanear e conectar ao servidor.
