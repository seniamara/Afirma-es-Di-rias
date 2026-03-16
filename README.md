# 🌸 **Afirmações Diárias**

<div align="center">
  <img src="assets/logo.png" alt="Afirmações Diárias Logo" width="120"/>
  <h3>Transforme sua mente, uma afirmação por dia</h3>
  <p>
    <a href="https://github.com/seu-usuario/positive_now/issues">Reportar Bug</a>
    ·
    <a href="https://github.com/seu-usuario/positive_now/issues">Solicitar Funcionalidade</a>
  </p>
</div>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.22+-blue?logo=flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.4+-blue?logo=dart"/>
  <img src="https://img.shields.io/badge/Firebase-✓-orange?logo=firebase"/>
  <img src="https://img.shields.io/badge/License-MIT-green"/>
  <img src="https://img.shields.io/badge/Platform-Android%20|%20iOS-brightgreen"/>
  <img src="https://img.shields.io/badge/Idiomas-4%20línguas-ff69b4"/>
</p>

---

## 📱 **Sobre o Projeto**

**Afirmações Diárias** é um aplicativo mobile desenvolvido em Flutter que oferece afirmações positivas diárias para promover o bem-estar emocional e o autoconhecimento. Com uma interface moderna e intuitiva, o app ajuda os usuários a manter uma mentalidade positiva através de afirmações inspiradoras, registro de humor e acompanhamento de progresso.

### ✨ **Funcionalidades Principais**

| Funcionalidade | Descrição |
|----------------|-----------|
| 🏠 **Tela Inicial** | Afirmação do dia com card interativo e check-in de humor diário |
| 📚 **Biblioteca** | Categorias temáticas, favoritos e histórico de visualizações |
| 📊 **Progresso** | Gráficos de humor, streak diário e estatísticas completas |
| 👤 **Perfil** | Configurações, tema claro/escuro e seletor de idiomas |
| 🌐 **Internacionalização** | Suporte a 4 idiomas: PT, EN, DE, FR |
| 🔐 **Autenticação** | Login anônimo ou por email/senha com Firebase |

---

## 🎨 **Design e UX**

O aplicativo foi projetado com foco em:

- **Interface limpa e moderna** com gradientes suaves
- **Animações fluidas** para melhor experiência do usuário
- **Cores suaves e acolhedoras** (rosa claro como principal)
- **Feedback visual** em todas as interações
- **Design responsivo** para diferentes tamanhos de tela

### **Paleta de Cores**
```dart
static const Color primaryPink = Color(0xFFFFB6C1);  // Rosa claro
static const Color darkPink = Color(0xFFFF69B4);     // Rosa escuro
static const Color background = Color(0xFF121212);    // Fundo escuro
static const Color lightBackground = Color(0xFFF5F5F5); // Fundo claro
```

---

## 📸 **Screenshots**

<div align="center">
  <table>
    <tr>
      <td><img src="assets/screenshots/home.jpg" width="200" alt="Tela Inicial"/></td>
      <td><img src="assets/screenshots/library.jpg" width="200" alt="Biblioteca"/></td>
      <td><img src="assets/screenshots/progress.jpg" width="200" alt="Progresso"/></td>
      <td><img src="assets/screenshots/profile.jpg" width="200" alt="Perfil"/></td>
    </tr>
    <tr>
      <td align="center"><b>Tela Inicial</b></td>
      <td align="center"><b>Biblioteca</b></td>
      <td align="center"><b>Progresso</b></td>
      <td align="center"><b>Perfil</b></td>
    </tr>
    <tr>
      <td><img src="assets/screenshots/login.jpg" width="200" alt="Login"/></td>
      <td><img src="assets/screenshots/onboarding.jpg" width="200" alt="Onboarding"/></td>
      <td><img src="assets/screenshots/detail.jpg" width="200" alt="Detalhe"/></td>
      <td><img src="assets/screenshots/languages.jpg" width="200" alt="Idiomas"/></td>
    </tr>
    <tr>
      <td align="center"><b>Login</b></td>
      <td align="center"><b>Onboarding</b></td>
      <td align="center"><b>Detalhe</b></td>
      <td align="center"><b>Idiomas</b></td>
    </tr>
  </table>
</div>

---

## 🚀 **Começando**

### **Pré-requisitos**

