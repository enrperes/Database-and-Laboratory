-- ===========================================================================
-- LOGICA DI GESTIONE TRA PRESTITO, RATA E FILIALE (SENZA INTACCARE IL SALDO DEL CONTO)
-- ===========================================================================

-- 1. **Inserimento di un Prestito:**
--    - All'inserimento di un nuovo prestito (trigger `inserisci_prestito`) 
--      si sottrae subito l'importo (`ammontare`) dal campo `attivi` della filiale 
--      associata, simulando così l'erogazione del prestito.
--    - Successivamente (trigger `trigger_crea_rate_prestito`), si creano automaticamente 
--      le rate in `rata`, suddividendo l'ammontare totale in `N` mesi (campo `mesi`).

-- 2. **Pagamento di una Rata:**
--    - Quando una rata viene pagata (`AFTER UPDATE OF data_pagamento ON Rata`), 
--      il trigger `trigger_paga_rata` esegue `paga_rata()`:
--      - Si recupera l'importo della rata e, poiché il prestito non altera il saldo del conto,
--        non si aggiorna il conto.
--      - Si aggiunge invece l'importo pagato agli attivi della filiale, 
--        man mano che il cliente rimborsa il prestito.

-- SCELTE PROGETTUALI:
-- -------------------
-- - L'aggiunta del campo `mensilità` in `prestito` permette di generare rate coerenti 
--   con l'ammontare del prestito, garantendo che la somma delle rate corrisponda 
--   all'importo finanziato.
-- - Il pagamento della rata aggiorna solo gli attivi della filiale.
SET search_path TO banca;

-- ===========================================================================
-- FUNZIONE E TRIGGER PER L'INSERIMENTO DEL PRESTITO
-- ===========================================================================
CREATE OR REPLACE FUNCTION sottrai_prestito()
RETURNS TRIGGER AS $$
DECLARE
    nome_filiale VARCHAR(30);
BEGIN
    -- Recupera la filiale associata al conto del prestito
    SELECT filiale INTO nome_filiale
    FROM conto
    WHERE iban = NEW.conto;

    -- Sottrae l'ammontare del prestito dagli attivi della filiale
    UPDATE filiale
    SET attivi = attivi - NEW.ammontare
    WHERE nome = nome_filiale;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER inserisci_prestito
AFTER INSERT ON prestito
FOR EACH ROW
EXECUTE FUNCTION sottrai_prestito();

-- ===========================================================================
-- FUNZIONE E TRIGGER PER LA CREAZIONE AUTOMATICA DELLE RATE
-- ===========================================================================
CREATE OR REPLACE FUNCTION crea_rate_prestito()
RETURNS TRIGGER AS $$
DECLARE
    importo_mensile DECIMAL(16,2);
    i INT;
BEGIN
    -- Calcola l'importo mensile di ciascuna rata
    importo_mensile := NEW.ammontare / NEW.mensilità;

    -- Crea le rate mensili, incrementando di un mese la scadenza per ciascuna
    FOR i IN 1..NEW.mensilità LOOP
        INSERT INTO rata (numero, prestito, ammontare, data_scadenza)
        VALUES (
            i,
            NEW.codice,
            importo_mensile,
            NEW.data_apertura + (i * '1 month'::interval)
        );
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_crea_rate_prestito
AFTER INSERT ON prestito
FOR EACH ROW
EXECUTE FUNCTION crea_rate_prestito();

-- ===========================================================================
-- FUNZIONE E TRIGGER PER IL PAGAMENTO DELLE RATE
-- ===========================================================================
-- Quando una rata viene pagata (data_pagamento impostata), si aggiorna 
-- solo l'attivo della filiale, non il saldo del conto.
CREATE OR REPLACE FUNCTION paga_rata()
RETURNS TRIGGER AS $$
DECLARE
    iban_conto CHAR(27);
    filiale_nome VARCHAR(30);
BEGIN
    -- Se OLD.data_pagamento non è NULL, significa che la rata era già stata pagata.
    -- In tal caso, non è consentito nessun ulteriore aggiornamento.
    IF OLD.data_pagamento IS NOT NULL THEN
        RAISE EXCEPTION 'La rata è già stata pagata e non può essere modificata ulteriormente.';
    END IF;

    -- Se NEW.data_pagamento passa da NULL a non NULL, significa che la rata sta venendo pagata ora.
    IF NEW.data_pagamento IS NOT NULL THEN
        -- Recupera il conto associato al prestito
        SELECT conto_associato INTO iban_conto FROM prestito WHERE codice = NEW.prestito;

        -- Recupera la filiale associata al conto
        SELECT filiale INTO filiale_nome FROM conto WHERE iban = iban_conto;

        -- Aggiorna gli attivi della filiale incrementandoli dell'ammontare pagato
        UPDATE filiale
        SET attivi = attivi + NEW.ammontare
        WHERE nome = filiale_nome;
        
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'La rata è già stata pagata e non può essere modificata ulteriormente.';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_paga_rata
AFTER UPDATE OF data_pagamento ON rata
FOR EACH ROW
EXECUTE FUNCTION paga_rata();

-- RISULTATO:
-- Con questa configurazione:
-- - L'apertura di un prestito riduce gli attivi della filiale, senza influenzare il saldo dei conti.
-- - Le rate vengono create automaticamente, assicurando coerenza tra ammontare e mensilità.
-- - Il pagamento di ogni rata aumenta gli attivi della filiale, senza toccare il saldo dei conti