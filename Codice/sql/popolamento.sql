-- logica di popolamento

alter table Dipendente disable trigger all;
alter table Filiale disable trigger all;

-- inserisco le filiali
-- inserisco i dipendenti

alter table Dipendente enable trigger all;
alter table Filiale enable trigger all;

-- inserisco i clienti
-- inserisco i conti
-- inserisco possiede
-- inserisco i prestiti

UPDATE Rata
SET data_pagamento = CURRENT_DATE
WHERE data_scadenza < CURRENT_DATE
AND data_pagamento IS NULL;