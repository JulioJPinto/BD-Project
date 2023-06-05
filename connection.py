# Função para carregar as configurações da conexão com a base de dados a partir de um input
def load_config_from_input(input_str):
    config = {}
    parts = input_str.split('@')

    def invalid_format():
        raise ValueError("Formato inválido. O input deve estar no formato user:password@host:database")

    if len(parts) != 2:
        invalid_format()
    
    user_password = parts[0].split(':')
    host_database = parts[1].split(':')

    if len(user_password) != 2 or len(host_database) != 2:
        invalid_format()
    
    config['user'] = user_password[0]
    config['password'] = user_password[1]
    config['host'] = host_database[0]
    config['database'] = host_database[1]
    
    return config