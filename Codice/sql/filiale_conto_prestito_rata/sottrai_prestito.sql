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
