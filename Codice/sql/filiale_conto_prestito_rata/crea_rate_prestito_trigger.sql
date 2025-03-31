CREATE TRIGGER trigger_crea_rate_prestito
AFTER INSERT ON prestito
FOR EACH ROW
EXECUTE FUNCTION crea_rate_prestito();
