CREATE TRIGGER trigger_controllo_gestore
BEFORE INSERT OR UPDATE OF gestore ON cliente
FOR EACH ROW
EXECUTE FUNCTION controllo_gestore();
