CREATE OR REPLACE TRIGGER trigger_paga_rata
AFTER UPDATE OF data_pagamento ON rata
FOR EACH ROW
EXECUTE FUNCTION paga_rata();
