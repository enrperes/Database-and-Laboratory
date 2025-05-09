CREATE SCHEMA banca
    AUTHORIZATION enrperes;

COMMENT ON SCHEMA banca
    IS 'Il database per la gestione delle filiali di una banca, progetto di Basi di Dati.';

SET search_path TO banca;

-- Creazione delle tabelle del database
-- Tabella dipendente senza FOREIGN KEY
CREATE TABLE dipendente (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(30),
    cognome VARCHAR(30),
    data_assunzione DATE NOT NULL,
    telefono VARCHAR(15) CHECK (telefono ~ '^\+?[0-9]+$') UNIQUE,
    filiale VARCHAR(30) NOT NULL,
    capo INT
);

-- Tabella filiale
CREATE TABLE filiale (
    nome VARCHAR(30) PRIMARY KEY,
    città VARCHAR(30),
    indirizzo VARCHAR(100) UNIQUE,
    manager INT UNIQUE NOT NULL,
    attivi DECIMAL(16,2),
    FOREIGN KEY (manager) REFERENCES dipendente(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Aggiunta delle FOREIGN KEY dopo
ALTER TABLE dipendente
ADD CONSTRAINT fk_filiale FOREIGN KEY (filiale) REFERENCES filiale(nome) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE dipendente
ADD CONSTRAINT fk_capo FOREIGN KEY (capo) REFERENCES filiale(manager) ON UPDATE CASCADE ON DELETE RESTRICT;

-- Tabella cliente
CREATE TABLE cliente (
    id SERIAL PRIMARY KEY,
    cf CHAR(16) UNIQUE NOT NULL,
    nome VARCHAR(30),
    cognome VARCHAR(30),
    data_nascita DATE,
    residenza VARCHAR(100),
    telefono VARCHAR(15) CHECK (telefono ~ '^\+?[0-9]+$') UNIQUE,
    gestore INT,
    FOREIGN KEY (gestore) REFERENCES dipendente(id) ON UPDATE CASCADE ON DELETE SET NULL
);

-- Tabella conto
CREATE TABLE conto (
    filiale VARCHAR(30) NOT NULL,
    iban CHAR(27) PRIMARY KEY,
    saldo DECIMAL(16,2),
    FOREIGN KEY (filiale) REFERENCES filiale(nome) ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE TABLE contocorrente (
    iban CHAR(27) PRIMARY KEY,
    scoperto DECIMAL(16,2) CHECK (scoperto >= 0),
    FOREIGN KEY (iban) REFERENCES conto(iban) ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE contorisparmio (
    iban CHAR(27) PRIMARY KEY,
    tasso_interesse FLOAT CHECK (tasso_interesse > 0 AND tasso_interesse <= 4),
    FOREIGN KEY (iban) REFERENCES conto(iban) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Tabella possiede
CREATE TABLE possiede (
    cliente INT NOT NULL,
    conto CHAR(27) NOT NULL,
    tipo_operazione VARCHAR(16) NOT NULL CHECK (tipo_operazione in ('versamento', 'prelievo', 'bancomat', 'apertura')),
    importo_operazione DECIMAL(16,2) CHECK (importo_operazione >= 0),
    data_operazione DATE NOT NULL,
    PRIMARY KEY (cliente, conto),
    FOREIGN KEY (conto) REFERENCES conto(iban) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (cliente) REFERENCES cliente(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabella prestito
CREATE TABLE prestito (
    codice SERIAL PRIMARY KEY,
    conto CHAR(27) NOT NULL, 
    ammontare DECIMAL(16,2) CHECK (ammontare > 0),
    mensilità INT CHECK (mensilità > 0),
    data_apertura DATE NOT NULL,
    FOREIGN KEY (conto) REFERENCES conto(iban) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Tabella rata
CREATE TABLE rata (
    numero INT NOT NULL,
    prestito INT NOT NULL,
    ammontare DECIMAL(16,2) CHECK (ammontare > 0),
    data_scadenza DATE NOT NULL,
    data_pagamento DATE CHECK (data_pagamento IS NULL OR data_scadenza >= data_pagamento),
    PRIMARY KEY (numero, prestito),
    FOREIGN KEY (prestito) REFERENCES prestito(codice) ON UPDATE CASCADE ON DELETE CASCADE
);
