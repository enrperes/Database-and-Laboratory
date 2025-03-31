CREATE TRIGGER trg_contorisparmio_iban
BEFORE INSERT ON contorisparmio
FOR EACH ROW
EXECUTE PROCEDURE check_iban_uniqueness_contorisparmio();
