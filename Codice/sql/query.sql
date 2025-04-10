-- Il numero medio di rate dei prestiti associati a conti delle filiali di UD.
SELECT AVG(mensilità) AS media_rate
  FROM prestito, conto, filiale
  WHERE prestito.conto = conto.iban
    AND conto.filiale = filiale.nome
    AND filiale.città = 'Udine';

-- Tutti i clienti che hanno solo conti risparmio in filiali con almeno 10 e al massimo 20 dipendenti.
CREATE OR REPLACE VIEW filiali_3032 AS
  SELECT filiale, COUNT(*) AS n_dip
  FROM dipendente
  GROUP BY filiale
  HAVING COUNT(*) BETWEEN 30 AND 32;

SELECT cliente.id
  FROM cliente, possiede, conto, filiali_3032
  WHERE cliente.id = possiede.cliente
    AND possiede.conto = conto.iban
    AND conto.filiale = filiali_3032.filiale
    AND NOT EXISTS (
      SELECT 1
      FROM contocorrente
      WHERE contocorrente.iban = conto.iban
    );

-- Tutti i capi dei dipendenti che gestiscono almeno 3 clienti e che ciascun cliente abbia almeno 100k euro 
-- in conti (inteso come somma di tutti i conti che ha)
CREATE OR REPLACE VIEW clienti_ricchi AS
  SELECT cliente.id, SUM(conto.saldo) AS soldi, cliente.gestore
  FROM cliente, possiede, conto
  WHERE cliente.id = possiede.cliente
    AND conto.iban = possiede.conto
  GROUP BY cliente.id, cliente.gestore
  HAVING SUM(conto.saldo) > 100000;

SELECT DISTINCT capo
  FROM dipendente
  WHERE EXISTS (
    SELECT *
    FROM clienti_ricchi c1, clienti_ricchi c2, clienti_ricchi c3
    WHERE c1.gestore = dipendente.id
      AND c2.gestore = dipendente.id
      AND c3.gestore = dipendente.id
      AND c1.id < c2.id AND c2.id < c3.id
  );
)

--Tutti i dipendenti non capo che gestiscono esattamente 2 clienti di cui uno ha solo conti di risparmio e uno ha solo conti correnti.
CREATE OR REPLACE VIEW clienti_correnti AS
  SELECT possiede.cliente, cliente.gestore
  FROM possiede, cliente
  WHERE possiede.cliente = cliente.id
    AND NOT EXISTS (
      SELECT 1
      FROM contorisparmio
      WHERE contorisparmio.iban = possiede.conto
    );

  CREATE OR REPLACE VIEW clienti_risparmio AS
  SELECT possiede.cliente, cliente.gestore
  FROM possiede, cliente
  WHERE possiede.cliente = cliente.id
    AND NOT EXISTS (
      SELECT 1
      FROM contocorrente
      WHERE contocorrente.iban = possiede.conto
    );

 SELECT id
  FROM dipendente
  WHERE capo <> id
    AND EXISTS (
      SELECT *
      FROM clienti_correnti cc1
      WHERE cc1.gestore = dipendente.id
        AND NOT EXISTS (
          SELECT *
          FROM clienti_correnti cc2
          WHERE cc2.gestore = dipendente.id
            AND cc1.cliente <> cc2.cliente
        )
    )
    AND EXISTS (
      SELECT *
      FROM clienti_risparmio cr1
      WHERE cr1.gestore = dipendente.id
        AND NOT EXISTS (
          SELECT *
          FROM clienti_risparmio cr2
          WHERE cr2.gestore = dipendente.id
            AND cr1.cliente <> cr2.cliente
        )
    );

--Il cliente con il prestito più alto nella filiale di Roma che non è gestito da un dipendente con meno di 3 anni di esperienza.
 CREATE OR REPLACE VIEW clienti_gestiti_3 AS
  SELECT cliente.id
  FROM cliente, dipendente
  WHERE cliente.gestore = dipendente.id
    AND dipendente.data_assunzione < DATE '", data_limite, "';

 CREATE OR REPLACE VIEW candidati AS
  SELECT cliente.id, prestito.ammontare
  FROM cliente, clienti_gestiti_3, possiede, prestito, conto, filiale
  WHERE cliente.id = clienti_gestiti_3.id
    AND cliente.id = possiede.cliente
    AND possiede.conto = prestito.conto
    AND prestito.conto = conto.iban
    AND conto.filiale = filiale.nome
    AND filiale.città = 'Roma';

  SELECT id, ammontare
  FROM candidati c1
  WHERE NOT EXISTS (
    SELECT 1
    FROM candidati c2
    WHERE c2.ammontare > c1.ammontare
  );

