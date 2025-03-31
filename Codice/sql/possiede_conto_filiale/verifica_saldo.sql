CREATE OR REPLACE FUNCTION verifica_saldo()
RETURNS TRIGGER AS $$
DECLARE
    scoperto_var NUMERIC := 0;
    is_conto_corrente BOOLEAN := FALSE;
BEGIN
    -- Verifica se il conto è un conto_corrente
    SELECT EXISTS (SELECT 1 FROM contocorrente WHERE iban = NEW.iban)
    INTO is_conto_corrente;

    -- Se è conto_corrente, recupera lo scoperto
    IF is_conto_corrente THEN
        SELECT scoperto INTO scoperto_var
        FROM contocorrente WHERE iban = NEW.iban;
    ELSE
        RAISE EXCEPTION 
            'Operazione non concessa, conto di risparmio';
    END IF;

    -- Controllo del nuovo saldo
    IF  NEW.saldo < -scoperto_var THEN
        RAISE EXCEPTION 
            'Errore: saldo insufficiente. 
            Operazione annullata.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
