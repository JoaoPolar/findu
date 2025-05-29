# 🗄️ Configuração do Banco de Dados - FindU Admin

## ⚠️ IMPORTANTE: Execute este processo para resolver os erros de banco

Os erros que você está vendo indicam que as tabelas não existem no banco de dados Supabase. Siga este guia para configurar tudo corretamente.

## 🎯 **NOVA ESTRUTURA: RECORRÊNCIA SEMANAL**

O sistema agora suporta:
- ✅ **Apenas 2 horários por dia**: Manhã e Tarde/Noite
- ✅ **Aulas recorrentes**: Se repetem automaticamente toda semana
- ✅ **Controle de período**: Data de início e fim da recorrência
- ✅ **Detecção de conflitos**: Evita dupla alocação por sala/horário

### Exemplo de Funcionamento:
```
Segunda-feira, Manhã (07:00-11:00):
- Sala 101: Matemática I - Engenharia Civil (1º Semestre) [RECORRENTE]

Segunda-feira, Tarde/Noite (13:00-17:00):
- Sala 101: Algoritmos - Sistemas de Informação (2º Semestre) [RECORRENTE]
```

## 📋 Passo a Passo

### 1. Acesse o Supabase Dashboard
1. Vá para [https://supabase.com](https://supabase.com)
2. Faça login na sua conta
3. Selecione o projeto FindU

### 2. Abra o SQL Editor
1. No menu lateral, clique em **"SQL Editor"**
2. Clique em **"New query"**

### 3. Execute o Script de Configuração
1. Copie todo o conteúdo do arquivo `database_setup.sql`
2. Cole no SQL Editor do Supabase
3. Clique em **"Run"** para executar

### 4. Verifique se as Tabelas foram Criadas
Após executar o script, você deve ver:
- ✅ 5 tabelas criadas
- ✅ Dados de exemplo inseridos
- ✅ Políticas de segurança configuradas

## 🔍 Verificação

Execute esta query para confirmar que tudo foi criado:

```sql
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE schemaname = 'public' 
    AND tablename IN ('admin_users', 'courses', 'rooms', 'students', 'class_schedules')
ORDER BY tablename;
```

Você deve ver 5 linhas retornadas.

## 📊 Estrutura das Tabelas Criadas

### 1. **admin_users** - Usuários administrativos
- `id` (UUID, Primary Key)
- `email` (VARCHAR, Unique)
- `name` (VARCHAR)
- `role` (VARCHAR)
- `created_at`, `last_login`, `is_active`

### 2. **courses** - Cursos da faculdade
- `id` (UUID, Primary Key)
- `name` (VARCHAR)
- `code` (VARCHAR, Unique)
- `total_semesters` (INTEGER)
- `shift` (VARCHAR)
- `coordinator` (VARCHAR)
- `is_active`, `created_at`, `updated_at`

### 3. **rooms** - Salas da faculdade
- `id` (UUID, Primary Key)
- `number` (VARCHAR)
- `building` (VARCHAR)
- `capacity` (INTEGER)
- `type` (VARCHAR)
- `equipment` (TEXT[])
- `is_active`, `created_at`, `updated_at`

### 4. **students** - Estudantes
- `id` (UUID, Primary Key)
- `name` (VARCHAR)
- `email` (VARCHAR, Unique)
- `course` (VARCHAR)
- `semester` (INTEGER)
- `shift` (VARCHAR)
- `enrolled_classes` (TEXT[])
- `created_at`, `updated_at`

### 5. **class_schedules** - Horários das aulas ⭐ **ATUALIZADA**
- `id` (UUID, Primary Key)
- `class_name` (VARCHAR)
- `teacher_name` (VARCHAR)
- `room`, `building` (VARCHAR)
- `day_of_week` (INTEGER) - 1=Segunda, 6=Sábado
- `time_slot` (INTEGER) - 1=Manhã, 2=Tarde/Noite
- `start_time_hour`, `start_time_minute` (INTEGER)
- `end_time_hour`, `end_time_minute` (INTEGER)
- `course_id` (UUID, Foreign Key)
- `semester` (INTEGER)
- **`is_recurring`** (BOOLEAN) - Se repete semanalmente
- **`start_date`** (DATE) - Início da recorrência
- **`end_date`** (DATE) - Fim da recorrência (opcional)
- `created_at`, `updated_at`

## 🎯 Dados de Exemplo Incluídos

O script já inclui dados de exemplo:

### Cursos:
- Engenharia Civil (10 semestres, Matutino)
- Engenharia da Computação (10 semestres, Matutino)
- Sistemas de Informação (8 semestres, Noturno)
- Direito (10 semestres, Noturno)
- Psicologia (10 semestres, Vespertino)
- Medicina (12 semestres, Integral)
- Enfermagem (8 semestres, Matutino)

### Salas:
- **Bloco A**: Salas 101-103, 201-202, 301 (35-50 pessoas)
- **Bloco B**: Labs 101-102, 201 (30-35 pessoas)
- **Bloco C**: Salas 101-102, 201 (25-30 pessoas)
- **Biblioteca**: Auditórios 1 e 2 (80-100 pessoas)

### Estudantes:
- 10 estudantes de exemplo distribuídos pelos cursos

### Horários de Exemplo:
- **Matemática I**: Segunda, Manhã, Sala 101 (Eng. Civil 1º) - RECORRENTE
- **Física I**: Terça, Manhã, Sala 102 (Eng. Civil 1º) - RECORRENTE
- **Algoritmos**: Segunda, Tarde/Noite, Lab 101 (Sistemas 2º) - RECORRENTE

## 🔐 Segurança Configurada

O script configura automaticamente:
- **RLS (Row Level Security)** habilitado
- **Políticas de acesso** para usuários autenticados
- **Acesso de leitura** para usuários anônimos (app mobile)
- **Constraint único** para evitar conflitos de sala/horário

## 🚀 Após a Configuração

1. **Reinicie a aplicação Flutter**:
   ```bash
   flutter run -d chrome
   ```

2. **Teste o login** com qualquer email válido

3. **Verifique se os dados aparecem** em todas as seções:
   - Dashboard com estatísticas
   - Lista de estudantes
   - Lista de salas
   - Lista de cursos
   - **Grade de horários simplificada** (2 horários por dia)

## 🎯 **FUNCIONALIDADES DA NOVA ESTRUTURA**

### Grade Semanal Simplificada:
- **2 horários por dia**: Manhã (07:00-11:00) e Tarde/Noite (13:00-17:00)
- **6 dias da semana**: Segunda a Sábado
- **Visualização clara**: Cada célula mostra as aulas alocadas
- **Cores por curso**: Identificação visual fácil

### Recorrência Semanal:
- **Aulas recorrentes**: Marcadas com ícone de repetição
- **Período definido**: Data de início e fim configuráveis
- **Flexibilidade**: Pode criar aulas únicas ou recorrentes

### Exemplo de Uso:
1. **Secretária** cria uma aula de "Matemática I"
2. **Configura** para Segunda-feira, Manhã, Sala 101
3. **Marca como recorrente** com início hoje e fim em dezembro
4. **Sistema** entende que a aula se repete toda segunda-feira
5. **Estudantes** veem no app mobile que têm Matemática toda segunda

## ❌ Solução de Problemas

### Se ainda houver erros:

1. **Verifique as credenciais do Supabase** em `lib/services/supabase_service.dart`
2. **Confirme que o projeto está ativo** no Supabase
3. **Execute novamente o script SQL** se necessário
4. **Verifique os logs** no console do Flutter

### Erros comuns:
- `relation does not exist` = Tabelas não foram criadas
- `404 error` = URL ou chaves do Supabase incorretas
- `Authentication error` = Políticas de segurança não configuradas
- `Constraint violation` = Tentativa de criar conflito de horário

## 📞 Suporte

Se os problemas persistirem:
1. Verifique se o script foi executado completamente
2. Confirme que todas as 5 tabelas existem
3. Teste a conexão com uma query simples no SQL Editor
4. Verifique se a constraint de horário está funcionando

---

**✅ Após seguir este guia, o sistema deve funcionar perfeitamente com a nova estrutura de recorrência semanal!** 