-- ===========================================================================
-- LOGICA PER LA GESTIONE DELLE OPERAZIONI IN `POSSIEDE`
-- ===========================================================================
-- Assunto di base:
-- `Possiede` ha una riga per ogni coppia (cliente, conto), rappresentante l'ultima
-- operazione effettuata. Ogni UPDATE su questa riga equivale a registrare una nuova 
-- operazione, sovrascrivendo la precedente.
-- 
-- Cosa succede al momento dell'UPDATE su `Possiede`:
-- - Il trigger AFTER UPDATE su `Possiede` interpreta l'aggiornamento come un "inserimento"
--   di una nuova operazione.
-- - In base al tipo di operazione (prelievo, bancomat, versamento), aggiorna il saldo 
--   del conto aggiungendo o sottraendo l'importo.
-- - Prima di confermare la modifica al saldo, viene eseguito un controllo di validità 
--   (verifica_saldo) per evitare che il conto scenda oltre i limiti consentiti.
-- - Se il saldo è valido, si aggiorna la colonna `attivi` nella tabella `Filiale` 
--   corrispondente (trigger AFTER UPDATE ON Conto), tenendo i dati coerenti.
SET search_path TO banca;

-- FUNZIONE: inserisci_operazione()
-- Questa funzione viene invocata dal trigger AFTER UPDATE su `Possiede`.
-- Ogni volta che `Possiede` viene aggiornato, calcoliamo l'effetto dell'operazione 
-- sul saldo del conto. Non ripristiniamo nulla di precedente, consideriamo solo la 
-- nuova operazione.
CREATE OR REPLACE FUNCTION inserisci_operazione()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo_operazione IN ('prelievo', 'bancomat') THEN
        UPDATE Conto
        SET saldo = saldo - NEW.importo_operazione
        WHERE iban = NEW.conto;
    ELSIF NEW.tipo_operazione = 'versamento' THEN
        UPDATE Conto
        SET saldo = saldo + NEW.importo_operazione
        WHERE iban = NEW.conto;
    ELSE 
        RAISE EXCEPTION 'Operazione apertura non ripetibile';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: trigger_inserisci_operazione
-- AFTER UPDATE su Possiede:
-- Ogni modifica di tipo_operazione o importo_operazione su una riga di Possiede 
-- viene interpretata come una nuova operazione, applicando le modifiche al saldo del conto.
CREATE TRIGGER trigger_inserisci_operazione
AFTER UPDATE ON Possiede
FOR EACH ROW
EXECUTE FUNCTION inserisci_operazione();

-- FUNZIONE: verifica_saldo()
-- Prima di aggiornare il saldo di un conto, controlla se il nuovo saldo è valido:
-- - Se è un ContoCorrente, può andare in negativo fino allo scoperto.
-- - Se è un ContoRisparmio, non può mai andare in negativo.
-- Se la condizione non è rispettata, genera un'eccezione bloccando l'operazione.
CREATE OR REPLACE FUNCTION verifica_saldo()
RETURNS TRIGGER AS $$
DECLARE
    scoperto NUMERIC := 0;
    is_conto_corrente BOOLEAN := FALSE;
BEGIN
    -- Verifica se il conto è un ContoCorrente
    SELECT EXISTS (SELECT 1 FROM ContoCorrente WHERE iban = NEW.iban)
    INTO is_conto_corrente;

    -- Se è ContoCorrente, recupera lo scoperto
    IF is_conto_corrente THEN
        SELECT scoperto INTO scoperto
        FROM ContoCorrente WHERE iban = NEW.iban;
    ELSE
        RAISE EXCEPTION 'Operazione non concessa, conto di risparmio';
    END IF;

    -- Controllo del nuovo saldo
    IF  NEW.saldo < -scoperto THEN
        RAISE EXCEPTION 'Errore: saldo insufficiente. Operazione annullata.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: trigger_verifica_saldo
-- BEFORE UPDATE OF saldo ON Conto:
-- Ogni volta che si tenta di aggiornare il saldo di un conto, si esegue il controllo
-- per verificare la validità del nuovo saldo.
CREATE TRIGGER trigger_verifica_saldo
BEFORE UPDATE OF saldo ON Conto
FOR EACH ROW
EXECUTE FUNCTION verifica_saldo();

-- FUNZIONE: aggiorna_attivi_filiale()
-- Dopo che il saldo del conto è stato correttamente aggiornato, questa funzione aggiorna
-- il totale degli attivi nella filiale del conto. Aggiunge la differenza tra nuovo e vecchio
-- saldo di quel conto direttamente al campo `attivi` della filiale, senza bisogno di ricalcoli 
-- completi.
CREATE OR REPLACE FUNCTION aggiorna_attivi_filiale()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Filiale
    SET attivi = attivi + (NEW.saldo - OLD.saldo)
    WHERE nome = NEW.filiale;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: trigger_aggiorna_attivi_filiale
-- AFTER UPDATE OF saldo ON Conto:
-- Si attiva solo se l'UPDATE di saldo in Conto va a buon fine (cioè dopo verifica_saldo),
-- e aggiorna gli attivi nella filiale associata.
CREATE TRIGGER trigger_aggiorna_attivi_filiale
AFTER UPDATE OF saldo ON Conto
FOR EACH ROW
EXECUTE FUNCTION aggiorna_attivi_filiale();

-- RISULTATO:
-- Con questa configurazione, ogni volta che si modifica la riga in `Possiede`
-- relativa a (cliente, conto), si considera questa azione come l'inserimento di 
-- una nuova operazione. Il saldo del conto viene aggiornato di conseguenza, 
-- controllato il rispetto dei vincoli, e aggiornati gli attivi della filiale.
-- Se in futuro si volesse uno storico completo di operazioni, servirà una tabella 
-- separata dedicata a memorizzare ogni operazione eseguita.