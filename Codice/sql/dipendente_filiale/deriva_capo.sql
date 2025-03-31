CREATE OR REPLACE FUNCTION deriva_capo()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM filiale
        WHERE manager = NEW.id AND nome != NEW.filiale
    ) THEN
        RAISE EXCEPTION 
            'Non è possibile cambiare la filiale del dipendente % perché è manager di una altra filiale.', 
            NEW.id;
    END IF;

    NEW.capo := (SELECT manager FROM filiale WHERE nome = NEW.filiale);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
