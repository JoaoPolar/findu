# 🗄️ Configuração do Banco de Dados - FindU Admin

## ⚠️ IMPORTANTE: Execute este processo para resolver os erros de banco

Os erros que você está vendo indicam que as tabelas não existem no banco de dados Supabase. Siga este guia para configurar tudo corretamente.

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

### 5. **class_schedules** - Horários das aulas
- `id` (UUID, Primary Key)
- `class_name` (VARCHAR)
- `teacher_name` (VARCHAR)
- `room`, `building` (VARCHAR)
- `day` (VARCHAR)
- `start_time_hour`, `start_time_minute` (INTEGER)
- `end_time_hour`, `end_time_minute` (INTEGER)
- `course_id` (UUID, Foreign Key)
- `semester` (INTEGER)
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

## 🔐 Segurança Configurada

O script configura automaticamente:
- **RLS (Row Level Security)** habilitado
- **Políticas de acesso** para usuários autenticados
- **Acesso de leitura** para usuários anônimos (app mobile)

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
   - Grade de horários

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

## 📞 Suporte

Se os problemas persistirem:
1. Verifique se o script foi executado completamente
2. Confirme que todas as 5 tabelas existem
3. Teste a conexão com uma query simples no SQL Editor

---

**✅ Após seguir este guia, o sistema deve funcionar perfeitamente!** 