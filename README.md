# FindU Admin - Sistema de Gestão de Ensalamento

Sistema administrativo web para gerenciamento completo do sistema de ensalamento FindU.

## 📋 Funcionalidades

### 🎯 Gestão de Estudantes
- ✅ Cadastro de novos estudantes
- ✅ Edição de dados dos estudantes
- ✅ Exclusão de estudantes
- ✅ Filtros por curso, semestre e turno
- ✅ Busca por nome ou email

### 🏢 Gestão de Salas
- ✅ Cadastro de novas salas
- ✅ Edição de informações das salas
- ✅ Exclusão de salas
- ✅ Configuração de equipamentos
- ✅ Filtros por prédio e tipo de sala

### �� Gestão de Cursos
- ✅ Cadastro de cursos
- ✅ Edição de cursos
- ✅ Configuração de semestres e turnos
- ✅ Filtros por turno
- ✅ Busca por nome ou código

### ⏰ Gestão de Horários (ENSALAMENTO SEMANAL)
- ✅ **Grade semanal visual** - Visualização completa da semana
- ✅ **Criação de horários** - Alocação de salas por horário
- ✅ **Detecção de conflitos** - Evita dupla alocação de salas
- ✅ **Horários padronizados** - 7 horários pré-definidos
- ✅ **Alocação por curso e semestre** - Organização por turma
- ✅ **Interface intuitiva** - Clique para alocar, cores por curso
- ✅ **Lista detalhada** - Visualização em lista agrupada por curso

## 🎯 **FUNCIONALIDADE PRINCIPAL: ENSALAMENTO SEMANAL**

### Como Funciona o Ensalamento:

1. **Grade Visual**: Visualize toda a semana em formato de tabela
   - **Linhas**: 7 horários (07:00 às 22:30)
   - **Colunas**: Dias da semana (Segunda a Sábado)
   - **Células**: Mostram as aulas alocadas ou botão para adicionar

2. **Alocação Inteligente**:
   - Selecione disciplina, professor, curso e semestre
   - Escolha dia da semana e horário
   - Selecione a sala disponível
   - Sistema detecta conflitos automaticamente

3. **Detecção de Conflitos**:
   - ❌ Impede alocação de sala já ocupada no mesmo horário
   - ✅ Mostra salas disponíveis com capacidade
   - 🎨 Cores diferentes para cada curso

4. **Exemplo de Uso**:
   ```
   Segunda-feira, 1º Horário (07:00-08:40):
   - Sala 101: Matemática I - Engenharia Civil (1º Semestre)
   - Sala 102: Algoritmos - Sistemas de Informação (2º Semestre)
   
   Segunda-feira, 2º Horário (08:50-10:30):
   - Sala 101: Física I - Engenharia Civil (1º Semestre)
   - Sala 102: Banco de Dados - Sistemas de Informação (3º Semestre)
   ```

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK (versão 3.4.4 ou superior)
- Dart SDK
- Navegador web (Chrome recomendado)

### Instalação
1. Clone o repositório
2. Navegue até a pasta do projeto administrativo:
   ```bash
   cd findu_admin
   ```
3. Instale as dependências:
   ```bash
   flutter pub get
   ```
4. Execute o projeto:
   ```bash
   flutter run -d chrome
   ```

## 🔐 Autenticação

O sistema utiliza autenticação via Supabase. Para acessar o sistema administrativo, é necessário ter credenciais válidas.

### Login de Teste
- Email: qualquer email válido cadastrado no Supabase
- Senha: senha correspondente

## 🏗️ Arquitetura

### Estrutura de Pastas
```
lib/
├── models/           # Modelos de dados
│   ├── admin_user.dart
│   ├── student.dart
│   ├── room.dart
│   ├── course.dart
│   └── class_schedule.dart
├── services/         # Serviços e lógica de negócio
│   ├── supabase_service.dart
│   └── admin_service.dart
└── ui/              # Interface do usuário
    ├── pages/       # Páginas da aplicação
    │   ├── login_page.dart
    │   ├── dashboard_page.dart
    │   ├── students_page.dart
    │   ├── rooms_page.dart
    │   ├── courses_page.dart
    │   └── schedules_page.dart
    └── components/  # Componentes reutilizáveis
```

### Tecnologias Utilizadas
- **Flutter Web**: Framework principal
- **Supabase**: Backend e autenticação
- **Material Design**: Design system

## 🔄 Integração com o App Mobile

Este sistema administrativo compartilha o mesmo backend (Supabase) com o aplicativo mobile FindU, garantindo sincronização em tempo real dos dados.

### Fluxo de Dados
1. **Admin Web** → Cadastra estudantes, salas, cursos e horários
2. **Supabase** → Armazena e sincroniza os dados
3. **App Mobile** → Consome os dados para exibir horários aos estudantes

### Exemplo Prático:
1. **Secretária** acessa o sistema web
2. **Cadastra** um estudante no curso de Engenharia Civil, 3º semestre
3. **Aloca** aulas na grade semanal para o 3º semestre de Engenharia Civil
4. **Estudante** abre o app mobile e vê automaticamente seus horários

## 📊 Horários Padronizados

O sistema utiliza 7 horários padrão:

| Horário | Período |
|---------|---------|
| 1º | 07:00 - 08:40 |
| 2º | 08:50 - 10:30 |
| 3º | 10:50 - 12:30 |
| 4º | 13:30 - 15:10 |
| 5º | 15:20 - 17:00 |
| 6º | 19:00 - 20:40 |
| 7º | 20:50 - 22:30 |

## 🎨 Interface do Ensalamento

### Grade Semanal
- **Visualização**: Tabela com dias da semana e horários
- **Cores**: Cada curso tem uma cor diferente
- **Interação**: Clique para editar ou adicionar aulas
- **Informações**: Disciplina, sala, curso e semestre

### Lista de Horários
- **Agrupamento**: Por curso e semestre
- **Detalhes**: Professor, sala, prédio, horário
- **Ações**: Editar ou excluir horários

## 📈 Funcionalidades Futuras

### Dashboard Avançado
- Relatórios de ocupação de salas
- Estatísticas de uso por curso
- Gráficos de distribuição de estudantes

### Gestão Avançada de Horários
- Algoritmo de otimização de alocação
- Sugestões de horários alternativos
- Importação/exportação de grades

### Notificações
- Alertas de mudanças de horário
- Notificações para estudantes
- Relatórios automáticos

## 🤝 Contribuição

Este projeto faz parte do sistema FindU e está em desenvolvimento ativo. Contribuições são bem-vindas!

## 📝 Licença

Este projeto é parte do sistema FindU de gestão de ensalamento.
