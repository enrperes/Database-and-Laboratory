# SETUP INIZIALE ----

# setwd("") - impostare la directory di lavoro contenente il file R, la cartella dati e codice. 
library(DBI)
library(RPostgres)
library(here)

set.seed(42)

# CREAZIONE DATABASE ----

con <- dbConnect(
  RPostgres::Postgres(),
  dbname   = "postgres",
  host     = "localhost",
  port     =  5432,
  user     = "enrperes",
  password = "9999"
)
dbExecute(con, "CREATE DATABASE db_banca;")
dbDisconnect(con)


## CONNESSIONE A db_banca ----

con <- dbConnect(
  RPostgres::Postgres(),
  dbname   = "db_banca",
  host     = "localhost",
  port     =  5432,
  user     = "enrperes",
  password = "9999"
)


## CARICAMENTO FILE DI TESTO ----

v_nomi                <- readLines("./dati/nomi.txt")
v_cognomi             <- readLines("./dati/cognomi.txt")
v_ammontare_prestito  <- readLines("./dati/ammontare_prestito.txt")
v_cf                  <- readLines("./dati/cf.txt")
v_data_assunzione     <- readLines("./dati/data_assunzione.txt")
v_data_prestito       <- readLines("./dati/data_prestito.txt")
v_data_nascita        <- readLines("./dati/data_nascita.txt")
v_data_apertura       <- readLines("./dati/data_apertura.txt")
v_iban                <- readLines("./dati/iban.txt")
v_interesse           <- readLines("./dati/interesse.txt")
v_mensilità           <- readLines("./dati/mensilità.txt")
v_residenza           <- readLines("./dati/residenza.txt")
v_indirizzo           <- readLines("./dati/indirizzo.txt")
v_saldo               <- readLines("./dati/saldo.txt")
v_scoperto            <- readLines("./dati/scoperto.txt")
v_telefono            <- readLines("./dati/telefono.txt")
v_città               <- readLines("./dati/città.txt")


## CONFIGURAZIONE DEI VOLUMI DEI DATI ----

num_clienti    <- 30000    # Numero totale di clienti
num_filiali    <- 6        # Numero totale di filiali
num_dipendenti <- 200      # Numero totale di dipendenti
num_conti      <- 24000    # Numero totale di conti bancari
num_correnti   <- 20000    # Numero di conti correnti
num_risparmi   <- 4000     # Numero di conti risparmio
num_prestiti   <- 14000    # Numero totale di prestiti


## CREAZIONE SCHEMA (TABLES) ----

query   <- paste(readLines("./codice/sql/tables.sql"), collapse = "\n")
queries <- unlist(strsplit(query, ";"))
queries <- trimws(queries)
queries <- queries[queries != ""]

for (q in queries) {
  tryCatch({
    dbExecute(con, q)
  }, error = function(e2) {
    message("Errore in query:\n", q, "\nMessaggio: ", e2$message)
  })
}


# CARICAMENTO TRIGGER E FUNZIONI ----

base_path <- "./Codice/sql"


## ==== DIPENDENTE_FILIALE ====
df_files <- c(
  "/dipendente_filiale/deriva_capo.sql",
  "/dipendente_filiale/deriva_capo_trigger.sql",
  "/dipendente_filiale/valida_manager.sql",
  "/dipendente_filiale/valida_manager_trigger.sql"
)


## ==== FILIALE_CONTO_PRESTITO_RATA ====
fcpr_files <- c(
  "/filiale_conto_prestito_rata/crea_rate_prestito.sql",
  "/filiale_conto_prestito_rata/crea_rate_prestito_trigger.sql",
  "/filiale_conto_prestito_rata/paga_rata.sql",
  "/filiale_conto_prestito_rata/paga_rata_trigger.sql",
  "/filiale_conto_prestito_rata/sottrai_prestito.sql",
  "/filiale_conto_prestito_rata/sottrai_prestito_trigger.sql"
)


## ==== POSSIEDE_CONTO_FILIALE ====
pcf_files <- c(
  "/possiede_conto_filiale/aggiorna_attivi_filiale.sql",
  "/possiede_conto_filiale/aggiorna_attivi_filiale_trigger.sql",
  "/possiede_conto_filiale/inserisci_operazione.sql",
  "/possiede_conto_filiale/inserisci_operazione_trigger.sql",
  "/possiede_conto_filiale/verifica_saldo.sql",
  "/possiede_conto_filiale/verifica_saldo_trigger.sql",
  "/possiede_conto_filiale/check_iban_un.sql",
  "/possiede_conto_filiale/check_iban_un_trigger.sql",
  "/possiede_conto_filiale/check_iban2_un.sql",
  "/possiede_conto_filiale/check_iban2_un_trigger.sql"
)

