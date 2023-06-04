CREATE SCHEMA IF NOT EXISTS edudata;
USE edudata;

CREATE TABLE Aluno (
    NrAluno INT,
    idEscola INT,
    Nome VARCHAR(255) NOT NULL,
    Escalao CHAR,
    Idade INT NOT NULL,
    DataDeNascimento DATE NOT NULL,
    fk_Curso INT,
    PRIMARY KEY (NrAluno, idEscola)
);

CREATE TABLE Curso (
    id INT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    Descricao TEXT
);

CREATE TABLE Escola (
    id INT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    Tipo CHAR NOT NULL,
    IdadeMediaProfessores FLOAT NOT NULL,
    NumeroMedioAlunosPorTurma FLOAT NOT NULL,
    fk_Concelho INT,
    fk_DiretorEscola INT
);

CREATE TABLE Concelho (
    id INT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    IdadeMediaPopulacao FLOAT NOT NULL,
    RendimentoMedioAgregadoFamiliar FLOAT NOT NULL,
    NumeroMedioFilhos FLOAT NOT NULL,
    fk_PresidenteConcelho INT
);

CREATE TABLE ExameNacional (
    id INT PRIMARY KEY,
    Ano INT NOT NULL,
    Fase CHAR NOT NULL,
    DataHora DATETIME NOT NULL,
    TempoNecessario INT NOT NULL,
    TempoTolerancia INT NOT NULL,
    fk_Disciplina INT
);

CREATE TABLE RealizacaoExame (
    id INT PRIMARY KEY,
    NotaFinal FLOAT,
    NotaRevisada FLOAT,
    fk_Aluno INT,
    fk_AlunoEscola INT,
    fk_ExameNacional INT,
    fk_EscolaRealizada INT
);

CREATE TABLE Disciplina (
    id INT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL
);

CREATE TABLE PresidenteConcelho (
    id INT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL
);

CREATE TABLE DiretorEscola (
    id INT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL
);
 
ALTER TABLE Aluno ADD CONSTRAINT FK_Aluno_Escola
    FOREIGN KEY (idEscola)
    REFERENCES Escola (id)
    ON DELETE RESTRICT;
 
ALTER TABLE Aluno ADD CONSTRAINT FK_Aluno_Curso
    FOREIGN KEY (fk_Curso)
    REFERENCES Curso (id)
    ON DELETE RESTRICT;
 
ALTER TABLE Escola ADD CONSTRAINT FK_Escola_Concelho
    FOREIGN KEY (fk_Concelho)
    REFERENCES Concelho (id)
    ON DELETE RESTRICT;

ALTER TABLE Escola ADD CONSTRAINT FK_Escola_DiretorEscola
    FOREIGN KEY (fk_DiretorEscola)
    REFERENCES DiretorEscola (id)
    ON DELETE RESTRICT;
 
ALTER TABLE Concelho ADD CONSTRAINT FK_Concelho_PresidenteConcelho
    FOREIGN KEY (fk_PresidenteConcelho)
    REFERENCES PresidenteConcelho (id);
 
ALTER TABLE ExameNacional ADD CONSTRAINT FK_ExameNacional_Disciplina
    FOREIGN KEY (fk_Disciplina)
    REFERENCES Disciplina (id)
    ON DELETE RESTRICT;
 
ALTER TABLE RealizacaoExame ADD CONSTRAINT FK_RealizacaoExame_EscolaRealizada
    FOREIGN KEY (fk_EscolaRealizada)
    REFERENCES Escola (id);
 
ALTER TABLE RealizacaoExame ADD CONSTRAINT FK_RealizacaoExame_ExameNacional
    FOREIGN KEY (fk_ExameNacional)
    REFERENCES ExameNacional (id);
 
ALTER TABLE RealizacaoExame ADD CONSTRAINT FK_RealizacaoExame_Aluno
    FOREIGN KEY (fk_Aluno, fk_AlunoEscola)
    REFERENCES Aluno (NrAluno, idEscola);

CREATE VIEW vwExamesRealizados AS
SELECT RE.id AS "Id",
       RE.fk_aluno AS "Nº de Aluno", 
       A.Nome AS "Nome", 
       AE.Nome AS "Escola do Aluno", 
       EE.Nome AS "Escola do Exame", 
       CONCAT(D.Nome, ' -  Fase ', EN.Fase, ' ', EN.Ano) AS "Exame",
       EN RE.NotaFinal AS "Nota Final", 
       RE.NotaRevisada AS "Nota Revisada"
FROM 
    RealizacaoExame AS RE JOIN Aluno AS A 
        ON RE.fk_Aluno=A.NrAluno AND RE.fk_AlunoEscola=A.idEscola
    JOIN ExameNacional EN 
        ON RE.fk_ExameNacional=EN.id
    JOIN AlunoEscola AE 
        ON RE.fk_AlunoEscola=E.id
    JOIN EscolaExame EE 
        ON RE.fk_EscolaRealizada=EE.id
    JOIN Disciplina D 
        ON EN.fk_Disciplina=D.id
GROUP BY AE.Nome;

CREATE PROCEDURE ExamesDeAlunosDaEscola @Escola VARCHAR(255)
AS
SELECT *
    FROM ExamesRealizados
    WITH ExamesRealizados AS(
    SELECT RE.id AS "Id",
        RE.fk_aluno AS "Nº de Aluno", 
        A.Nome AS "Nome", 
        AE.Nome AS "Escola do Aluno", 
        EE.Nome AS "Escola do Exame", 
        CONCAT(D.Nome, ' -  Fase ', EN.Fase, ' ', EN.Ano) AS "Exame",
        EN RE.NotaFinal AS "Nota Final", 
        RE.NotaRevisada AS "Nota Revisada"
    FROM 
        RealizacaoExame AS RE JOIN Aluno AS A 
            ON RE.fk_Aluno=A.NrAluno AND RE.fk_AlunoEscola=A.idEscola
        JOIN ExameNacional EN 
            ON RE.fk_ExameNacional=EN.id
        JOIN AlunoEscola AE 
            ON RE.fk_AlunoEscola=E.id
        JOIN EscolaExame EE 
            ON RE.fk_EscolaRealizada=EE.id
        JOIN Disciplina D 
            ON EN.fk_Disciplina=D.id
    )
    WHERE ExamesRealizados.AE.Nome = @Escola;