-- ===========================================================================
-- LOGICA PER LA GESTIONE DELLE OPERAZIONI IN `possiede`
-- ===========================================================================

SET search_path TO banca;

-------------------------------------------------------------------------------
-- 1) Trigger per impedire che lo stesso IBAN sia in contocorrente e contorisparmio
-------------------------------------------------------------------------------

-- A) Funzione e trigger su contocorrente
CREATE OR REPLACE FUNCTION check_iban_uniqueness_contocorrente()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM contorisparmio WHERE iban = NEW.iban) THEN
        RAISE EXCEPTION 'Impossibile inserire IBAN % in contocorrente, è già presente in contorisparmio!', NEW.iban;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_contocorrente_iban
BEFORE INSERT ON contocorrente
FOR EACH ROW
EXECUTE FUNCTION check_iban_uniqueness_contocorrente();


-- B) Funzione e trigger su contorisparmio
CREATE OR REPLACE FUNCTION check_iban_uniqueness_contorisparmio()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM contocorrente WHERE iban = NEW.iban) THEN
        RAISE EXCEPTION 'Impossibile inserire IBAN % in contorisparmio, è già presente in contocorrente!', NEW.iban;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_contorisparmio_iban
BEFORE INSERT ON contorisparmio
FOR EACH ROW
EXECUTE FUNCTION check_iban_uniqueness_contorisparmio();



-------------------------------------------------------------------------------
-- 2) Logica generale su `possiede`: inserisci_operazione, verifica_saldo, ecc.
-------------------------------------------------------------------------------

-- FUNZIONE: inserisci_operazione()
-- Invocata dal trigger AFTER UPDATE su `possiede`.
-- Ogni volta che `possiede` viene aggiornato, calcoliamo l'effetto dell'operazione 
-- sul saldo del conto (incremento / decremento). 
CREATE OR REPLACE FUNCTION inserisci_operazione()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo_operazione IN ('prelievo', 'bancomat') THEN
        UPDATE conto
        SET saldo = saldo - NEW.importo_operazione
        WHERE iban = NEW.conto;
        
    ELSIF NEW.tipo_operazione = 'versamento' THEN
        UPDATE conto
        SET saldo = saldo + NEW.importo_operazione
        WHERE iban = NEW.conto;
        
    ELSE 
        RAISE EXCEPTION 'Operazione apertura non ripetibile';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: trigger_inserisci_operazione
-- AFTER UPDATE su possiede:
-- Ogni modifica di tipo_operazione o importo_operazione su una riga di possiede 
-- viene interpretata come una nuova operazione, applicando le modifiche al saldo del conto.
CREATE TRIGGER trigger_inserisci_operazione
AFTER UPDATE ON possiede
FOR EACH ROW
EXECUTE FUNCTION inserisci_operazione();



-- FUNZIONE: verifica_saldo()
-- Prima di aggiornare il saldo di un conto, controlla se il nuovo saldo è valido:
-- - Se è un conto_corrente, può andare in negativo fino allo scoperto.
-- - Se è un conto_risparmio, non può mai andare in negativo (nel tuo esempio: 
--   lanci eccezione se non è conto_corrente)
CREATE OR REPLACE FUNCTION verifica_saldo()
RETURNS TRIGGER AS $$
DECLARE
    scoperto NUMERIC := 0;
    is_conto_corrente BOOLEAN := FALSE;
BEGIN
    -- Verifica se il conto è un conto_corrente
    SELECT EXISTS (SELECT 1 FROM contocorrente WHERE iban = NEW.iban)
    INTO is_conto_corrente;

    -- Se è conto_corrente, recupera lo scoperto
    IF is_conto_corrente THEN
        SELECT scoperto INTO scoperto
        FROM contocorrente WHERE iban = NEW.iban;
    ELSE
        RAISE EXCEPTION 'Operazione non concessa, conto di risparmio';
    END IF;

    -- Controllo del nuovo saldo
    IF NEW.saldo < -scoperto THEN
        RAISE EXCEPTION 'Errore: saldo insufficiente. Operazione annullata.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: trigger_verifica_saldo
-- BEFORE UPDATE OF saldo ON conto:
-- Ogni volta che si tenta di aggiornare il saldo di un conto, si esegue il controllo
-- per verificare la validità del nuovo saldo.
CREATE TRIGGER trigger_verifica_saldo
BEFORE UPDATE OF saldo ON conto
FOR EACH ROW
EXECUTE FUNCTION verifica_saldo();



-- FUNZIONE: aggiorna_attivi_filiale()
-- Dopo che il saldo del conto è stato correttamente aggiornato, questa funzione aggiorna
-- il totale degli attivi nella filiale del conto. Aggiunge la differenza tra nuovo e vecchio
-- saldo (NEW.saldo - OLD.saldo) direttamente al campo `attivi` della filiale.
CREATE OR REPLACE FUNCTION aggiorna_attivi_filiale()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE filiale
    SET attivi = attivi + (NEW.saldo - OLD.saldo)
    WHERE nome = NEW.filiale;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: trigger_aggiorna_attivi_filiale
-- AFTER INSERT OR UPDATE OF saldo ON conto:
-- Si attiva solo se l'UPDATE di saldo va a buon fine, e aggiorna gli attivi 
-- della filiale associata al conto.
CREATE TRIGGER trigger_aggiorna_attivi_filiale
AFTER INSERT OR UPDATE OF saldo ON conto
FOR EACH ROW
EXECUTE FUNCTION aggiorna_attivi_filiale();