## ==== CLIENTE_DIPENDENTE ====
cd_files <- c(
  "cliente_dipendente/cliente_dipendente.sql",
  "cliente_dipendente/cliente_dipendente_trigger.sql"
)


# Esecuzione dei file ----
for (file in c(df_files, fcpr_files, pcf_files, cd_files)) {
  query <- paste(readLines(file.path(base_path, file)), collapse = "\n")
  tryCatch({
    dbExecute(con, query)
    message("Eseguito: ", file)
  }, error = function(e) {
    message("Errore in ", file, " → ", e$message)
  })
}


# POPOLAMENTO FILIALI E DIPENDENTI ----

# Disabilita i trigger per inserimento 
dbExecute(con, "ALTER TABLE dipendente DISABLE TRIGGER ALL;")
dbExecute(con, "ALTER TABLE filiale DISABLE TRIGGER ALL;")


## ==== Inserimento filiali ====
filiali <- data.frame(
  nome      = c("1", "2", "3", "4", "5", "6"),
  città     = v_città,
  indirizzo = v_indirizzo,
  manager   = c(1:6),
  attivi    = 0
)
dbWriteTable(con, name = "filiale", value = filiali, append = TRUE, row.names = FALSE)


## ==== Inserimento dipendenti ====
dipendenti <- data.frame(
  nome            = sample(v_nomi, num_dipendenti, replace = TRUE),
  cognome         = sample(v_cognomi, num_dipendenti),
  data_assunzione = v_data_assunzione,
  telefono        = v_telefono[1:num_dipendenti],
  filiale         = c("1", "2", "3", "4", "5", "6", sample(as.character(1:6), 
                                                           num_dipendenti - 6, replace = TRUE)),
  capo            = -1
)
dbWriteTable(con, name = "dipendente", value = dipendenti, append = TRUE, row.names = FALSE)


# RIABILITAZIONE TRIGGER E AGGIORNAMENTO FORZATO

dbExecute(con, "ALTER TABLE dipendente ENABLE TRIGGER ALL;")
dbExecute(con, "ALTER TABLE filiale ENABLE TRIGGER ALL;")
# Forza i trigger con update fittizi
dbExecute(con, "UPDATE dipendente SET filiale = filiale;")
dbExecute(con, "UPDATE filiale SET manager = manager;")


## POPOLAMENTO CLIENTI ----

clienti <- data.frame(
  cf           = v_cf,
  nome         = sample(v_nomi, num_clienti, replace = TRUE),
  cognome      = sample(v_cognomi, num_clienti, replace = TRUE),
  data_nascita = v_data_nascita,
  residenza    = v_residenza,
  telefono     = v_telefono[(num_dipendenti + 1):(num_dipendenti + num_clienti)]
)

# Assegna gestori in modo sequenziale
gestori_possibili <- c(1:100)
clienti$gestore <- NA  # inizializza

num_primi <- floor(0.67 * 24000)
for (i in 1:num_primi) {
  clienti$gestore[i] <- gestori_possibili[(i - 1) %% length(gestori_possibili) + 1]
}

num_ultimi <- floor(0.67 * 6000)
offset <- 24000
for (i in 1:num_ultimi) {
  clienti$gestore[offset + i] <- gestori_possibili[(i - 1) %% length(gestori_possibili) + 1]
}

# Scrive nel DB
dbWriteTable(con, name = "cliente", value = clienti, append = TRUE, row.names = FALSE)



## POPOLAMENTO CONTO ----

conti <- data.frame(
  iban    = v_iban,
  saldo   = v_saldo,
  filiale = sample(1:num_filiali, num_conti, replace = TRUE)
)
dbWriteTable(con, name = "conto", value = conti, append=TRUE, row.names=FALSE)


## POPOLAMENTO CONTO CORRENTE ----

correnti <- data.frame(
  iban     = v_iban[1:num_correnti],
  scoperto = v_scoperto 
)
dbWriteTable(con, "contocorrente", correnti, append=TRUE, row.names=FALSE)


## POPOLAMENTO CONTO DI RISPARMIO ----

