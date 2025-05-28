-- =====================================================
-- SCRIPT DE CONFIGURAÇÃO DO BANCO DE DADOS FINDU
-- Execute este script no Supabase SQL Editor
-- =====================================================

-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABELA: admin_users
-- Usuários administrativos do sistema
-- =====================================================
CREATE TABLE IF NOT EXISTS public.admin_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'admin',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true
);

-- =====================================================
-- TABELA: courses
-- Cursos da faculdade
-- =====================================================
CREATE TABLE IF NOT EXISTS public.courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    total_semesters INTEGER NOT NULL DEFAULT 8,
    shift VARCHAR(50) NOT NULL,
    coordinator VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABELA: rooms
-- Salas da faculdade
-- =====================================================
CREATE TABLE IF NOT EXISTS public.rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    number VARCHAR(50) NOT NULL,
    building VARCHAR(100) NOT NULL,
    capacity INTEGER NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'classroom',
    equipment TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(number, building)
);

-- =====================================================
-- TABELA: students
-- Estudantes da faculdade
-- =====================================================
CREATE TABLE IF NOT EXISTS public.students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    course VARCHAR(100) NOT NULL,
    semester INTEGER NOT NULL,
    shift VARCHAR(50) NOT NULL,
    enrolled_classes TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABELA: class_schedules
-- Horários das aulas (ensalamento) - ATUALIZADA PARA RECORRÊNCIA
-- =====================================================
CREATE TABLE IF NOT EXISTS public.class_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_name VARCHAR(255) NOT NULL,
    teacher_name VARCHAR(255) NOT NULL,
    room VARCHAR(50) NOT NULL,
    building VARCHAR(100) NOT NULL,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 1 AND day_of_week <= 6), -- 1=Segunda, 6=Sábado
    time_slot INTEGER NOT NULL CHECK (time_slot IN (1, 2)), -- 1=Manhã, 2=Tarde/Noite
    start_time_hour INTEGER NOT NULL,
    start_time_minute INTEGER NOT NULL,
    end_time_hour INTEGER NOT NULL,
    end_time_minute INTEGER NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    semester INTEGER NOT NULL,
    is_recurring BOOLEAN DEFAULT true, -- Se a aula se repete semanalmente
    start_date DATE, -- Data de início da recorrência
    end_date DATE, -- Data de fim da recorrência (opcional)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    -- Constraint para evitar conflitos de sala no mesmo horário
    UNIQUE(room, building, day_of_week, time_slot)
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_students_course_semester ON students(course, semester);
CREATE INDEX IF NOT EXISTS idx_class_schedules_course_semester ON class_schedules(course_id, semester);
CREATE INDEX IF NOT EXISTS idx_class_schedules_day_time ON class_schedules(day_of_week, time_slot);
CREATE INDEX IF NOT EXISTS idx_class_schedules_room_time ON class_schedules(room, building, day_of_week, time_slot);
CREATE INDEX IF NOT EXISTS idx_rooms_building_type ON rooms(building, type);

-- =====================================================
-- INSERIR DADOS INICIAIS
-- =====================================================

-- Inserir cursos padrão
INSERT INTO public.courses (id, name, code, total_semesters, shift, coordinator) VALUES
    (uuid_generate_v4(), 'Engenharia Civil', 'ENG_CIVIL', 10, 'morning', 'Prof. João Silva'),
    (uuid_generate_v4(), 'Engenharia da Computação', 'ENG_COMP', 10, 'morning', 'Prof. Maria Santos'),
    (uuid_generate_v4(), 'Sistemas de Informação', 'SIS_INFO', 8, 'evening', 'Prof. Carlos Lima'),
    (uuid_generate_v4(), 'Direito', 'DIREITO', 10, 'evening', 'Prof. Ana Costa'),
    (uuid_generate_v4(), 'Psicologia', 'PSICO', 10, 'afternoon', 'Prof. Pedro Oliveira'),
    (uuid_generate_v4(), 'Medicina', 'MED', 12, 'full', 'Prof. Laura Ferreira'),
    (uuid_generate_v4(), 'Enfermagem', 'ENF', 8, 'morning', 'Prof. Sofia Rodrigues')
ON CONFLICT (code) DO NOTHING;

