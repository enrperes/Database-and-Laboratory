CREATE TRIGGER trigger_aggiorna_attivi_filiale
AFTER INSERT OR UPDATE OF saldo ON conto
FOR EACH ROW
EXECUTE FUNCTION aggiorna_attivi_filiale();
