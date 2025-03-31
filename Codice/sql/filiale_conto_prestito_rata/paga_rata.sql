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
        SELECT conto INTO iban_conto FROM prestito WHERE codice = NEW.prestito;

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
