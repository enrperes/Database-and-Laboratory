--## 1. Distribuzione mensilità per i prestiti di conti con > 100.000 che sono gestiti da un gestore. ----
CREATE OR REPLACE VIEW clienti_gestiti AS
  SELECT cliente.id, cliente.gestore
  FROM cliente, dipendente
  WHERE cliente.gestore = dipendente.id;

SELECT mensilità, COUNT(*)
    FROM clienti_gestiti, possiede, conto, prestito
    WHERE clienti_gestiti.id = possiede.cliente
    AND possiede.conto = conto.iban
    AND conto.saldo > 50.000
    AND possiede.conto = prestito.conto
    GROUP BY mensilità

--## 2. soldi gestiti dai gestori in funzione dell'anzianità ----
CREATE OR REPLACE VIEW dipendenti_gestori AS
  SELECT dipendente.data_assunzione, dipendente.id
  FROM cliente, dipendente
  WHERE cliente.gestore = dipendente.id;

SELECT SUM(conto.saldo) as skey, dipendenti_gestori.data_assunzione 
  FROM clienti_gestiti, possiede, conto, dipendenti_gestori
  WHERE clienti_gestiti.id = possiede.cliente
  AND possiede.conto = conto.iban
  AND dipendenti_gestori.id = clienti_gestiti.gestore 
  GROUP BY dipendenti_gestori.data_assunzione;


-- # 3. Per filiale, il numero di conti cointestatari con un prestito afferente ----

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


