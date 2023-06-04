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