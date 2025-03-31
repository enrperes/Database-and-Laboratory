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
