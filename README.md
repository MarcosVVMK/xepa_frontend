# 📱 Xepa - Frontend (Aplicativo Móvel / Multiplataforma)

> **Trabalho de Conclusão de Curso (TCC)**  
> Curso Superior de Tecnologia em Análise e Desenvolvimento de Sistemas  
> Instituto Federal de Educação, Ciência e Tecnologia de Goiás (IFG) - Câmpus Jataí

---

## 📌 Sobre o Projeto

O **Xepa** é um aplicativo móvel e multiplataforma desenvolvido para permitir que consumidores consultem e comparem preços de produtos em supermercados locais, encontrem o menor valor total para suas listas de compras e cadastrem novos preços via leitura de QR Code de Notas Fiscais Eletrônicas (NFC-e).

Este repositório contém o **módulo Frontend**, construído em Flutter e estruturado utilizando os princípios da **Clean Architecture** e **Feature-Driven Development**.

### 🎓 Informações Acadêmicas

* **Título do TCC:** Xepa: Plataforma de Comparação de Preços de Produtos em Supermercados Locais
* **Autor:** Marcos Vinícius Vieira Matos
* **Instituição:** Instituto Federal de Educação, Ciência e Tecnologia de Goiás (IFG) - Câmpus Jataí
* **Departamento:** Departamento de Áreas Acadêmicas
* **Curso:** Tecnologia em Análise e Desenvolvimento de Sistemas (TADS)
* **Orientador:** Prof. Dr. Flávio de Assis Vilela
* **Banca Examinadora:**
  * Prof. Dr. Leizer Fernandes Moraes
  * Prof. Me. Murilo de Assis Silva
* **Data:** Julho de 2026

---

## 🛠️ Tecnologias e Bibliotecas Utilizadas

* **Linguagem:** Dart (SDK 3.11+)
* **Framework:** Flutter
* **Arquitetura:** Clean Architecture (Domain, Data, Presentation)
* **Gerenciamento de Requisições HTTP:** Dio
* **Injeção de Dependências:** GetIt
* **Leitor de QR Code / NFC-e:** Mobile Scanner
* **Mapas e Geolocalização:** Flutter Map, LatLong2, Geocoding
* **Armazenamento Seguro Local:** Flutter Secure Storage
* **Variáveis de Ambiente:** Flutter Dotenv
* **Modelagem Imutável / Programação Funcional:** Dartz, Equatable
* **Testes Automatizados:** Flutter Test, Mockito

---

## 📋 Pré-requisitos

Antes de executar o aplicativo, certifique-se de possuir:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado e configurado (`flutter doctor` sem erros).
* [Android Studio](https://developer.android.com/studio) ou [VS Code](https://code.visualstudio.com/) com as extensões do Flutter e Dart.
* Emulador Android/iOS ou dispositivo físico com modo de depuração USB ativado.

---

## ⚙️ Configuração do Ambiente

1. **Navegar até a pasta do frontend:**
   ```bash
   cd frontend
   ```

2. **Configurar o Arquivo `.env`:**
   Crie ou edite o arquivo `.env` na raiz do diretório `frontend` indicando o endereço da API Backend:

   ```env
   # Apontando para a API de produção no Railway:
   API_BASE_URL=https://xepabackend-production.up.railway.app/api/v1

   # Para conectar com a API rodando localmente no Android Emulator:
   # API_BASE_URL=http://10.0.2.2:8080/api/v1
   ```

3. **Instalar as Dependências:**
   ```bash
   flutter pub get
   ```

---

## 🚀 Como Rodar o Aplicativo

1. **Listar os dispositivos/emuladores disponíveis:**
   ```bash
   flutter devices
   ```

2. **Executar o aplicativo:**
   * No dispositivo ou emulador padrão:
     ```bash
     flutter run
     ```
   * Em um dispositivo específico ou no navegador Web (Chrome):
     ```bash
     flutter run -d chrome
     ```

---

## 🧪 Executando os Testes Automatizados

O frontend conta com 150 testes unitários que garantem a integridade dos modelos, entidades, casos de uso e gerenciamento de erros. Para executar a suíte completa de testes:

```bash
flutter test
```

---

## 📄 Licença e Uso

Este projeto foi desenvolvido estritamente para fins acadêmicos como parte do Trabalho de Conclusão de Curso (TCC) no Instituto Federal de Goiás (IFG) - Câmpus Jataí.
