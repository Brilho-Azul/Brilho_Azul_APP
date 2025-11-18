##  Funcionalidades

**Login Seguro:** Autenticação via E-mail e Senha usando Firebase Authentication.
**Cadastro Completo:** Registro de novos usuários capturando dados extras (Nome e Sobrenome).
**Armazenamento em Nuvem:** Persistência dos dados do usuário (além do login) utilizando Cloud Firestore.
**Feedback Visual:** Indicadores de carregamento e mensagens de erro/sucesso (Snackbars) para melhor UX.
**Navegação Inteligente:** Redirecionamento automático e proteção de rotas.
**Boas Práticas:** Código limpo, separado em arquivos de responsabilidade única.

##  Tecnologias Utilizadas

* **[Flutter](https://flutter.dev/)** - Framework de UI do Google.
* **[Firebase Auth](https://firebase.google.com/docs/auth)** - Gerenciamento de identidade.
* **[Cloud Firestore](https://firebase.google.com/docs/firestore)** - Banco de dados NoSQL em tempo real.
* **Dart** - Linguagem de programação.

##  Pré-requisitos

Para rodar este projeto, você precisa ter instalado:

1.  **Flutter SDK** (versão estável mais recente).
2.  **Java JDK 17** (Essencial para compatibilidade com o Gradle moderno).
    * *Nota:* Evite Java 21 ou 8 para este projeto.
3.  Um dispositivo Android (físico ou emulador) configurado.


2. Configuração do Firebase
Este projeto requer suas próprias credenciais do Firebase:

* Crie um projeto no Firebase Console.

* Ative o Authentication (Provedor de E-mail/Senha).

* Ative o Firestore Database (Inicie em modo de teste).

* Instale o CLI do flutterfire e configure o projeto:

```bash
flutterfire configure
(Isso irá gerar o arquivo lib/firebase_options.dart e configurar o Android).
```

## 3. Instale as Dependências
No terminal, na raiz do projeto:
```bash
flutter pub get
```
## 4. Executar
```bash

flutter run
📂 Estrutura do Projeto
lib/
├── main.dart           # Inicialização do App e Firebase
├── firebase_options.dart # Configuração gerada (NÃO EDITE)
├── login_screen.dart   # Tela de Login
├── signup_screen.dart  # Tela de Cadastro (Auth + Firestore)
└── home_screen.dart    # Tela de Boas-vindas (Logout)

```


Solução de Problemas Comuns (Windows)
```bash
Se você encontrar erros de build (Gradle/Kotlin):

Erro de "PigeonUserDetails" ou "Source value 8":

Certifique-se de que está usando o Java 17.

Verifique se o JAVA_HOME nas variáveis de ambiente aponta para a pasta do JDK 17.

Erro de "File Path" ou "Directory not found":

Verifique se a pasta do projeto não tem espaços no nome (ex: Evite Meus Projetos, use MeusProjetos).
