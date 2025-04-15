# Contribuindo com o Projeto Smart Joy

Obrigado por querer contribuir com o **Smart Joy**! Este projeto é composto por dois aplicativos Flutter:

- **Joy Server (Windows Desktop)**: Servidor que controla o sistema.
- **Controle Smart Joy (Android)**: Controle remoto que se conecta via Wi-Fi ou Bluetooth.

Este guia vai te ajudar a configurar o projeto localmente, seguir boas práticas e colaborar com eficiência.

---

## 🧰 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Flutter](https://flutter.dev) 3.29.3
- [Visual Studio 2022+](https://visualstudio.microsoft.com/) com suporte para C++ e Windows SDK
- Android Studio (ou outro emulador Android)
- Git
- Chocolatey (Windows)

Para Windows:
```bash
choco install visualstudio2022buildtools
```

---

## 🚀 Rodando o projeto localmente

### Joy Server (Windows)
```bash
cd smart_joy
flutter pub get
cd native/bluetooth
build.bat     # Compila a DLL Bluetooth
cd ../..
flutter run -d windows
```

### Controle Smart Joy (Android)
```bash
cd controle_smart_joy
flutter pub get
flutter run -d android
```

> Crie um arquivo `.env` em cada pasta com as variáveis `API_PORT` e `API_KEY` para rodar corretamente.

---

## 📄 Padrão de Commits

Siga o [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: adicionar novo botão de pareamento
fix: corrigir erro no envio de comando
chore: ajustes gerais no layout
```

---

## 🔀 Como enviar Pull Requests

1. Crie uma branch: `git checkout -b minha-feature`
2. Faça os commits seguindo o padrão
3. Teste sua mudança localmente
4. Abra um Pull Request para `main`

Se possível, descreva no PR:
- O que foi feito
- Como testar
- Se afeta algo já existente

---

## 🧪 Testes

Atualmente não temos testes automatizados.
Valide manualmente suas alterações antes de abrir um PR.

---

## 🛠️ Estrutura dos diretórios

```
Projeto_Smart_Joy/
├── smart_joy/                # Joy Server Desktop
│   ├── lib/
│   ├── native/bluetooth/     # Código C++ da DLL
│   └── .env                  # Configurações locais
├── controle_smart_joy/       # App Android
│   └── .env
└── .github/workflows/        # CI com GitHub Actions
```

---

## 🙌 Contribuições bem-vindas!

Sugestões, melhorias, correções e novas ideias são super bem-vindas.
Sinta-se à vontade para abrir uma *issue* ou um *pull request* 💜

---

## 📫 Contato

Caso tenha dúvidas, você pode abrir uma [Issue](https://github.com/JonasCGN/Projeto_Smart_Joy/issues) ou entrar em contato diretamente pelo repositório.

---

Obrigado por contribuir para tornar o Smart Joy ainda melhor! 🚀
