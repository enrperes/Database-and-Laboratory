-- logica di popolamento

alter table dipendente disable trigger all;
alter table filiale disable trigger all;

-- inserisco le filiali
-- inserisco i dipendenti

alter table dipendente enable trigger all;
alter table filiale enable trigger all;

-- inserisco i clienti
-- inserisco i conti
-- inserisco possiede
-- inserisco i prestiti

UPDATE rata
SET data_pagamento = CURRENT_DATE
WHERE data_scadenza < CURRENT_DATE
AND data_pagamento IS NULL;
