CREATE OR REPLACE FUNCTION aggiorna_attivi_filiale()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE filiale
        SET attivi = attivi + NEW.saldo
        WHERE nome = NEW.filiale;
    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE filiale
        SET attivi = attivi + (NEW.saldo - OLD.saldo)
        WHERE nome = NEW.filiale;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
