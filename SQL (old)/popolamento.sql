-- logica di popolamento

alter table Dipendente disable trigger all;
alter table Filiale disable trigger all;

-- inserisco le filiali

alter table Dipendente enable trigger all;
alter table Filiale enable trigger all;

-- inserisco i dipendenti
-- inserisco i clienti
-- inserisco i conti
-- inserisco possiede
-- inserisco i prestiti