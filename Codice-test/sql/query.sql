-- Il numero medio di rate dei prestiti associati a conti delle filiali di UD.
SELECT AVG(Prestito.mensilità)
FROM Prestito, Conto, Filiale
WHERE Prestito.conto_associato=Conto.iban AND Conto.filiale=Filiale.nome AND Filiale.città=Udine

-- Tutti i clienti che hanno solo conti risparmio in filiali con almeno 10 e al massimo 20 dipendenti.
CREATE VIEW AS Filiali_1020
    SELECT filiale, COUNT* AS N_dip
    FROM Dipendente
    GROUP BY Dipendente.filiale
    HAVING N_dip between 10 AND 20

SELECT Cliente.id
FROM Cliente, Filiali_1020, Conto, Possiede
WHERE Cliente.id=Possiede.cliente AND Possiede.conto=Conto.iban AND Conto.filiale=Filiale_1020.filiale
    AND NOT EXISTS (
        SELECT *
        FROM ContoCorrente
        WHERE ContoCorrente.iban=Conto.iban
    )

-- Tutti i capi dei dipendenti che gestiscono almeno 3 clienti e che ciascun cliente abbia almeno 100k euro 
-- in conti (inteso come somma di tutti i conti che ha)
CREATE VIEW AS Clienti_ricchi
    SELECT Cliente.id, COUNT* AS soldi
    FROM Cliente, Possiede, Conto
    WHERE Cliente.id=Possiede.cliente AND Conto.iban=Possiede.conto
    GROUP BY Cliente.id
    HAVING soldi > 100000

SELECT DISTINCT capo
FROM Dipendente
WHERE EXISTS (
    SELECT *
    FROM Clienti_ricchi AS C1, Clienti_ricchi AS C2, Clienti_ricchi AS C3
    WHERE C1.gestore=C2.gestore AND C1.gestore=C3.gestore AND C1.id < C2.id AND C2.id < C3.id
)

--Tutti i dipendenti non capo che gestiscono esattamente 2 clienti di cui uno ha solo conti di risparmio e uno ha solo conti correnti.
CREATE VIEW AS Clienti_correnti
    SELECT Possiede.cliente, gestore
    FROM Possiede, Cliente
    WHERE Possiede.cliente=Cliente.ide AND NOT EXISTS (
        SELECT *
        FROM ContoRisparmio
        WHERE ContoRisparmio.iban=Possiede.conto
    )

CREATE VIEW AS Clienti_risparmio
    SELECT Possiede.cliente, gestore
    FROM Possiede, Cliente
    WHERE Possiede.cliente=Cliente.ide AND NOT EXISTS (
        SELECT *
        FROM ContoCorrente
        WHERE ContoCorrente.iban=Possiede.conto
    )

SELECT id
FROM Dipendente
WHERE capo<>id AND EXISTS(
    SELECT *
    FROM Clienti_correnti AS CC1
    WHERE gestore=id AND NOT EXISTS (
        SELECT *
        FROM Clienti_correnti AS CC2
        WHERE gestore=id AND CC1.cliente <> CC2.cliente
    )
)
AND EXISTS(
    SELECT *
    FROM Clienti_risparmio AS CR1
    WHERE gestore=id AND NOT EXISTS (
        SELECT *
        FROM Clienti_risparmio AS CR2
        WHERE gestore=id AND CR1.cliente <> CR2.cliente
    )
)

--Il cliente con il prestito più alto nella filiale di Roma che non è gestito da un dipendente con meno di 3 anni di esperienza.
CREATE VIEW AS ClientiGestiti3
    SELECT Cliente.id
    FROM Cliente, Dipendente
    WHERE gestore=Dipendente.id AND Dipendente.data_assunzione < "DATAOGGI - 3 ANNI"

CREATE VIEW AS Candidati
    SELECT Cliente.id, Prestito.ammontare
    FROM ClientiGestiti3, Filiale, Prestito, Possiede
    WHERE Filiale.città=Roma AND Possiede.cliente = Cliente.id AND Possiede.conto = Prestito.conto_associato

SELECT id
FROM Candidati as C1
WHERE NOT EXISTS (
    SELECT *
    FROM Candidati as C2
    WHERE C2.ammontare > C1.ammontare
)