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
		   E.Nome AS "Escola do Aluno",
		   CONCAT(D.Nome, ' -  Fase ', EN.Fase, ' ', EN.Ano) AS "Exame",
		   RE.NotaFinal AS "Nota Final", 
		   RE.NotaRevisada AS "Nota Revisada"
	FROM 
		RealizacaoExame RE JOIN Aluno AS A 
			ON RE.fk_Aluno=A.NrAluno AND RE.fk_AlunoEscola=A.idEscola
		JOIN ExameNacional EN 
			ON RE.fk_ExameNacional=EN.id
		JOIN Escola E 
			ON RE.fk_AlunoEscola=E.id
		JOIN Disciplina D 
			ON EN.fk_Disciplina=D.id
	ORDER BY RE.NotaFinal ASC;

CREATE VIEW vwExamesPorNotaMédia AS
    SELECT CONCAT(D.Nome, ' -  Fase ', EN.Fase, ' ', EN.Ano) AS "Exame",
           COUNT(*) AS "Nº de Alunos",
           AVG(IF(RE.NotaRevisada IS NULL,RE.NotaFinal,RE.NotaRevisada)) AS "Nota Média"
    FROM 
        RealizacaoExame RE JOIN ExameNacional EN
            ON RE.fk_ExameNacional = EN.id
        JOIN Disciplina D
            ON EN.fk_Disciplina = D.id
    GROUP BY D.id, EN.Fase, EN.Ano
    ORDER BY "Nota Média" ASC;

CREATE VIEW vwExamesporEscola AS
    SELECT E.Nome AS "Escola",
           COUNT(*) AS "Nº de Alunos",
           AVG(IF(RE.NotaRevisada IS NULL,RE.NotaFinal,RE.NotaRevisada)) AS "Nota Média"
    FROM
        RealizacaoExame RE JOIN ExameNacional EN
            ON RE.fk_ExameNacional = EN.id
        JOIN Disciplina D
            ON EN.fk_Disciplina = D.id
        JOIN Escola E
            ON RE.fk_AlunoEscola = E.id
    GROUP BY E.id
    ORDER BY "Nota Média" ASC;

CREATE VIEW vwExamesPorConcelhoDadosSocioEconomicos AS
    SELECT C.Nome AS "Concelho",
           AVG(E.IdadeMediaProfessores) AS "Idade Média dos Docentes",
           AVG(E.NumeroMedioAlunosPorTurma) AS "Nº Médio de Alunos por Turma",
           C.IdadeMediaPopulacao AS "Idade Média População",
           C.RendimentoMedioAgregadoFamiliar AS "Rendimento Médio do Agregado Familiar",
           COUNT(*) AS "Nº de Alunos",
           AVG(IF(RE.NotaRevisada IS NULL,RE.NotaFinal,RE.NotaRevisada)) AS "Nota Média"
    FROM
        RealizacaoExame RE JOIN ExameNacional EN
            ON RE.fk_ExameNacional = EN.id
        JOIN Disciplina D
            ON EN.fk_Disciplina = D.id
        JOIN Escola E
            ON RE.fk_AlunoEscola = E.id
        JOIN Concelho C
            ON E.fk_Concelho = C.id
    GROUP BY C.id
    ORDER BY "Nota Média" ASC;

CREATE VIEW vwAlunosPorNotaMédia AS
    SELECT A.Nome AS "Aluno",
           E.Nome AS "Escola",
           AVG(IF(RE.NotaRevisada IS NULL,RE.NotaFinal,RE.NotaRevisada)) AS "Nota Média"
    FROM 
        RealizacaoExame RE JOIN Aluno A
            ON RE.fk_Aluno = A.NrAluno AND RE.fk_AlunoEscola = A.idEscola
        JOIN Escola E
            ON A.idEscola = E.id
    GROUP BY A.NrAluno, A.idEscola
    ORDER BY "Nota Média" ASC;

