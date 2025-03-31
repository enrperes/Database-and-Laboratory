CREATE TRIGGER trigger_verifica_saldo
BEFORE UPDATE OF saldo ON conto
FOR EACH ROW
EXECUTE FUNCTION verifica_saldo();
