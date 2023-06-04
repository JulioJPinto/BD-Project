CREATE SCHEMA IF NOT EXISTS edudata;
USE edudata;

CREATE TABLE aluno (
    NrAluno INT,
    idEscola INT,
    Nome VARCHAR(255) NOT NULL,
    Escalao CHAR,
    Idade INT NOT NULL,
    DataDeNascimento DATE NOT NULL,
    fk_Curso INT,
    PRIMARY KEY (NrAluno, idEscola)
);

CREATE TABLE curso (
    id INT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    Descricao TEXT
);

CREATE TABLE escola (
    id INT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    Tipo CHAR NOT NULL,
    IdadeMediaProfessores FLOAT NOT NULL,
    NumeroMedioAlunosPorTurma FLOAT NOT NULL,
    fk_Concelho INT,
    fk_DiretorEscola INT
);

CREATE TABLE concelho (
    id INT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    IdadeMediaPopulacao FLOAT NOT NULL,
    RendimentoMedioAgregadoFamiliar FLOAT NOT NULL,
    NumeroMedioFilhos FLOAT NOT NULL,
    fk_PresidenteConcelho INT
);

CREATE TABLE examenacional (
    id INT PRIMARY KEY,
    Ano INT NOT NULL,
    Fase CHAR NOT NULL,
    DataHora DATETIME NOT NULL,
    TempoNecessario INT NOT NULL,
    TempoTolerancia INT NOT NULL,
    fk_Disciplina INT
);

CREATE TABLE realizacaoexame (
    id INT PRIMARY KEY,
    NotaFinal FLOAT,
    NotaRevisada FLOAT,
    fk_Aluno INT,
    fk_AlunoEscola INT,
    fk_ExameNacional INT,
    fk_EscolaRealizada INT
);

CREATE TABLE disciplina (
    id INT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL
);

CREATE TABLE presidenteconcelho (
    id INT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL
);

CREATE TABLE diretorescola (
    id INT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL
);
 
ALTER TABLE aluno ADD CONSTRAINT FK_Aluno_Escola
    FOREIGN KEY (idEscola)
    REFERENCES escola (id)
    ON DELETE RESTRICT;
 
ALTER TABLE aluno ADD CONSTRAINT FK_Aluno_Curso
    FOREIGN KEY (fk_Curso)
    REFERENCES curso (id)
    ON DELETE RESTRICT;
 
ALTER TABLE escola ADD CONSTRAINT FK_Escola_Concelho
    FOREIGN KEY (fk_Concelho)
    REFERENCES concelho (id)
    ON DELETE RESTRICT;

ALTER TABLE escola ADD CONSTRAINT FK_Escola_DiretorEscola
    FOREIGN KEY (fk_DiretorEscola)
    REFERENCES diretorescola (id)
    ON DELETE RESTRICT;
 
ALTER TABLE concelho ADD CONSTRAINT FK_Concelho_PresidenteConcelho
    FOREIGN KEY (fk_PresidenteConcelho)
    REFERENCES presidenteconcelho (id);
 
ALTER TABLE examenacional ADD CONSTRAINT FK_ExameNacional_Disciplina
    FOREIGN KEY (fk_Disciplina)
    REFERENCES disciplina (id)
    ON DELETE RESTRICT;
 
ALTER TABLE realizacaoexame ADD CONSTRAINT FK_RealizacaoExame_EscolaRealizada
    FOREIGN KEY (fk_EscolaRealizada)
    REFERENCES escola (id);
 
ALTER TABLE realizacaoexame ADD CONSTRAINT FK_RealizacaoExame_ExameNacional
    FOREIGN KEY (fk_ExameNacional)
    REFERENCES examenacional (id);
 
ALTER TABLE realizacaoexame ADD CONSTRAINT FK_RealizacaoExame_Aluno
    FOREIGN KEY (fk_Aluno, fk_AlunoEscola)
    REFERENCES aluno (NrAluno, idEscola);

CREATE VIEW vwExamesRealizados AS
	SELECT RE.id AS "Id",
		   RE.fk_aluno AS "Nº de Aluno", 
		   A.Nome AS "Nome", 
		   E.Nome AS "Escola do Aluno",
		   CONCAT(D.Nome, ' -  Fase ', EN.Fase, ' ', EN.Ano) AS "Exame",
		   RE.NotaFinal AS "Nota Final", 
		   RE.NotaRevisada AS "Nota Revisada"
	FROM RealizacaoExame RE 
    JOIN aluno A 
        ON RE.fk_Aluno = A.NrAluno AND RE.fk_AlunoEscola = A.idEscola
    JOIN examenacional EN 
        ON RE.fk_ExameNacional = EN.id
    JOIN escola E 
        ON RE.fk_AlunoEscola = E.id
    JOIN disciplina D 
        ON EN.fk_Disciplina = D.id
	GROUP BY E.Nome;

DELIMITER &&
CREATE PROCEDURE ExamesDeAlunosDaEscola (IN Escola VARCHAR(255))
BEGIN
	SELECT RE.id AS "Id",
			RE.fk_aluno AS "Nº de Aluno", 
			A.Nome AS "Nome", 
			E.Nome AS "Escola do Aluno", 
			CONCAT(D.Nome, ' -  Fase ', EN.Fase, ' ', EN.Ano) AS "Exame",
			RE.NotaFinal AS "Nota Final", 
			RE.NotaRevisada AS "Nota Revisada"
	FROM
		realizacaoexame RE 
        JOIN aluno A
			ON RE.fk_Aluno=A.NrAluno AND RE.fk_AlunoEscola=A.idEscola
		JOIN examenacional EN 
			ON RE.fk_ExameNacional=EN.id
		JOIN escola E 
			ON RE.fk_AlunoEscola=E.id
		JOIN disciplina D 
			ON EN.fk_Disciplina=D.id
	WHERE E.Nome = Escola;
END &&
DELIMITER ;