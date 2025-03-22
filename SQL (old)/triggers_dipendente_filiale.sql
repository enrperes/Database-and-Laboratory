-- ==========================================
-- LOGICA DI GESTIONE TRA DIPENDENTE E FILIALE
-- ==========================================

-- Questo file definisce le relazioni tra le tabelle `Dipendente` e `Filiale`,
-- sfruttando trigger, funzioni e vincoli di chiave esterna per garantire:
-- - Coerenza dei dati
-- - Aggiornamenti automatici
-- - Rispetto dell'integrità referenziale

-- INTEGRAZIONE CON I VINCOLI DI CHIAVE ESTERNA:
-- ---------------------------------------------
-- Le chiavi esterne su `Filiale` agiscono come veri e propri "trigger mascherati":
-- - `ON DELETE RESTRICT` su `manager` impedisce la cancellazione di un dipendente se è manager.
-- - `ON DELETE RESTRICT` su `nome` impedisce la cancellazione di una filiale che ha dipendenti.
-- - `ON UPDATE CASCADE` su `manager` e `nome` aggiorna automaticamente le relazioni
--   tra dipendenti e filiali, garantendo che eventuali cambiamenti di manager o nome
--   di filiale si riflettano sui dipendenti associati.

-- PANORAMICA DELLE OPERAZIONI GESTITE:
-- ------------------------------------

-- 1. **INSERIMENTO O MODIFICA DI UN DIPENDENTE:**
--    - Se si inserisce un nuovo dipendente o si cambia la sua filiale, 
--      il trigger `trigger_aggiornamento_dipendente` esegue la funzione `deriva_capo()`
--      per assegnare automaticamente il "capo" del dipendente, corrispondente al manager 
--      della filiale associata.
   
-- 2. **VALIDAZIONE DEL MANAGER IN FILIALE:**
--    - Quando si assegna o modifica il manager di una filiale, il trigger 
--      `trigger_validazione_manager` esegue `valida_manager()` per verificare 
--      che il manager lavori effettivamente in quella filiale.

-- 3. **AGGIORNAMENTO AUTOMATICO DEI DIPENDENTI:**
--    - Non c'è una funzione dedicata perché l'aggiornamento dei capi dei dipendenti 
--      in caso di modifica del manager di una filiale è già garantito dalle chiavi 
--      esterne con `ON UPDATE CASCADE`. In questo modo non è necessario un trigger aggiuntivo.

-- 4. **BLOCCO DELLA CANCELLAZIONE DI UN MANAGER:**
--    - `ON DELETE RESTRICT` impedisce di cancellare un manager finché è assegnato ad una filiale.

-- 5. **CANCELLAZIONE DI UNA FILIALE CON DIPENDENTI:**
--    - Prima di eliminare una filiale con dipendenti, è necessario spostarli altrove
--      e rimuovere temporaneamente i vincoli. Questo garantisce consistenza nel processo.

-- 6. **CONSISTENZA DEI DATI:**
--    - Ogni modifica è soggetta a controlli di consistenza e integrità, garantendo dati sempre coerenti.
SET search_path TO banca;

-- FUNZIONE: deriva_capo()
-- Quando si inserisce o aggiorna la filiale di un dipendente:
-- - Verifica che il dipendente non sia manager di una filiale.
-- - Imposta il suo capo al manager della filiale indicata.

CREATE OR REPLACE FUNCTION deriva_capo()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica che il dipendente non sia già manager in un'altra filiale
    IF EXISTS (
        SELECT 1
        FROM Filiale
        WHERE manager = NEW.id AND nome != NEW.filiale
    ) THEN
        RAISE EXCEPTION 'Non è possibile cambiare la filiale del dipendente % perché è manager di una filiale.', NEW.id;
    END IF;

    NEW.capo := (SELECT manager FROM Filiale WHERE nome = NEW.filiale);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: trigger_aggiornamento_dipendente
-- BEFORE UPDATE OR INSERT OF filiale ON Dipendente:
-- Assegna automaticamente il capo al dipendente, chiamando deriva_capo().
CREATE TRIGGER trigger_aggiornamento_dipendente_insert
BEFORE INSERT ON Dipendente
FOR EACH ROW
EXECUTE FUNCTION deriva_capo();

CREATE TRIGGER trigger_aggiornamento_dipendente_update
BEFORE UPDATE OF filiale ON Dipendente
FOR EACH ROW
EXECUTE FUNCTION deriva_capo();

-- FUNZIONE: valida_manager()
-- Verifica che il manager assegnato a una filiale lavori effettivamente in quella filiale.
CREATE OR REPLACE FUNCTION valida_manager()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT *
        FROM Dipendente
        WHERE id = NEW.manager AND filiale = NEW.nome
    ) THEN
        RAISE EXCEPTION 'Il manager % non lavora nella filiale %', NEW.manager, NEW.nome;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: trigger_validazione_manager
-- BEFORE INSERT OR UPDATE OF manager ON Filiale:
-- Controlla la validità del nuovo manager chiamando valida_manager().
CREATE TRIGGER trigger_validazione_manager
BEFORE INSERT OR UPDATE OF manager ON Filiale
FOR EACH ROW
EXECUTE FUNCTION valida_manager();

-- RISULTATO:
-- Con questa configurazione:
-- - L'assegnazione del capo ai dipendenti avviene in automatico.
-- - La validazione del manager assicura coerenza tra manager e filiale.
-- - La cancellazione dei manager è impedita finché non si cambiano le relazioni esistenti.
-- - Le chiavi esterne con ON UPDATE CASCADE garantiscono l'aggiornamento dei riferimenti 
--   senza bisogno di trigger aggiuntivi.