- Flutter SDK (^3.22.0)
- Dart SDK (^3.4.0)
- Android Studio / VS Code
- Conta no Firebase
- Chave de API da [API Ninjas](https://api-ninjas.com/)

### **Instalação**

1. **Clone o repositório**
```bash
git clone https://github.com/seniamara/Afirma-es-Di-rias.git
cd positive_now
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure o Firebase**

   **Android:**
   - Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
   - Adicione um aplicativo Android com package name `com.seuapp.positive_now`
   - Baixe o arquivo `google-services.json` e coloque em `android/app/`
   
   **iOS:**
   - Adicione um aplicativo iOS com bundle ID `com.seuapp.positiveNow`
   - Baixe o arquivo `GoogleService-Info.plist` e coloque em `ios/Runner/`
   
   **Ative os serviços:**
   - Authentication (Anônimo e Email/Senha)
   - Firestore Database

4. **Configure a API de Citações**

   - Acesse [API Ninjas](https://api-ninjas.com/)
   - Crie uma conta gratuita
   - Obtenha sua API Key
   - Adicione no arquivo `lib/services/api_ninjas_service.dart`:
   ```dart
   static const String _apiKey = 'SUA_CHAVE_AQUI';
   ```

5. **Execute o aplicativo**
```bash
flutter run
```

### **Configuração do Firestore**

#### **Regras de Segurança (Desenvolvimento)**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🏗️ **Arquitetura**

O aplicativo segue o padrão **MVVM (Model-View-ViewModel)** com **Provider** para gerenciamento de estado.

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    View     │────▶│  ViewModel  │────▶│    Model    │
│  (Widgets)  │◀────│  (Provider) │◀────│   (Dados)   │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │                    │
       ▼                   ▼                    ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Services  │     │  Locale/    │     │  Firebase   │
│  (API/DB)   │     │   Theme     │     │   /Local    │
└─────────────┘     └─────────────┘     └─────────────┘
```

### **Providers Principais**

| Provider | Responsabilidade |
|----------|------------------|
| `AfirmacaoProvider` | Gerenciar afirmações, favoritos e histórico |
| `AuthProvider` | Autenticação e dados do usuário |
| `ThemeProvider` | Alternância entre tema claro/escuro |
| `LocaleProvider` | Gerenciamento de idioma |

---

## 🌐 **API e Integrações**

### **API Ninjas Quotes**

- **Endpoint**: `https://api.api-ninjas.com/v2/randomquotes`
- **Método**: GET
- **Headers**: `X-Api-Key: SUA_CHAVE`

#### **Exemplo de Requisição**
```dart
final response = await http.get(
  Uri.parse('https://api.api-ninjas.com/v2/randomquotes'),
  headers: {'X-Api-Key': _apiKey},
);
```

#### **Exemplo de Resposta**
```json
[
  {
    "quote": "O caminho para o sucesso começa com o conhecimento...",
    "author": "Savana China",
    "category": "success"
  }
]
```

### **Firebase Services**

- **Authentication**: Login anônimo e por email/senha
- **Firestore**: Armazenamento de preferências e dados do usuário

#### **Estrutura do Firestore**
```
users/
  └── {userId}/
      ├── onboardingComplete: boolean
      ├── selectedAreas: array
      ├── preferredTime: string
      ├── afirmacoes_cache/
      │   └── {afirmacaoId}
      ├── favoritos/
      │   └── {afirmacaoId}
      └── humor/
          └── {registroId}
```

---

## 🌍 **Internacionalização**

O app suporta 4 idiomas usando arquivos JSON e o pacote `flutter_localizations`.

### **Idiomas Disponíveis**

| Bandeira | Código | Idioma |
|----------|--------|--------|
| 🇧🇷 | `pt` | Português |
| 🇺🇸 | `en` | Inglês |
| 🇩🇪 | `de` | Alemão |
| 🇫🇷 | `fr` | Francês |

### **Estrutura dos Arquivos de Tradução**
```json
{
  "app_name": "Afirmações Diárias",
  "welcome": "Bem-vindo ao\nAfirmações Diárias",
  "login": "Entrar",
  "logout": "Sair da conta",
  // ... mais de 150 chaves de tradução
}
```

### **Uso no Código**
```dart
// Obter o texto traduzido
Text(AppLocalizations.of(context).translate('welcome_back'))

// Com parâmetros
Text('${localizations.translate('viewed')} ${_formatarTempo(data)}')
```

---

## 📁 **Estrutura do Projeto**

```
positive_now/
├── android/                   # Configurações Android
├── ios/                       # Configurações iOS
├── assets/
│   └── translations/          # Arquivos de tradução
│       ├── pt.json
│       ├── en.json
│       ├── de.json
│       └── fr.json
├── lib/
│   ├── app/                   # Telas do aplicativo
│   │   ├── auth/              # Telas de autenticação
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── biblioteca.dart
│   │   ├── home.dart
│   │   ├── onboarding.dart
│   │   ├── perfil.dart
│   │   ├── progresso.dart
│   │   └── splash_screen.dart
│   ├── l10n/                  # Internacionalização
│   │   └── app_localizations.dart
│   ├── models/                # Modelos de dados
│   │   └── models.dart
│   ├── providers/             # Gerenciamento de estado
│   │   ├── afirmacao_provider.dart
│   │   ├── auth_provider.dart
│   │   ├── locale_provider.dart
│   │   └── theme_provider.dart
│   ├── services/              # Serviços externos
│   │   ├── api_ninjas_service.dart
│   │   └── firebase_service.dart
│   ├── theme/                 # Configurações de tema
│   │   └── app_theme.dart
│   ├── widgets/               # Componentes reutilizáveis
│   │   └── gradient_button.dart
│   ├── firebase_options.dart
│   └── main.dart
├── test/                       # Testes unitários
├── .gitignore
├── pubspec.yaml
└── README.md
```

---

## 🧪 **Testes**

```bash
# Executar todos os testes
flutter test

# Executar testes com cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📝 **Licença**

Este projeto está licenciado sob a **MIT License** - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

## 👥 **Contribuição**

### **Como Contribuir**

1. **Fork o projeto**
2. **Crie uma branch**
```bash
git checkout -b feature/nova-funcionalidade
```
3. **Commit suas mudanças**
```bash
git commit -m '✨ feat: adiciona nova funcionalidade'
```
4. **Push para a branch**
```bash
git push origin feature/nova-funcionalidade
```
5. **Abra um Pull Request**

### **Padrões de Commit**
- `✨ feat:` - Nova funcionalidade
- `🐛 fix:` - Correção de bug
- `📚 docs:` - Documentação
- `💄 style:` - Estilo de código
- `♻️ refactor:` - Refatoração
- `✅ test:` - Testes
- `🔧 chore:` - Tarefas de manutenção

---

## 📞 **Contato**

- **Desenvolvedor**: (https://github.com/seniamara/)
- **Email**: seniamaraa@gmail.com
- **LinkedIn**: [www.linkedin.com/in/seniamara-benedito-04630731b](https://www.linkedin.com/in/seniamara-benedito-04630731b/)

---

## 📦 **Versões**

| Versão | Data | Principais Mudanças |
|--------|------|---------------------|
| 1.0.0 | Mar/2026 | Lançamento inicial |

---

## 🔗 **Links Úteis**

- [Documentação do Flutter](https://docs.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [API Ninjas](https://api-ninjas.com/)
- [Provider Package](https://pub.dev/packages/provider)

---

<div align="center">
  <h3>✨ Obrigado por fazer parte desta jornada! ✨</h3>
  <img src="assets/lotus.png" width="60"/>
  <p>Desenvolvido com ❤️ e ☕</p>
  <p>
    <a href="https://github.com/seu-usuario/positive_now">GitHub</a> •
    <a href="https://pub.dev/packages">Pub.dev</a> •
    <a href="https://flutter.dev">Flutter</a>
  </p>
  <p>© 2026 Afirmações Diárias. Todos os direitos reservados.</p>
</div>
```

## 📝 **Como criar o README.md**

1. **Crie o arquivo na raiz do projeto:**
```bash
touch README.md
```

2. **Abra o arquivo no seu editor e cole o conteúdo acima**

3. **Personalize com suas informações:**
   - Substitua `seu-usuario` pelo seu nome de usuário do GitHub
   - Adicione seu email e redes sociais
   - Coloque suas screenshots na pasta `assets/screenshots/`
   - Adicione um logo na pasta `assets/logo.png`

4. **Commit e push:**
```bash
git add README.md
git commit -m "📚 docs: adiciona README completo com documentação"
git push
```
