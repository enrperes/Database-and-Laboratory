CREATE OR REPLACE FUNCTION check_iban_uniqueness_contorisparmio()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM contocorrente WHERE iban = NEW.iban) THEN
        RAISE EXCEPTION 'Impossibile inserire IBAN % in contorisparmio, è già presente in contocorrente!', NEW.iban;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
