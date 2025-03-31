CREATE TRIGGER trigger_validazione_manager
BEFORE INSERT OR UPDATE OF manager ON filiale
FOR EACH ROW
EXECUTE FUNCTION valida_manager();
