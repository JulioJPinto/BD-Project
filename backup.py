import os
import sys
import datetime
import subprocess
import shutil
from connection import load_config_from_input

# Pasta de backup
backup_folder = 'backups'

def create_backup(connection_info_lazy):
    # Criar pasta de backup se não existir
    if not os.path.exists(backup_folder):
        os.makedirs(backup_folder)

    # Gerar nome do arquivo de backup baseado na data e hora atual
    now = datetime.datetime.now()
    backup_file = os.path.join(backup_folder, now.strftime('%Y-%m-%d_%H-%M-%S') + '.sql')

    connection_info = connection_info_lazy()

    user = connection_info['user']
    password = connection_info['password']
    host = connection_info['host']
    database = connection_info['database']

    # Comando para criar o backup
    cmd = f'mysqldump --user={user} --password={password} --host={host} --databases {database} --routines > {backup_file}'

    # Executar o comando
    subprocess.call(cmd, shell=True)
    print(f'O backup foi criado em: {backup_file}')


def import_backup(connection_info_lazy, file_path):
    # Verificar se o arquivo de backup existe
    if not os.path.isfile(file_path):
        print(f'O arquivo de backup "{file_path}" não existe.')
        return
    
    connection_info = connection_info_lazy()

    user = connection_info['user']
    password = connection_info['password']
    host = connection_info['host']
    database = connection_info['database']

    # Comando para importar o backup para a base de dados
    cmd = f'mysql --user={user} --password={password} --host={host} {database} < {file_path}'

    # Solicitar confirmação do usuário
    confirmation = input('Tem certeza de que deseja importar o backup? Isso substituirá completamente a base de dados atual. (y/n): ')

    if confirmation.lower() != 'y':
        print('Operação cancelada pelo usuário.')
        return

    # Executar o comando
    subprocess.call(cmd, shell=True)
    print(f'Importado "{file_path}" para a base de dados.')


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Uso: python backup.py [save|import <file>]')
        sys.exit(1)

    command = sys.argv[1]

    connection_info = lambda: load_config_from_input(input('Digite as informações de conexão no formato \'user:password@host:database\': '))

    if command == 'save':
        create_backup(connection_info)
    elif command == 'import':
        if len(sys.argv) < 3:
            print('Uso: python backup.py import <file>')
            sys.exit(1)
        
        file_path = sys.argv[2]
        import_backup(connection_info, file_path)
    else:
        print(f'Comando desconhecido: {command}')
        print('Uso: python backup.py [save|import <file>]')
        sys.exit(1)