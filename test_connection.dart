import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://xnwxjxayemwgomenhvbi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhud3hqeGF5ZW13Z29tZW5odmJpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxOTUzODIsImV4cCI6MjA1OTc3MTM4Mn0.QwRMmDqP0A06dbdkSmN4xIZ8oy5V6pOBlSmiCjh20qc',
  );

  final client = Supabase.instance.client;

  print('🔍 Testando conexão com Supabase...');

  try {
    // Teste 1: Verificar se as tabelas existem testando uma query simples
    print('\n1. Testando tabelas...');
    
    try {
      await client.from('courses').select('count').count();
      print('  ✅ courses');
    } catch (e) {
      print('  ❌ courses - $e');
    }
    
    try {
      await client.from('rooms').select('count').count();
      print('  ✅ rooms');
    } catch (e) {
      print('  ❌ rooms - $e');
    }
    
    try {
      await client.from('students').select('count').count();
      print('  ✅ students');
    } catch (e) {
      print('  ❌ students - $e');
    }
    
    try {
      await client.from('class_schedules').select('count').count();
      print('  ✅ class_schedules');
    } catch (e) {
      print('  ❌ class_schedules - $e');
    }
    
    try {
      await client.from('admin_users').select('count').count();
      print('  ✅ admin_users');
    } catch (e) {
      print('  ❌ admin_users - $e');
    }

    // Teste 2: Verificar se há dados
    print('\n2. Verificando dados...');
    
    final courses = await client.from('courses').select('count').count();
    print('  Cursos: $courses');
    
    final rooms = await client.from('rooms').select('count').count();
    print('  Salas: $rooms');
    
    final students = await client.from('students').select('count').count();
    print('  Estudantes: $students');

    print('\n✅ CONEXÃO OK! O banco está funcionando.');
    
  } catch (e) {
    print('\n❌ ERRO na conexão: $e');
    print('\nVerifique:');
    print('1. Se o projeto Supabase está ativo');
    print('2. Se as credenciais estão corretas');
    print('3. Se o script SQL foi executado');
  }
} 