risparmi <- data.frame(
  iban            = v_iban[(num_correnti+1):num_conti],
  tasso_interesse = v_interesse
)

# Inserimento nel database ----
dbWriteTable(con, "contorisparmio", risparmi, append=TRUE, row.names=FALSE)


# POPOLAMENTO POSSIEDE ----

# assegnazione 1 a 1 per i primi 24.000 clienti
possiede <- data.frame(
  cliente         = 1:num_conti,
  conto           = v_iban,
  tipo_operazione = rep("apertura", num_conti),
  data_operazione = v_data_apertura
)
additional <- data.frame(
  cliente         = (num_conti + 1):num_clienti,
  conto           = v_iban[1:6000],
  tipo_operazione = rep("apertura", 6000),
  data_operazione = v_data_apertura[1:6000]
)
# Unione dei due data frame
possiede_df <- rbind(possiede, additional)
print(possiede_df$conto[24001])
print(possiede_df$conto[1])
dbWriteTable(con, "possiede", possiede_df, append = TRUE, row.names = FALSE)



# POPOLAMENTO PRESTITI (trigger genereranno le rate) ----

prestiti <- data.frame(
  conto           = sample(v_iban, num_prestiti),
  ammontare       = v_ammontare_prestito,
  mensilità       = v_mensilità,
  data_apertura   = v_data_prestito
)
dbWriteTable(con, name = "prestito", value = prestiti, append = TRUE, row.names = FALSE)



# PAGAMENTO MASSIVO RATE E AGGIORNAMENTO ATTIVI ----


# 1. Disabilita trigger per evitare rallentamenti
dbExecute(con, "ALTER TABLE rata DISABLE TRIGGER trigger_paga_rata;")

