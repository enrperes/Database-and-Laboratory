-- ==========================================
-- LOGICA DI GESTIONE TRA DIPENDENTE E FILIALE
-- ==========================================

-- INTEGRAZIONE CON I VINCOLI DI CHIAVE ESTERNA:
-- ---------------------------------------------
-- - `ON DELETE RESTRICT` su `manager` impedisce la cancellazione di un dipendente se è manager.
-- - `ON DELETE RESTRICT` su `nome` impedisce la cancellazione di una filiale che ha dipendenti.
-- - `ON UPDATE CASCADE` su `manager` e `nome` aggiorna automaticamente le relazioni
--   tra dipendenti e filiali, garantendo che eventuali cambiamenti di manager o nome
--   di filiale si riflettano sui dipendenti associati.

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
--      e rimuovere temporaneamente i vincoli. 
SET search_path TO banca;

-- ===========================================================================
-- FUNZIONE E TRIGGER PER DERIVARE IL CAPO DEI DIPENDENTI
-- ===========================================================================
CREATE OR REPLACE FUNCTION deriva_capo()
RETURNS TRIGGER AS $$  
BEGIN
    -- Verifica che il dipendente non sia già manager in un'altra filiale
    IF EXISTS (
        SELECT 1
        FROM Filiale
        WHERE manager = NEW.id AND nome != NEW.filiale
    ) THEN
        RAISE EXCEPTION 'Non è possibile cambiare la filiale del dipendente % o inserirlo
        perché è manager di una altra filiale.', NEW.id;
    END IF;

    NEW.capo := (SELECT manager FROM Filiale WHERE nome = NEW.filiale);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_aggiornamento_dipendente
BEFORE INSERT OR UPDATE OF filiale ON Dipendente
FOR EACH ROW
EXECUTE FUNCTION deriva_capo();

-- ===========================================================================
-- FUNZIONE E TRIGGER PER CONTROLLARE IL MANAGER DI UNA FILIALE
-- ===========================================================================
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
-- Controlla la validità del nuovo manager chiamando valida_manager().
CREATE TRIGGER trigger_validazione_manager
BEFORE INSERT OR UPDATE OF manager ON Filiale
FOR EACH ROW
EXECUTE FUNCTION valida_manager();

-- ========================================================================================================================
-- RISULTATO:
-- - L'assegnazione del capo ai dipendenti avviene in automatico.
-- - La validazione del manager assicura coerenza tra manager e filiale.
-- - La cancellazione dei manager è impedita finché non si cambiano le relazioni esistenti.
-- - Le chiavi esterne con ON UPDATE CASCADE garantiscono l'aggiornamento dei riferimenti 
-- - senza bisogno di trigger aggiuntivi.