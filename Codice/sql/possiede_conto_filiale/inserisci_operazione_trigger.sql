CREATE TRIGGER trigger_inserisci_operazione
AFTER UPDATE ON possiede
FOR EACH ROW
EXECUTE FUNCTION inserisci_operazione();
