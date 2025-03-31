CREATE OR REPLACE FUNCTION check_iban_uniqueness_contocorrente()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM contorisparmio WHERE iban = NEW.iban) THEN
        RAISE EXCEPTION 'Impossibile inserire IBAN % in contocorrente, è già presente in contorisparmio!', NEW.iban;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