# 2. Paga tutte le rate scadute (fino a oggi compreso)
dbExecute(con, "
  UPDATE rata
  SET data_pagamento = data_scadenza
  WHERE data_scadenza <= CURRENT_DATE
    AND data_pagamento IS NULL;
")

# 3. Aggiorna gli attivi delle filiali manualmente
dbExecute(con, "
  UPDATE filiale f
  SET attivi = f.attivi + t.totale
  FROM (
    SELECT c.filiale, SUM(r.ammontare) AS totale
    FROM rata r
    JOIN prestito p ON r.prestito = p.codice
    JOIN conto c ON p.conto = c.iban
    WHERE r.data_pagamento <= CURRENT_DATE
    GROUP BY c.filiale
  ) t
  WHERE f.nome = t.filiale;
")

# 4. Riabilita il trigger per l'utilizzo dinamico futuro
dbExecute(con, "ALTER TABLE rata ENABLE TRIGGER trigger_paga_rata;")









# TEST ----


## TEST DIPENDENTE E FILIALE ----


### TEST 1: Aggiornamento filiale di un dipendente (id = 1) ----

cat("\n=== Test 1: Aggiornamento filiale di dipendente (id = 1) ===\n")
# Questo update dovrebbe fallire perché il dipendente è manager in un'altra filiale.
tryCatch({
  dbExecute(con, "UPDATE dipendente SET filiale = '3' WHERE id = 1;")
}, error = function(e) {
  cat("Errore atteso: ", e$message, "\n")
})
print(dbGetQuery(con, "SELECT id, filiale, capo FROM dipendente WHERE id = 1;"))


### TEST 2: Aggiornamento manager della filiale '3' ----

cat("\n=== Test 2: Aggiornamento manager della filiale '3' ===\n")
# Questo update dovrebbe fallire perché il dipendente 2 non lavora in filiale 3.
tryCatch({
  dbExecute(con, "UPDATE filiale SET manager = 2 WHERE nome = '3';")
}, error = function(e) {
  cat("Errore atteso: ", e$message, "\n")
})
print(dbGetQuery(con, "SELECT nome, manager FROM filiale WHERE nome = '3';"))


### TEST 3: Inserimento di un nuovo dipendente ----

cat("\n=== Test 3: Inserimento nuovo dipendente ===\n")
# Verifica: all'inserimento, il trigger assegna correttamente il campo "capo" in base alla filiale.
nuovo_dipendente <- data.frame(
  nome = "Alessandro",
  cognome = "Neri",
  data_assunzione = Sys.Date(),
  telefono = "123456789",
  filiale = "4"
)
dbWriteTable(con, "dipendente", nuovo_dipendente, append = TRUE, row.names = FALSE)
print(dbGetQuery(con, "SELECT * FROM dipendente WHERE nome = 'Alessandro' AND cognome = 'Neri';"))



### TEST 4: Aggiornamento manager filiale con dipendente valido ----

cat("\n=== Test 4: Aggiornamento manager filiale con dipendente valido ===\n")
# Inserimento di un nuovo dipendente in filiale "5" (inizialmente non manager),
# recupera il suo id e assegnalo come manager della filiale "5"
nuovo_dip <- data.frame(
  nome = "Giulia",
  cognome = "Rossi",
  data_assunzione = Sys.Date(),
  telefono = "987654321",
  filiale = "5",
  capo = -1
)
dbWriteTable(con, "dipendente", nuovo_dip, append = TRUE, row.names = FALSE)
id_nuovo <- dbGetQuery(con, "SELECT id FROM dipendente WHERE nome = 'Giulia' 
                       AND cognome = 'Rossi';")$id[1]
cat("Nuovo dipendente id: ", id_nuovo, "\n")
dbExecute(con, paste0("UPDATE filiale SET manager = ", id_nuovo, " WHERE nome = '5';"))
print(dbGetQuery(con, "SELECT nome, manager FROM filiale WHERE nome = '5';"))


### TEST 5: Cancellazione di un dipendente non manager ----

cat("\n=== Test 5: Cancellazione di un dipendente non manager (id = 7) ===\n")
# Controlla il dipendente con id = 7 e procedi con la cancellazione, verificando che l'operazione avvenga correttamente.
print(dbGetQuery(con, "SELECT id, nome, cognome, filiale, capo FROM dipendente WHERE id = 7;"))
dbExecute(con, "DELETE FROM dipendente WHERE id = 7;")
print(dbGetQuery(con, "SELECT id FROM dipendente WHERE id = 7;"))





## TEST PRESTITO, RATA ----


### TEST 1: Inserimento nuovo prestito e generazione rate ----

cat("\n=== Test 1: Inserimento nuovo prestito e generazione rate ===\n")

# Inseriamo un nuovo prestito per un conto esistente (ad es. il decimo IBAN)
nuovo_prestito <- data.frame(
  conto         = v_iban[10],
  ammontare     = "100000",       # importo del prestito
  mensilità     = "36",           # numero di rate
  data_apertura = as.character(Sys.Date())
)
dbWriteTable(con, "prestito", nuovo_prestito, append = TRUE, row.names = FALSE)

# Recupera il prestito appena inserito (supponiamo che 'codice' sia la chiave primaria)
prestito_inserito <- dbGetQuery(con, "SELECT * FROM prestito ORDER BY codice DESC LIMIT 1;")
print(prestito_inserito)

# Estrae il codice del prestito per controllare le rate generate
codice_prestito <- prestito_inserito$codice
rate_generata <- dbGetQuery(con, paste0("SELECT * FROM rata WHERE prestito = ", codice_prestito, ";"))
print(rate_generata)
cat("Numero di rate generate: ", nrow(rate_generata), "\n\n")


### TEST 2: Pagamento di una rata ----

cat("\n=== Test 2: Pagamento di una rata ===\n")

filiale_attivi_old <- dbGetQuery(con, paste0("
  SELECT f.nome, f.attivi
  FROM filiale f
  JOIN conto c ON c.filiale = f.nome
  WHERE c.iban = (SELECT conto FROM prestito WHERE codice = ", codice_prestito, ");
"))

# Seleziona una rata non pagata per il prestito appena inserito
rata_non_pagata <- dbGetQuery(con, paste0("SELECT * FROM rata WHERE prestito = ", 
                                          codice_prestito, " AND data_pagamento IS NULL LIMIT 1;"))
print(rata_non_pagata)

# Simula il pagamento aggiornando la data_pagamento al valore di data_scadenza
dbExecute(con, paste0("UPDATE rata SET data_pagamento = data_scadenza WHERE numero = ", 
                      rata_non_pagata$numero[1], " AND prestito = ", codice_prestito, ";"))

# Verifica che la rata sia stata aggiornata
rata_pagata <- dbGetQuery(con, paste0("SELECT * FROM rata WHERE numero = ", 
                                      rata_non_pagata$numero[1], " AND prestito = ", codice_prestito, ";"))
print(rata_pagata)

# (Facoltativo) Controlla l'aggiornamento degli attivi della filiale associata
filiale_attivi_new <- dbGetQuery(con, paste0("
  SELECT f.nome, f.attivi
  FROM filiale f
  JOIN conto c ON c.filiale = f.nome
  WHERE c.iban = (SELECT conto FROM prestito WHERE codice = ", codice_prestito, ");
"))
print(filiale_attivi_new[2] - filiale_attivi_old[2])

cat("\n=== Fine Test Prestito - Rata ===\n")



## TEST CONTO, POSSIEDE, FILIALE ----



### TEST 1: Inserimento operazione (versamento e prelievo) ----

cat("\n=== Test X1: Inserimento operazione (versamento e prelievo) su possiede ===\n")

riga_possiede <- dbGetQuery(con, paste0( "
  SELECT * 
  FROM possiede
  WHERE conto = '", v_iban[1], "';
"))
print(riga_possiede)

if(nrow(riga_possiede) == 0) {
  cat("Nessun record in possiede da aggiornare.\n")
} else {
  id_cliente <- riga_possiede$cliente[1]
  iban_conto <- riga_possiede$conto[1]
  
  cat("\n--- Operazione: versamento 100 ---\n")
  tryCatch({
    dbExecute(con, paste0("
      UPDATE possiede
      SET tipo_operazione = 'versamento', importo_operazione = 100
      WHERE cliente = ", id_cliente, "
        AND conto = '", iban_conto, "';
    "))
    saldo_dopo <- dbGetQuery(con, paste0("SELECT saldo FROM conto WHERE iban = '", iban_conto, "';"))
    cat("Saldo dopo versamento: ", saldo_dopo$saldo[1], "\n")
  }, error = function(e) {
    cat("Errore nel versamento: ", e$message, "\n")
  })
  
  cat("\n--- Operazione: prelievo 200 ---\n")
  tryCatch({
    dbExecute(con, paste0("
      UPDATE possiede
      SET tipo_operazione = 'prelievo', importo_operazione = 200
      WHERE cliente = ", id_cliente, "
        AND conto = '", iban_conto, "';
    "))
    saldo_dopo2 <- dbGetQuery(con, paste0("SELECT saldo FROM conto WHERE iban = '", iban_conto, "';"))
    cat("Saldo dopo prelievo: ", saldo_dopo2$saldo[1], "\n")
  }, error = function(e) {
    cat("Errore nel prelievo: ", e$message, "\n")
  })
}



### TEST 2: Verifica_saldo – forzo saldo negativo ----

cat("\n=== Test X2: Verifica_saldo – forzo saldo negativo ===\n")

riga_possiede2 <- dbGetQuery(con, paste0("
  SELECT * 
  FROM possiede
  WHERE conto = '", v_iban[1], "';
"))

if(nrow(riga_possiede2) == 0) {
  cat("Nessun record in possiede da aggiornare.\n")
} else {
  id_cliente2 <- riga_possiede2$cliente[1]
  iban_conto2 <- riga_possiede2$conto[1]
  
  tryCatch({
    dbExecute(con, paste0("
      UPDATE possiede
      SET tipo_operazione = 'prelievo', importo_operazione = 999999
      WHERE cliente = ", id_cliente2, "
        AND conto = '", iban_conto2, "';
    "))
    cat("Prelievo eccessivo riuscito – il trigger non blocca i saldi negativi!\n")
  }, error = function(e) {
    cat("Errore atteso (saldo insufficiente): ", e$message, "\n")
  })
}



### TEST 3: Aggiorna attivi filiale ----

cat("\n=== Test X3: Aggiorna attivi filiale ===\n")

conto_test <- dbGetQuery(con, paste0("SELECT iban, filiale, saldo FROM conto WHERE iban = '", v_iban[2], "';"))
print(conto_test)

if(nrow(conto_test) > 0) {
  iban_test    <- conto_test$iban[1]
  filiale_test <- conto_test$filiale[1]
  
  filiale_old <- dbGetQuery(con, paste0("
    SELECT attivi 
    FROM filiale 
    WHERE nome = '", filiale_test, "';
  "))
  cat("Attivi filiale PRIMA: ", filiale_old$attivi[1], "\n")
  
  tryCatch({
    dbExecute(con, paste0("
      UPDATE possiede
      SET tipo_operazione = 'versamento', importo_operazione = 500
      WHERE conto = '", iban_test, "'
        AND tipo_operazione = 'apertura';
    "))
  }, error = function(e) {
    cat("Errore sul versamento test: ", e$message, "\n")
  })
  
  nuovo_saldo <- dbGetQuery(con, paste0("
    SELECT saldo 
    FROM conto 
    WHERE iban = '", iban_test, "';
  "))
  filiale_new <- dbGetQuery(con, paste0("
    SELECT attivi 
    FROM filiale 
    WHERE nome = '", filiale_test, "';
  "))
  
  cat("Saldo conto DOPO:    ", nuovo_saldo$saldo[1], "\n")
  cat("Attivi filiale DOPO: ", filiale_new$attivi[1], "\n")
  cat("Variazione attivi:   ", filiale_new$attivi[1] - filiale_old$attivi[1], "\n")
} else {
  cat("Nessun conto trovato per il test di aggiorna attivi filiale.\n")
}



### TEST 4: IBAN duplicato tra contocorrente e contorisparmio ----

cat("\n=== Test X4: IBAN duplicato tra contocorrente e contorisparmio ===\n")

tryCatch({
  dbBegin(con)
  
  # 1) Inserisco l'IBAN in 'conto' (necessario per rispettare la foreign key)
  dbExecute(con, "
    INSERT INTO conto (iban, saldo, filiale)
    VALUES ('IT_TEST_DUPL_IBAN', 0, '1');
  ")
  
  # 2) Inserisco in contocorrente
  dbExecute(con, "
    INSERT INTO contocorrente (iban, scoperto)
    VALUES ('IT_TEST_DUPL_IBAN', 9999);
  ")
  
  # 3) Provo a inserirlo anche in contorisparmio
  dbExecute(con, "
    INSERT INTO contorisparmio (iban, tasso_interesse)
    VALUES ('IT_TEST_DUPL_IBAN', 2.0);
  ")
  
  dbCommit(con)
  cat("Inserimento duplicato riuscito: i trigger non hanno bloccato l'IBAN!\n")
}, error = function(e) {
  dbRollback(con)
  cat("Errore atteso (IBAN duplicato): ", e$message, "\n")
})



### TEST 5: INSERIMENTO DI UN CONTO ----

cat("\n=== Test Inserimento nuovo conto risparmio con transazione ===\n")

iban_nuovo   <- "IT_TEST_CONTO_RISP_01"
filiale_nuovo <- "3"    
id_cliente   <- 12345   
ok           <- FALSE

dbBegin(con)
tryCatch({
  # 1) Inserisci il nuovo conto in 'conto'
  query_conto <- paste0("
    INSERT INTO conto (iban, saldo, filiale)
    VALUES ('", iban_nuovo, "', 1000, '", filiale_nuovo, "');
  ")
  dbExecute(con, query_conto)
  
  # 2) Inserisci in 'contorisparmio' (se fosse conto corrente, lo faresti in 'contocorrente')
  query_risp <- paste0("
    INSERT INTO contorisparmio (iban, tasso_interesse)
    VALUES ('", iban_nuovo, "', 1.5);
  ")
  dbExecute(con, query_risp)
  
  # 3) Collega il conto al cliente in 'possiede'
  query_possiede <- paste0("
    INSERT INTO possiede (cliente, conto, tipo_operazione, data_operazione)
    VALUES (", id_cliente, ", '", iban_nuovo, "', 'apertura', CURRENT_DATE);
  ")
  dbExecute(con, query_possiede)
  
  # Se tutti gli insert vanno a buon fine, andiamo a commit
  ok <- TRUE
  
}, error = function(e) {
  cat("Errore durante l'inserimento del nuovo conto risparmio: ", e$message, "\n")
})

if(ok) {
  dbCommit(con)
  cat("Transazione completata con successo!\n")
} else {
  dbRollback(con)
  cat("Transazione annullata: non tutte le operazioni sono riuscite.\n")
}

# Verifica finale
conto_inserito <- dbGetQuery(con, paste0("SELECT * FROM conto WHERE iban = '", iban_nuovo, "';"))
print(conto_inserito)
risp_inserito <- dbGetQuery(con, paste0("SELECT * FROM contorisparmio WHERE iban = '", iban_nuovo, "';"))
print(risp_inserito)
possiede_inserito <- dbGetQuery(con, paste0("SELECT * FROM possiede WHERE conto = '", iban_nuovo, "';"))
print(possiede_inserito)

### Test 6: Inserimento di un gestore in un cliente ----
cat("\n=== Test Inserimento di un gestore in un cliente ===\n")

cliente_mio <- 29999
gestore_ok <- dbGetQuery(con, "SELECT gestore FROM cliente WHERE id=5999")
gestore_sbagliato <- dbGetQuery(con, "SELECT gestore FROM cliente WHERE id=6001")

dbExecute(con, paste0("
      UPDATE cliente
      SET gestore = '",gestore_sbagliato,"'
      WHERE id = 29999;
    "))

dbExecute(con, paste0("
      UPDATE cliente
      SET gestore = '",gestore_ok,"'
      WHERE id = 29999;
"))
result <- dbGetQuery(con, "SELECT * FROM cliente WHERE id = 29999")
print(result)




# ---- ESECUZIONE DELLE QUERY ----

## 1. Numero medio di rate dei prestiti associati a conti nelle filiali di Udine ----
media_rate_udine <- dbGetQuery(con, "
  SELECT AVG(mensilità) AS media_rate
  FROM prestito, conto, filiale
  WHERE prestito.conto = conto.iban
    AND conto.filiale = filiale.nome
    AND filiale.città = 'Udine';
")
print(media_rate_udine)

## 2. Clienti con solo conti risparmio in filiali con 30–32 dipendenti ----
 dbExecute(con, "
  CREATE OR REPLACE VIEW filiali_3032 AS
  SELECT filiale, COUNT(*) AS n_dip
  FROM dipendente
  GROUP BY filiale
  HAVING COUNT(*) BETWEEN 30 AND 32;
")

clienti_risparmio <- dbGetQuery(con, "
  SELECT cliente.id
  FROM cliente, possiede, conto, filiali_3032
  WHERE cliente.id = possiede.cliente
    AND possiede.conto = conto.iban
    AND conto.filiale = filiali_3032.filiale
    AND NOT EXISTS (
      SELECT 1
      FROM contocorrente
      WHERE contocorrente.iban = conto.iban
    );
")
print(head(clienti_risparmio, 10))  # Stampa solo le prime 10 righe

## 3. Capi che gestiscono almeno 3 clienti ricchi (con oltre 100k euro nei conti) ----
dbExecute(con, "
  CREATE OR REPLACE VIEW clienti_ricchi AS
  SELECT cliente.id, SUM(conto.saldo) AS soldi, cliente.gestore
  FROM cliente, possiede, conto
  WHERE cliente.id = possiede.cliente
    AND conto.iban = possiede.conto
  GROUP BY cliente.id, cliente.gestore
  HAVING SUM(conto.saldo) > 100000;
")

capi <- dbGetQuery(con, "
  SELECT DISTINCT capo
  FROM dipendente
  WHERE EXISTS (
    SELECT *
    FROM clienti_ricchi c1, clienti_ricchi c2, clienti_ricchi c3
    WHERE c1.gestore = dipendente.id
      AND c2.gestore = dipendente.id
      AND c3.gestore = dipendente.id
      AND c1.id < c2.id AND c2.id < c3.id
  );
")
print(capi)

## 4. Dipendenti (non capi) che gestiscono due clienti: uno con solo conti correnti, uno con solo conti risparmio ----
dbExecute(con, "
  CREATE OR REPLACE VIEW clienti_correnti AS
  SELECT possiede.cliente, cliente.gestore
  FROM possiede, cliente
  WHERE possiede.cliente = cliente.id
    AND NOT EXISTS (
      SELECT 1
      FROM contorisparmio
      WHERE contorisparmio.iban = possiede.conto
    );
")

dbExecute(con, "
  CREATE OR REPLACE VIEW clienti_risparmio AS
  SELECT possiede.cliente, cliente.gestore
  FROM possiede, cliente
  WHERE possiede.cliente = cliente.id
    AND NOT EXISTS (
      SELECT 1
      FROM contocorrente
      WHERE contocorrente.iban = possiede.conto
    );
")

dipendenti <- dbGetQuery(con, "
  SELECT id
  FROM dipendente
  WHERE capo <> id
    AND EXISTS (
      SELECT *
      FROM clienti_correnti cc1
      WHERE cc1.gestore = dipendente.id
        AND NOT EXISTS (
          SELECT *
          FROM clienti_correnti cc2
          WHERE cc2.gestore = dipendente.id
            AND cc1.cliente <> cc2.cliente
        )
    )
    AND EXISTS (
      SELECT *
      FROM clienti_risparmio cr1
      WHERE cr1.gestore = dipendente.id
        AND NOT EXISTS (
          SELECT *
          FROM clienti_risparmio cr2
          WHERE cr2.gestore = dipendente.id
            AND cr1.cliente <> cr2.cliente
        )
    );
")
print(dipendenti)

## 5. Cliente con il prestito più alto nella filiale di Roma non gestito da un dipendente con meno di 3 anni di esperienza ----
data_limite <- Sys.Date() - (365 * 3)

dbExecute(con, paste0("
  CREATE OR REPLACE VIEW clienti_gestiti_3 AS
  SELECT cliente.id
  FROM cliente, dipendente
  WHERE cliente.gestore = dipendente.id
    AND dipendente.data_assunzione < DATE '", data_limite, "';
"))

dbExecute(con, "
  CREATE OR REPLACE VIEW candidati AS
  SELECT cliente.id, prestito.ammontare
  FROM cliente, clienti_gestiti_3, possiede, prestito, conto, filiale
  WHERE cliente.id = clienti_gestiti_3.id
    AND cliente.id = possiede.cliente
    AND possiede.conto = prestito.conto
    AND prestito.conto = conto.iban
    AND conto.filiale = filiale.nome
    AND filiale.città = 'Roma';
")

cliente_top <- dbGetQuery(con, "
  SELECT id, ammontare
  FROM candidati c1
  WHERE NOT EXISTS (
    SELECT 1
    FROM candidati c2
    WHERE c2.ammontare > c1.ammontare
  );
")
print(cliente_top)



# ---- GRAFICI ----


## 1. Distribuzione mensilità per i prestiti di conti con > 100.000 che sono gestiti da un gestore. ----


dbExecute(con, paste0("
  CREATE OR REPLACE VIEW clienti_gestiti AS
  SELECT cliente.id, cliente.gestore
  FROM cliente, dipendente
  WHERE cliente.gestore = dipendente.id;
"))

table <- dbGetQuery(con, paste0("
  SELECT mensilità, COUNT(*)
  FROM clienti_gestiti, possiede, conto, prestito
  WHERE clienti_gestiti.id = possiede.cliente
  AND possiede.conto = conto.iban
  AND conto.saldo > 50.000
  AND possiede.conto = prestito.conto
  GROUP BY mensilità
"))

hist(table$mensilità, breaks = seq(0, 250, by = 10),
     main = "Distribuzione mensilità per prestiti afferenti conti con saldo > 50.000 €",
     xlab = "Mensilità", ylab = "Frequenza", col = "skyblue", border = "white")


## 2. soldi gestiti dai gestori in funzione dell'anzianità ----

dbExecute(con, paste0("
  CREATE OR REPLACE VIEW dipendenti_gestori AS
  SELECT dipendente.data_assunzione, dipendente.id
  FROM cliente, dipendente
  WHERE cliente.gestore = dipendente.id;
"))

table <- dbGetQuery(con, paste0("
  SELECT SUM(conto.saldo) as skey, dipendenti_gestori.data_assunzione 
  FROM clienti_gestiti, possiede, conto, dipendenti_gestori
  WHERE clienti_gestiti.id = possiede.cliente
  AND possiede.conto = conto.iban
  AND dipendenti_gestori.id = clienti_gestiti.gestore 
  GROUP BY dipendenti_gestori.data_assunzione
  ;
"))

print(table)
plot(table[,2], table[,1], main="titolo")

# 3. Per filiale, il numero di conti cointestatari con un prestito afferente ----

# Il numero di conti cointestati per filiale che hanno almeno un prestito associato.
dbExecute(con, paste0("
  CREATE VIEW conti_cointestati AS
  SELECT p1.conto, conto.filiale
  FROM possiede AS p1, conto
  WHERE p1.conto = conto.iban AND EXISTS (
    SELECT *
    FROM possiede AS p2
    WHERE p1.conto = p2.conto AND p1.cliente < p2.cliente)
;"))
#Giusto mettere solo < e non <> perchè se no conto doppi?
  
  
table <- dbGetQuery(con, paste0("
  SELECT filiale, COUNT(*) AS n_conti
  FROM conti_cointestati, prestito
  WHERE conti_cointestati.conto = prestito.conto
  AND ammontare > 50.000
  GROUP BY filiale
;"))

table$n_conti <- as.numeric(table$n_conti)

barplot(table$n_conti, names.arg = table$filiale,
        main = "Numero conti cointestati con prestito per filiale",
        xlab = "Filiale", ylab = "Numero conti", col = "skyblue", border = "white", las = 2)









