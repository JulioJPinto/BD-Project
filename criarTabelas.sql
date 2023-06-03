CREATE SCHEMA IF NOT EXISTS edudata;
USE edudata;

CREATE TABLE Aluno (
    NrAluno INT,
    idEscola INT,
    Nome VARCHAR(255) NOT NULL,
    Escalao CHAR,
    Idade INT NOT NULL,
    DataDeNascimento DATE NOT NULL,
    fk_Escola INT,
    fk_Curso INT,
    PRIMARY KEY (NrAluno, idEscola)
);

CREATE TABLE Curso (
    id INT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    Descricao VARCHAR(255) NOT NULL
);

CREATE TABLE Escola (
    id INT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    Tipo CHAR NOT NULL,
    IdadeMediaProfessores FLOAT NOT NULL,
    NumeroMedioAlunosPorTurma FLOAT NOT NULL,
    fk_Concelho INT
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
    fk_ExameNacional INT,
    fk_Escola INT
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
    Nome VARCHAR(255) NOT NULL,
    fk_Escola INT
);
 
ALTER TABLE Aluno ADD CONSTRAINT FK_Aluno_Escola
    FOREIGN KEY (fk_Escola)
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
 
ALTER TABLE Concelho ADD CONSTRAINT FK_Concelho_PresidenteConcelho
    FOREIGN KEY (fk_PresidenteConcelho)
    REFERENCES PresidenteConcelho (id);
 
ALTER TABLE ExameNacional ADD CONSTRAINT FK_ExameNacional_Disciplina
    FOREIGN KEY (fk_Disciplina)
    REFERENCES Disciplina (id)
    ON DELETE RESTRICT;
 
ALTER TABLE RealizacaoExame ADD CONSTRAINT FK_RealizacaoExame_Escola
    FOREIGN KEY (fk_Escola)
    REFERENCES Escola (id);
 
ALTER TABLE RealizacaoExame ADD CONSTRAINT FK_RealizacaoExame_ExameNacional
    FOREIGN KEY (fk_ExameNacional)
    REFERENCES ExameNacional (id);
 
ALTER TABLE RealizacaoExame ADD CONSTRAINT FK_RealizacaoExame_Aluno
    FOREIGN KEY (fk_Aluno, fk_Escola)
    REFERENCES Aluno (NrAluno, idEscola); # FIX fk_Escola != idEscola
 
ALTER TABLE DiretorEscola ADD CONSTRAINT FK_DiretorEscola_Escola
    FOREIGN KEY (fk_Escola)
    REFERENCES Escola (id);