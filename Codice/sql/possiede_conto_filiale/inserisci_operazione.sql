CREATE OR REPLACE FUNCTION inserisci_operazione()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo_operazione IN ('prelievo', 'bancomat') THEN
        UPDATE conto
        SET saldo = saldo - NEW.importo_operazione
        WHERE iban = NEW.conto;
    ELSIF NEW.tipo_operazione = 'versamento' THEN
        UPDATE conto
        SET saldo = saldo + NEW.importo_operazione
        WHERE iban = NEW.conto;
    ELSE 
        RAISE EXCEPTION 
            'Operazione apertura non ripetibile';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
