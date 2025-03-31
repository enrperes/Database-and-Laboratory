setwd("~/Documents/UniUD/Basi di dati/LAB/Relazione/Codice/dati")

# Carica pacchetti
# install.packages("RPostgres")
library(DBI)
library(RPostgres)

# Connessione al database di default
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "postgres",
  host = "localhost",
  port = 5432,
  user = "enrperes",
  password = "9999"
)

# Crea il database
dbExecute(con, "CREATE DATABASE db_banca;")

# Chiudi la connessione
dbDisconnect(con)

# Ora connettiti a db_banca
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "db_banca",
  host = "localhost",
  port = 5432,
  user = "enrperes",
  password = "9999"
)

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

# Leggi tutto il file SQL
query <- paste(readLines("tables.sql"), collapse = "\n")

# Carico lo schema tramite queries
queries <- unlist(strsplit(query, ";"))
queries <- trimws(queries)
queries <- queries[queries != ""]
  
for (q in queries) {
  if (nchar(q) > 0) {
    tryCatch({
      dbExecute(con, q)
    }, error = function(e2) {
      message("Errore in query:\n", q, "\nMessaggio: ", e2$message)
    })
  }
}


  # Define the split_sql function
  split_sql <- function(sql) {
    queries <- c()
    current <- ""
    in_dollar <- FALSE
    i <- 1
    sql_length <- nchar(sql)
    
    while (i <= sql_length) {
      # Toggle the in_dollar flag when encountering "$$"
      if (i <= sql_length - 1 && substr(sql, i, i + 1) == "$$") {
        in_dollar <- !in_dollar
        current <- paste0(current, "$$")
        i <- i + 2
        next
      }
      char <- substr(sql, i, i)
      # Split on semicolon only if not inside a $$ block
      if (char == ";" && !in_dollar) {
        queries <- c(queries, current)
        current <- ""
      } else {
        current <- paste0(current, char)
      }
      i <- i + 1
    }
    
    # Append any remaining SQL not terminated by a semicolon
    if (nchar(trimws(current)) > 0) {
      queries <- c(queries, current)
    }
    return(queries)
  }

# Read the entire SQL file into one string
sql <- paste(readLines("triggers_dipendente_filiale.sql"), collapse = "\n")

# Use the split_sql function to split the file into individual queries
queries <- split_sql(sql)
queries <- trimws(queries)
queries <- queries[queries != ""]

# Execute each query with error handling
for (q in queries) {
  tryCatch({
    dbExecute(con, q)
  }, error = function(e2) {
    message("Error in query:\n", q, "\nMessage: ", e2$message)
  })
}




# Leggi tutto il file SQL
query <- paste(readLines("triggers_dipendente_filiale.sql"), collapse = "\n")


# Carico lo schema tramite queries
queries <- unlist(strsplit(query, ";"))
queries <- trimws(queries)
queries <- queries[queries != ""]


for (q in queries) {
  if (nchar(q) > 0) {
    tryCatch({
      dbExecute(con, q)
    }, error = function(e2) {
      message("Errore in query:\n", q, "\nMessaggio: ", e2$message)
    })
  }
}

# logica di popolamento
dbExecute(con, "alter table Dipendente disable trigger all;")
dbExecute(con, "alter table Filiale disable trigger all;")

# inserisco le filiali
filiali <- data.frame(
  nome = c("1", "2", "3", "4", "5", "6"),
  città = v_città,
  indirizzo = v_indirizzo,
  manager = c(1:6), 
  attivi = 0
)

dbWriteTable(con, name = "filiale",
             value = filiali, append = TRUE, row.names = FALSE)

# inserisco i dipendenti
nomi_dipendenti <- sample(v_nomi, 200, replace = T)
cognomi_dipendenti <- sample(v_cognomi, 200)
tel_dipendenti <- v_telefono[0:200]
fil_dipendenti <- c("1", "2", "3", "4", "5", "6", sample(as.character(1:6), 194, replace = TRUE))

dipendenti <- data.frame(
  nome = nomi_dipendenti,
  cognome = cognomi_dipendenti,
  data_assunzione = v_data_assunzione,
  telefono = tel_dipendenti,
  filiale = fil_dipendenti,
  capo = -1
)

dbWriteTable(con, name = "dipendente",
             value = dipendenti, append = TRUE, row.names = FALSE)

# logica di popolamento
dbExecute(con, "alter table Dipendente enable trigger all;")
dbExecute(con, "alter table Filiale enable trigger all;")





































# imposta lo schema "banca"
dbGetQuery(con, "SET search_path TO banca;")




# genera un dataframe con dati casuali per 200 dipendenti
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

