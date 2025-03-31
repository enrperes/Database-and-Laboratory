CREATE TRIGGER trg_contocorrente_iban
BEFORE INSERT ON contocorrente
FOR EACH ROW
EXECUTE PROCEDURE check_iban_uniqueness_contocorrente();
