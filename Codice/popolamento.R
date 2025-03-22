# driver PostgreSQL e creazione connessione
library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="db_banca")

# caricamento file .txt con i dati 
v_nomi <- readLines("nomi.txt")
v_cognomi <- readLines("cognomi.txt")
v_ammontare_prestito <- readLines("ammontare_prestito.txt")
v_cf <- readLines("cf.txt")
v_data_assunzione <- readLines("data_assunzione.txt")
v_data_prestito <- readLines("data_prestito.txt")
v_data_nascita <- readLines("data_nascita.txt")
v_iban <- readLines("iban.txt")
v_interesse <- readLines("interesse.txt")
v_mensilità <- readLines("mensilità.txt")
v_residenza <- readLines("residenza.txt")
v_indirizzo <- readLines("indirizzo.txt")
v_saldo <- readLines("saldo.txt")
v_scoperto <- readLines("scoperto.txt")
v_telefono <- readLines("telefono.txt")
v_città <- readLines("città.txt")

# imposta lo schema "banca"
dbGetQuery(con, "SET search_path TO banca;")


# crea la tabella Dipendente
dbGetQuery(con, "CREATE TABLE Dipendente (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(30),
    cognome VARCHAR(30),
    data_assunzione DATE NOT NULL,
    telefono VARCHAR(15) CHECK (telefono ~ '^\+?[0-9]+$') UNIQUE,
    filiale VARCHAR(30) NOT NULL,
    capo INT
);")




# genera un dataframe con dati casuali per 100 dipendenti
set.seed(123)  # per riproducibilità
num_dipendenti <- 200


dipendente_df <- data.frame(
  nome = sample(v_nomi, num_dipendenti, replace = TRUE),
  cognome = sample(v_cognomi, num_dipendenti, replace = TRUE),
  data_assunzione = v_data_assunzione,
  telefono = v_telefono,
  filiale = v_filiale,
  capo = sample(v_nomi, num_dipendenti, replace = TRUE),
)

# inserisce i dati nella tabella Dipendente
dbWriteTable(con, name = "Dipendente", value = dipendente_df, append = TRUE, row.names = FALSE)