-- Inserir salas padrão
INSERT INTO public.rooms (number, building, capacity, type, equipment) VALUES
    ('101', 'Bloco A', 40, 'classroom', '{"projector", "whiteboard", "air_conditioning"}'),
    ('102', 'Bloco A', 40, 'classroom', '{"projector", "whiteboard"}'),
    ('103', 'Bloco A', 35, 'classroom', '{"whiteboard", "air_conditioning"}'),
    ('201', 'Bloco A', 45, 'classroom', '{"projector", "whiteboard", "air_conditioning", "sound_system"}'),
    ('202', 'Bloco A', 45, 'classroom', '{"projector", "whiteboard"}'),
    ('301', 'Bloco A', 50, 'classroom', '{"projector", "whiteboard", "air_conditioning", "microphone"}'),
    
    ('101', 'Bloco B', 30, 'lab', '{"computer", "projector", "whiteboard", "air_conditioning"}'),
    ('102', 'Bloco B', 30, 'lab', '{"computer", "projector", "whiteboard"}'),
    ('201', 'Bloco B', 35, 'lab', '{"computer", "projector", "whiteboard", "air_conditioning"}'),
    
    ('101', 'Bloco C', 25, 'classroom', '{"projector", "whiteboard"}'),
    ('102', 'Bloco C', 25, 'classroom', '{"whiteboard"}'),
    ('201', 'Bloco C', 30, 'classroom', '{"projector", "whiteboard", "air_conditioning"}'),
    
    ('Auditório 1', 'Biblioteca', 100, 'auditorium', '{"projector", "sound_system", "microphone", "air_conditioning"}'),
    ('Auditório 2', 'Biblioteca', 80, 'auditorium', '{"projector", "sound_system", "microphone"}')
ON CONFLICT (number, building) DO NOTHING;

-- Inserir estudantes de exemplo
INSERT INTO public.students (name, email, course, semester, shift, enrolled_classes) VALUES
    ('João Pedro Silva', 'joao.silva@email.com', 'ENG_CIVIL', 1, 'Manhã', '{}'),
    ('Maria Fernanda Santos', 'maria.santos@email.com', 'ENG_CIVIL', 3, 'Manhã', '{}'),
    ('Carlos Eduardo Lima', 'carlos.lima@email.com', 'SIS_INFO', 2, 'Noite', '{}'),
    ('Ana Carolina Costa', 'ana.costa@email.com', 'SIS_INFO', 4, 'Noite', '{}'),
    ('Pedro Henrique Oliveira', 'pedro.oliveira@email.com', 'DIREITO', 1, 'Noite', '{}'),
    ('Laura Beatriz Ferreira', 'laura.ferreira@email.com', 'MED', 2, 'Integral', '{}'),
    ('Sofia Rodrigues', 'sofia.rodrigues@email.com', 'ENF', 1, 'Manhã', '{}'),
    ('Lucas Gabriel Almeida', 'lucas.almeida@email.com', 'ENG_COMP', 3, 'Manhã', '{}'),
    ('Isabela Cristina Souza', 'isabela.souza@email.com', 'PSICO', 2, 'Tarde', '{}'),
    ('Rafael Augusto Pereira', 'rafael.pereira@email.com', 'ENG_CIVIL', 5, 'Manhã', '{}')
ON CONFLICT (email) DO NOTHING;

-- Inserir horários de exemplo com recorrência
-- Obter IDs dos cursos para os exemplos
DO $$
DECLARE
    eng_civil_id UUID;
    sis_info_id UUID;
    direito_id UUID;
