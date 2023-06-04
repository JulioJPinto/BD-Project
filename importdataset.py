import csv
import mysql.connector

# Configurações da conexão com a base de dados
config = {
    'user': 'root',
    'password': 'admin',
    'host': 'localhost',
    'database': 'edudata'
}

# Função para estabelecer a conexão com a base de dados
def conectar():
    try:
        conn = mysql.connector.connect(**config)
        print('Conexão estabelecida com sucesso!')
        return conn
    except mysql.connector.Error as err:
        print(f'Erro ao conectar à base de dados: {err}')
        return None

# Função para inserir os dados do CSV na tabela
def inserir_dados(conn, tabela, dados, mapeamento_colunas):
    cursor = conn.cursor()
    colunas_csv = dados[0].keys()
    colunas_sql = [mapeamento_colunas.get(coluna) for coluna in colunas_csv]

    placeholders = ', '.join(['%s'] * len(colunas_csv))
    colunas = ', '.join(colunas_sql)
    query = f"INSERT INTO {tabela} ({colunas}) VALUES ({placeholders})"
    valores = [[linha[coluna_csv] for coluna_csv in colunas_csv] for linha in dados]

    try:
        cursor.executemany(query, valores)
        conn.commit()
        print(f'{len(dados)} registos inseridos com sucesso na tabela {tabela}.')
    except mysql.connector.Error as err:
        conn.rollback()
        print(f'Erro ao inserir dados na tabela {tabela}: {err}')

    cursor.close()

# Função para ler os dados de um arquivo CSV
def ler_csv(nome_arquivo):
    dados = []
    with open(nome_arquivo, 'r', newline='', encoding='utf-8-sig') as arquivo:
        leitor = csv.DictReader(arquivo, delimiter=';')
        for linha in leitor:
            dados.append(linha)

    return dados

# Função principal
def main():
    # Realizar a conexão com a base de dados
    conn = conectar()
    if not conn:
        return

    # Inserir os dados na tabela PresidenteConcelho
    dados_presidente = ler_csv('dataset/presidentes.csv')
    mapeamento_colunas_presidente = {'Id': 'id',
                                     'Nome': 'Nome'}
    inserir_dados(conn, 'PresidenteConcelho', dados_presidente, mapeamento_colunas_presidente)

    # Inserir os dados na tabela Concelho
    dados_concelho = ler_csv('dataset/concelhos.csv')
    mapeamento_colunas_concelho = {'Id': 'id',
                                   'Nome': 'Nome',
                                   'IdadeMediaPopulacao': 'IdadeMediaPopulacao',
                                   'RendimentoMedioAgregadoFamiliar': 'RendimentoMedioAgregadoFamiliar',
                                   'NumeroMedioFilhos': 'NumeroMedioFilhos',
                                   'PresidenteId': 'fk_PresidenteConcelho'}
    inserir_dados(conn, 'Concelho', dados_concelho, mapeamento_colunas_concelho)

    # Inserir os dados na tabela DiretorEscola
    dados_diretores = ler_csv('dataset/diretores.csv')
    mapeamento_colunas_diretores = {'Id': 'id',
                                    'Nome': 'Nome'}
    inserir_dados(conn, 'DiretorEscola', dados_diretores, mapeamento_colunas_diretores)

    # Inserir os dados na tabela Escola
    dados_escolas = ler_csv('dataset/escolas.csv')
    mapeamento_colunas_escolas = {'Id': 'id',
                                  'Nome': 'Nome',
                                  'Tipo': 'Tipo',
                                  'IdadeMediaProfessores': 'IdadeMediaProfessores',
                                  'NumeroMedioAlunosPorTurma': 'NumeroMedioAlunosPorTurma',
                                  'ConcelhoId': 'fk_Concelho',
                                  'DiretorId': 'fk_DiretorEscola'}
    inserir_dados(conn, 'Escola', dados_escolas, mapeamento_colunas_escolas)

    # Inserir os dados na tabela Curso
    dados_cursos = ler_csv('dataset/cursos.csv')
    mapeamento_colunas_cursos = {'Id': 'id',
                                 'Nome': 'Nome',
                                 'Descricao': 'Descricao'}
    inserir_dados(conn, 'Curso', dados_cursos, mapeamento_colunas_cursos)

    # Inserir os dados na tabela Aluno
    dados_alunos = ler_csv('dataset/alunos.csv')
    mapeamento_colunas_alunos = {'nrAluno': 'NrAluno',
                                 'EscolaId': 'idEscola',
                                 'Nome': 'Nome',
                                 'Escalao': 'Escalao',
                                 'Idade': 'Idade',
                                 'DataDeNascimento': 'DataDeNascimento',
                                 'CursoId': 'fk_Curso'}
    inserir_dados(conn, 'Aluno', dados_alunos, mapeamento_colunas_alunos)

    # Inserir os dados na tabela Disciplina
    dados_disciplinas = ler_csv('dataset/disciplinas.csv')
    mapeamento_colunas_disciplinas = {'Id': 'id',
                                      'Nome': 'Nome'}
    inserir_dados(conn, 'Disciplina', dados_disciplinas, mapeamento_colunas_disciplinas)

    # Inserir os dados na tabela ExameNacional
    dados_exames = ler_csv('dataset/exames.csv')
    mapeamento_colunas_exames = {'Id': 'id',
                                 'Ano': 'Ano',
                                 'Fase': 'Fase',
                                 'DataHora': 'DataHora',
                                 'TempoNecessario': 'TempoNecessario',
                                 'TempoTolerancia': 'TempoTolerancia',
                                 'DisciplinaId': 'fk_Disciplina'}
    inserir_dados(conn, 'ExameNacional', dados_exames, mapeamento_colunas_exames)

    # Inserir os dados na tabela RealizacaoExame
    dados_realizacoes = ler_csv('dataset/realizacoesexames.csv')
    mapeamento_colunas_realizacoes = {'Id': 'id',
                                      'NotaFinal': 'NotaFinal',
                                      'NotaRevisada': 'NotaRevisada',
                                      'NrAluno': 'fk_Aluno',
                                      'EscolaAlunoId': 'fk_AlunoEscola',
                                      'ExameId': 'fk_ExameNacional',
                                      'EscolaRealizadaId': 'fk_EscolaRealizada'}
    inserir_dados(conn, 'RealizacaoExame', dados_realizacoes, mapeamento_colunas_realizacoes)

    # Fechar a conexão com a base de dados
    conn.close()

if __name__ == '__main__':
    main()