CREATE VIEW vwAnosPorNotaMédia AS
    SELECT EN.Ano AS "Ano",
           AVG(IF(RE.NotaRevisada IS NULL,RE.NotaFinal,RE.NotaRevisada)) AS "Nota Média"
    FROM 
        RealizacaoExame RE JOIN ExameNacional EN
            ON RE.fk_ExameNacional = EN.id
    GROUP BY EN.Ano
    ORDER BY "Nota Média" ASC;


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
		RealizacaoExame AS RE JOIN Aluno AS A 
			ON RE.fk_Aluno=A.NrAluno AND RE.fk_AlunoEscola=A.idEscola
		JOIN ExameNacional EN 
			ON RE.fk_ExameNacional=EN.id
		JOIN Escola E 
			ON RE.fk_AlunoEscola=E.id
		JOIN Disciplina D 
			ON EN.fk_Disciplina=D.id
	WHERE E.Nome = Escola
    ORDER BY RE.NotaFinal ASC;
END &&

CREATE PROCEDURE NotaMédiaExame (IN Disciplina_Nome VARCHAR(255),IN Fase CHAR,IN Ano INT)
BEGIN
	SELECT AVG(IF(RE.NotaRevisada IS NULL,RE.NotaFinal,RE.NotaRevisada)) AS "Nota Média"
	FROM
		ExameNacional EN JOIN RealizacaoExame AS RE
			ON RE.fk_ExameNacional=EN.id
		JOIN Disciplina D 
			ON EN.fk_Disciplina=D.id
	WHERE D.Nome = Disciplina_Nome AND EN.Ano=Ano AND EN.Fase=Fase;
END &&

CREATE PROCEDURE NotaMédiaExamePorCurso (IN Disciplina_Nome VARCHAR(255),IN Fase CHAR,IN Ano INT, IN Curso_Nome VARCHAR(255))
BEGIN
	SELECT AVG(IF(RE.NotaRevisada IS NULL,RE.NotaFinal,RE.NotaRevisada)) AS "Nota Média"
	FROM
		ExameNacional EN JOIN RealizacaoExame AS RE
			ON RE.fk_ExameNacional=EN.id
		JOIN Disciplina D 
			ON EN.fk_Disciplina=D.id
        JOIN Aluno A
            ON RE.fk_Aluno=A.NrAluno AND RE.fk_AlunoEscola=A.idEscola
        JOIN Curso C
            ON A.fk_Curso=C.id
	WHERE D.Nome = Disciplina_Nome AND EN.Ano=Ano AND EN.Fase=Fase AND C.Nome = Curso_Nome;
END &&

CREATE PROCEDURE NotaMédiaExamePorEscola (IN Disciplina_Nome VARCHAR(255),IN Fase CHAR,IN Ano INT, IN Escola_Nome VARCHAR(255))
BEGIN
	SELECT AVG(IF(RE.NotaRevisada IS NULL,RE.NotaFinal,RE.NotaRevisada)) AS "Nota Média"
	FROM
		ExameNacional EN JOIN RealizacaoExame AS RE
			ON RE.fk_ExameNacional=EN.id
		JOIN Disciplina D 
			ON EN.fk_Disciplina=D.id
        JOIN Escola E
            ON RE.fk_AlunoEscola = E.id
	WHERE D.Nome = Disciplina_Nome AND EN.Ano=Ano AND EN.Fase=Fase AND E.Nome = Escola_Nome;
END &&

CREATE PROCEDURE NotaMédiaExamePorCursoeEscola (IN Disciplina_Nome VARCHAR(255),IN Fase CHAR,IN Ano INT, IN Curso_Nome VARCHAR(255), IN Escola_Nome VARCHAR(255))
BEGIN
	SELECT AVG(IF(RE.NotaRevisada IS NULL,RE.NotaFinal,RE.NotaRevisada)) AS "Nota Média"
	FROM
		ExameNacional EN JOIN RealizacaoExame AS RE
			ON RE.fk_ExameNacional=EN.id
		JOIN Disciplina D 
			ON EN.fk_Disciplina=D.id
        JOIN Aluno A
            ON RE.fk_Aluno=A.NrAluno AND RE.fk_AlunoEscola=A.idEscola
        JOIN Curso C
            ON A.fk_Curso=C.id
        JOIN Escola E
            ON RE.fk_AlunoEscola = E.id
	WHERE D.Nome = Disciplina_Nome AND EN.Ano=Ano AND EN.Fase=Fase AND C.Nome = Curso_Nome AND E.Nome = Escola_Nome;
END &&

DELIMITER ;