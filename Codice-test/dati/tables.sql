CREATE SCHEMA banca
    AUTHORIZATION enrperes;

COMMENT ON SCHEMA banca
    IS 'Il database per la gestione delle filiali di una banca, il progetto di Basi di Dati.';

SET search_path TO banca;

-- Creazione delle tabelle del database
-- Tabella Dipendente senza FOREIGN KEY
CREATE TABLE Dipendente (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(30),
    cognome VARCHAR(30),
    data_assunzione DATE NOT NULL,
    telefono VARCHAR(15) CHECK (telefono ~ '^\+?[0-9]+$') UNIQUE,
    filiale VARCHAR(30) NOT NULL,
    capo INT
);

-- Tabella Filiale
CREATE TABLE Filiale (
    nome VARCHAR(30) PRIMARY KEY,
    città VARCHAR(30),
    indirizzo VARCHAR(100) UNIQUE,
    manager INT UNIQUE NOT NULL,
    attivi DECIMAL(16,2),
    FOREIGN KEY (manager) REFERENCES Dipendente(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Aggiunta delle FOREIGN KEY dopo
ALTER TABLE Dipendente
ADD CONSTRAINT fk_filiale FOREIGN KEY (filiale) REFERENCES Filiale(nome) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE Dipendente
ADD CONSTRAINT fk_capo FOREIGN KEY (capo) REFERENCES Filiale(manager) ON UPDATE CASCADE ON DELETE RESTRICT;

-- Tabella Cliente
CREATE TABLE Cliente (
    id SERIAL PRIMARY KEY,
    cf CHAR(16) UNIQUE NOT NULL,
    nome VARCHAR(30),
    cognome VARCHAR(30),
    data_nascita DATE,
    residenza VARCHAR(100),
    telefono VARCHAR(15) CHECK (telefono ~ '^\+?[0-9]+$') UNIQUE,
    gestore INT,
    FOREIGN KEY (gestore) REFERENCES Dipendente(id) ON UPDATE CASCADE ON DELETE SET NULL
);

-- Tabella Conto
CREATE TABLE Conto (
    filiale VARCHAR(30) NOT NULL,
    iban CHAR(27) PRIMARY KEY,
    saldo DECIMAL(16,2),
    FOREIGN KEY (filiale) REFERENCES Filiale(nome) ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE TABLE ContoCorrente (
    iban CHAR(27) PRIMARY KEY,
    scoperto DECIMAL(16,2) CHECK (scoperto >= 0),
    FOREIGN KEY (iban) REFERENCES Conto(iban) ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE ContoRisparmio (
    iban CHAR(27) PRIMARY KEY,
    tasso_interesse FLOAT CHECK (tasso_interesse > 0 AND tasso_interesse <= 4),
    FOREIGN KEY (iban) REFERENCES Conto(iban) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Tabella Possiede
CREATE TABLE Possiede (
    cliente INT NOT NULL,
    conto CHAR(27) NOT NULL,
    tipo_operazione VARCHAR(16) NOT NULL CHECK (tipo_operazione in ('versamento', 'prelievo', 'bancomat', 'apertura')),
    importo_operazione DECIMAL(16,2) CHECK (importo_operazione >= 0),
    data_operazione DATE NOT NULL,
    PRIMARY KEY (cliente, conto),
    FOREIGN KEY (conto) REFERENCES Conto(iban) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (cliente) REFERENCES Cliente(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabella Prestito
CREATE TABLE Prestito (
    codice SERIAL PRIMARY KEY,
    conto_associato CHAR(27) NOT NULL, 
    ammontare DECIMAL(16,2) CHECK (ammontare > 0),
    mensilità INT CHECK (mensilità > 0),
    data_apertura DATE NOT NULL,
    FOREIGN KEY (conto_associato) REFERENCES Conto(iban) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Tabella Rata
CREATE TABLE Rata (
    numero INT NOT NULL,
    prestito INT NOT NULL,
    ammontare DECIMAL(16,2) CHECK (ammontare > 0),
    data_scadenza DATE NOT NULL,
    data_pagamento DATE CHECK (data_pagamento IS NULL OR data_scadenza >= data_pagamento),
    PRIMARY KEY (numero, prestito),
    FOREIGN KEY (prestito) REFERENCES Prestito(codice) ON UPDATE CASCADE ON DELETE CASCADE
);
