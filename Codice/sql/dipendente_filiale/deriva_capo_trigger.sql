CREATE TRIGGER trigger_aggiornamento_dipendente
BEFORE INSERT OR UPDATE OF filiale ON dipendente
FOR EACH ROW
EXECUTE FUNCTION deriva_capo();
