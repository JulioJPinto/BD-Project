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
    id INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(255) NOT NULL,
    Descricao TEXT
);

CREATE TABLE escola (
    id INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(255) NOT NULL,
    Tipo CHAR NOT NULL,
    IdadeMediaProfessores FLOAT NOT NULL,
    NumeroMedioAlunosPorTurma FLOAT NOT NULL,
    fk_Concelho INT,
    fk_DiretorEscola INT
);

CREATE TABLE concelho (
    id INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(255) NOT NULL,
    IdadeMediaPopulacao FLOAT NOT NULL,
    RendimentoMedioAgregadoFamiliar FLOAT NOT NULL,
    NumeroMedioFilhos FLOAT NOT NULL,
    fk_PresidenteConcelho INT
);

CREATE TABLE examenacional (
    id INT PRIMARY KEY AUTO_INCREMENT,
    Ano INT NOT NULL,
    Fase CHAR NOT NULL,
    DataHora DATETIME NOT NULL,
    TempoNecessario INT NOT NULL,
    TempoTolerancia INT NOT NULL,
    fk_Disciplina INT
);

CREATE TABLE realizacaoexame (
    id INT PRIMARY KEY AUTO_INCREMENT,
    NotaFinal FLOAT,
    NotaRevisada FLOAT,
    fk_Aluno INT,
    fk_AlunoEscola INT,
    fk_ExameNacional INT,
    fk_EscolaRealizada INT
);

CREATE TABLE disciplina (
    id INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(255) NOT NULL
);

CREATE TABLE presidenteconcelho (
    id INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(255) NOT NULL
);

CREATE TABLE diretorescola (
    id INT PRIMARY KEY AUTO_INCREMENT,
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
		realizacaoexame RE 
        JOIN aluno A
			ON RE.fk_Aluno=A.NrAluno AND RE.fk_AlunoEscola=A.idEscola
		JOIN examenacional EN 
			ON RE.fk_ExameNacional=EN.id
		JOIN escola E 
			ON RE.fk_AlunoEscola=E.id
		JOIN disciplina D 
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

CREATE PROCEDURE CriarDiretorEscola (IN Nome VARCHAR(255))
BEGIN
    INSERT INTO diretorescola (Nome) VALUES (Nome);
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

CREATE TRIGGER CriarRoleDiretorEscola
AFTER INSERT ON diretorescola
FOR EACH ROW
BEGIN
    DECLARE diretor_id INT;
    DECLARE escola_id INT;

    SET diretor_id = NEW.id;
    SET escola_id = (SELECT fk_DiretorEscola FROM escola WHERE fk_DiretorEscola = diretor_id);

    IF escola_id IS NOT NULL THEN
        SET @username = CONCAT('diretor_', NEW.Nome, '@localhost');
        SET @password = '1234';
        SET @query = CONCAT('CREATE USER \'', @username, '\'@\'localhost\' IDENTIFIED BY \'', @password, '\'');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET @grantQuery = CONCAT('GRANT SELECT, UPDATE ON edudata.escola TO \'', @username, '\'@\'localhost\' WHERE fk_DiretorEscola = ', diretor_id);
        PREPARE grantStmt FROM @grantQuery;
        EXECUTE grantStmt;
        DEALLOCATE PREPARE grantStmt;
    END IF;
END &&

CREATE PROCEDURE CriarPresidenteConcelho (IN Nome VARCHAR(255))
BEGIN
    INSERT INTO presidenteconcelho (Nome) VALUES (Nome);
END &&

CREATE TRIGGER CriarRolePresidenteConcelho
AFTER INSERT ON presidenteconcelho
FOR EACH ROW
BEGIN
    DECLARE presidente_id INT;
    DECLARE concelho_id INT;

    SET presidente_id = NEW.id;
    SET concelho_id = (SELECT fk_PresidenteConcelho FROM concelho WHERE fk_PresidenteConcelho = presidente_id);

    IF concelho_id IS NOT NULL THEN
        SET @username = CONCAT('presidente_', NEW.Nome, '@localhost');
        SET @password = '1234';
        SET @query = CONCAT('CREATE USER \'', @username, '\'@\'localhost\' IDENTIFIED BY \'', @password, '\'');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET @grantQuery = CONCAT('GRANT SELECT, UPDATE ON edudata.concelho TO \'', @username, '\'@\'localhost\' WHERE fk_PresidenteConcelho = ', presidente_id);
        PREPARE grantStmt FROM @grantQuery;
        EXECUTE grantStmt;
        DEALLOCATE PREPARE grantStmt;
    END IF;
END &&

DELIMITER ;
