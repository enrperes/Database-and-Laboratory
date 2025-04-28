CREATE OR REPLACE FUNCTION controllo_gestore()
RETURNS TRIGGER AS $$

BEGIN
    IF EXISTS (
        SELECT 1
        FROM possiede as p1
        WHERE p1.cliente = NEW.id AND EXISTS (
            SELECT *
            FROM possiede as p2, cliente
            WHERE p1.conto = p2.conto AND p2.cliente = cliente.id AND p2.cliente != p1.cliente 
            AND cliente.gestore IS NOT NULL AND NEW.gestore IS NOT NULL
            AND cliente.gestore != NEW.gestore
            
        )
    ) THEN
        RAISE EXCEPTION 
            'Non è possibile inserire/modificare il cliente %, causa una sovrapposizione di gestori.', 
            NEW.id;
    END IF;

    RETURN NEW;
END;

$$ LANGUAGE plpgsql;
