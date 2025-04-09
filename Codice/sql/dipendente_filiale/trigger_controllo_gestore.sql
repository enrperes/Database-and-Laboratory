CREATE TRIGGER trigger_controllo_gestore
BEFORE INSERT OR UPDATE OF gestore ON cliente
FOR EACH ROW
EXECUTE FUNCTION controllo_gestore();

CREATE OR REPLACE FUNCTION controllo_gestore()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM possiede as p1
        WHERE p1.cliente = NEW.id AND EXISTS (
            SELECT *
            FROM possiede as p2, cliente
            WHERE p1.conto = p2.conto AND p2.cliente = cliente.id AND cliente.gestore != NEW.gestore
            AND cliente.gestore IS NOT NULL AND NEW.gestore IS NOT NULL
        )
    ) THEN
        RAISE EXCEPTION 
            'Non è possibile inserire/modificare il cliente %, causa una sovrapposizione di gestori.', 
            NEW.id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;