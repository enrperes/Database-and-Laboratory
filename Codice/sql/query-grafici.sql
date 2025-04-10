--Il numero di conti cointestati per filiale che hanno almeno un prestito associato.
CREATE VIEW conti_cointetsati AS
SELECT possiede.conto, conto.filiale
FROM possiede as p1, conto
WHERE p1.conto = conto.iban AND EXISTS (
SELECT *
FROM possiede as p2
WHERE p1.conto = p2.conto AND p1.cliente < p2.cliente)
--Giusto mettere solo < e non <> perchè se no conto doppi?


SELECT filiale, COUNT(*)
FROM conti_cointestati, prestito
WHERE conti_cointestati.conto = prestito.conto
GROUP BY filiale