BEGIN
    -- Buscar IDs dos cursos
    SELECT id INTO eng_civil_id FROM courses WHERE code = 'ENG_CIVIL' LIMIT 1;
    SELECT id INTO sis_info_id FROM courses WHERE code = 'SIS_INFO' LIMIT 1;
    SELECT id INTO direito_id FROM courses WHERE code = 'DIREITO' LIMIT 1;
    
    -- Inserir horários de exemplo se os cursos existirem
    IF eng_civil_id IS NOT NULL THEN
        INSERT INTO public.class_schedules (
            class_name, teacher_name, room, building, day_of_week, time_slot,
            start_time_hour, start_time_minute, end_time_hour, end_time_minute,
            course_id, semester, is_recurring, start_date
        ) VALUES
        ('Matemática I', 'Prof. João Silva', '101', 'Bloco A', 1, 1, 7, 0, 11, 0, eng_civil_id, 1, true, CURRENT_DATE),
        ('Física I', 'Prof. Maria Santos', '102', 'Bloco A', 2, 1, 7, 0, 11, 0, eng_civil_id, 1, true, CURRENT_DATE),
        ('Desenho Técnico', 'Prof. Carlos Lima', '201', 'Bloco B', 3, 2, 13, 0, 17, 0, eng_civil_id, 1, true, CURRENT_DATE);
    END IF;
    
    IF sis_info_id IS NOT NULL THEN
        INSERT INTO public.class_schedules (
            class_name, teacher_name, room, building, day_of_week, time_slot,
            start_time_hour, start_time_minute, end_time_hour, end_time_minute,
            course_id, semester, is_recurring, start_date
        ) VALUES
        ('Algoritmos', 'Prof. Ana Costa', '101', 'Bloco B', 1, 2, 19, 0, 23, 0, sis_info_id, 2, true, CURRENT_DATE),
        ('Banco de Dados', 'Prof. Pedro Oliveira', '102', 'Bloco B', 3, 2, 19, 0, 23, 0, sis_info_id, 3, true, CURRENT_DATE);
    END IF;
    
    IF direito_id IS NOT NULL THEN
        INSERT INTO public.class_schedules (
            class_name, teacher_name, room, building, day_of_week, time_slot,
            start_time_hour, start_time_minute, end_time_hour, end_time_minute,
            course_id, semester, is_recurring, start_date
        ) VALUES
        ('Direito Civil', 'Prof. Laura Ferreira', '301', 'Bloco A', 2, 2, 19, 0, 23, 0, direito_id, 1, true, CURRENT_DATE);
    END IF;
END $$;

-- =====================================================
-- POLÍTICAS DE SEGURANÇA (RLS)
-- =====================================================

-- Habilitar RLS nas tabelas
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.class_schedules ENABLE ROW LEVEL SECURITY;

-- Políticas para permitir acesso autenticado
CREATE POLICY "Allow authenticated access" ON public.admin_users FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow authenticated access" ON public.courses FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow authenticated access" ON public.rooms FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow authenticated access" ON public.students FOR ALL TO authenticated USING (true);
CREATE POLICY "Allow authenticated access" ON public.class_schedules FOR ALL TO authenticated USING (true);

-- Políticas para permitir acesso anônimo (para o app mobile)
CREATE POLICY "Allow anonymous read" ON public.courses FOR SELECT TO anon USING (true);
CREATE POLICY "Allow anonymous read" ON public.rooms FOR SELECT TO anon USING (true);
CREATE POLICY "Allow anonymous read" ON public.students FOR SELECT TO anon USING (true);
CREATE POLICY "Allow anonymous read" ON public.class_schedules FOR SELECT TO anon USING (true);

-- =====================================================
-- FUNÇÕES AUXILIARES
-- =====================================================

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para atualizar updated_at
CREATE TRIGGER update_courses_updated_at BEFORE UPDATE ON courses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_rooms_updated_at BEFORE UPDATE ON rooms FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_students_updated_at BEFORE UPDATE ON students FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_class_schedules_updated_at BEFORE UPDATE ON class_schedules FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- VIEWS ÚTEIS
-- =====================================================

-- View para facilitar consultas de horários com informações dos cursos
CREATE OR REPLACE VIEW schedule_details AS
SELECT 
    cs.*,
    c.name as course_name,
    c.code as course_code,
    CASE cs.day_of_week
        WHEN 1 THEN 'Segunda-feira'
        WHEN 2 THEN 'Terça-feira'
        WHEN 3 THEN 'Quarta-feira'
        WHEN 4 THEN 'Quinta-feira'
        WHEN 5 THEN 'Sexta-feira'
        WHEN 6 THEN 'Sábado'
    END as day_name,
    CASE cs.time_slot
        WHEN 1 THEN 'Manhã'
        WHEN 2 THEN 'Tarde/Noite'
    END as time_slot_name
FROM class_schedules cs
JOIN courses c ON cs.course_id = c.id;

-- =====================================================
-- SCRIPT CONCLUÍDO
-- =====================================================

-- Verificar se as tabelas foram criadas
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE schemaname = 'public' 
    AND tablename IN ('admin_users', 'courses', 'rooms', 'students', 'class_schedules')
ORDER BY tablename; 