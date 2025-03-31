CREATE TRIGGER inserisci_prestito
AFTER INSERT ON prestito
FOR EACH ROW
EXECUTE FUNCTION sottrai_prestito();
