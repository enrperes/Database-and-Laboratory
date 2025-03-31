CREATE OR REPLACE FUNCTION valida_manager()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT *
        FROM dipendente
        WHERE id = NEW.manager AND filiale = NEW.nome
    ) THEN
        RAISE EXCEPTION 
            'Il manager % non lavora nella filiale %', 
            NEW.manager, NEW.nome;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
