/* ------------ Document Setup ------------- */
#set heading(numbering: "1.")
#set text(lang: "it")
#set page(numbering: "1")
#set quote(block: true)
#show figure.caption: (emph)


#let title = text(25pt)[Relazione progetto di Laboratorio]
#let subtitle = text(20pt)[Corso di Basi di Dati]
#let date = text(15pt)[Università degli studi di Udine, A.A. 2024-2025]

#align(center, text(25pt)[
  #v(30%)
  #title \
  #subtitle \
  #date
])

#grid(
  columns: (1fr, 1fr),
  align(center)[
    Daniele De Martin \
    Enrico Peressin \
  ],
  align(center)[
    Massimiliano Di Marco \
    Michele Vecchiato \
  ]
)

#align(center)[
  #v(5em)
  #text(15pt)[#strong()[#upper[Progettazione e implementazione \ di una base di dati per la gestione di una banca]]]
  #v(2em)
]
#pagebreak()

/* ------------------------- */

#outline(indent: auto, title: "Indice")

/* 
1. Analisi dei requisiti 
2. Progettazione concettuale
3. Progettazione logica
4. Progettazione fisica
5. Implementazione
6. Analisi dei dati 
*/ 

#pagebreak()

/* ------------------------- */

= Raccolta e analisi dei requisiti
== Richiesta Originale
#quote[
  Si vuole progettare una base di dati di supporto ad alcune delle attività di una banca. \
  La banca è organizzata in un certo numero di filiali. Ogni filiale si trova in una determinata città ed è identificata univocamente da un nome (si noti che in unc città vi possono essere più filiali). La banca tiene traccia dei risultati (attivi) conseguiti da ciascuna filiale. \
  Ai clienti della banca è assegnato un codice che li identifica univocamente. La banca tiene traccia del nome del cliente e della sua residenza. I clienti possono possedere uno o più conti e possono chiedere prestitil. Ad un cliente può essere associato un particolare dipendente della banca, che segue personalmente tutte le pratiche del cliente (si tenga presente che non tutti i clienti godono di tale privilegio e che ad un dipendente della banca possono essere associati zero, uno o più clienti). \ 
  I dipendenti della banca sono identificati da un codice. La banca memorizza nome e recapito telefonico di ogni dipendente, il nome delele persone a suo carico e il codice dell'eventuale capo. La banca tiene inoltre traccia della data di assunzione di ciascun dipendente e dell'anzianità aziendale di ciascun dipendente (da quanto tempo tale dipendente lavora per la banca). \
  La banca offre due tipi di conto: conto corrente (con la possibilità di emettere assegni, ma senza interessi) e conto di risparmio (senza la possibilità di emettere assegni, ma con interessi). Un conto èuò essere posseduto congiuntamente da più clienti e un cliente può possedere più conti. Ogni conto è caratterizzato da un numero che lo identifica univocamente. Per ogni conto, la banca tiene traccia del saldo corrente e della data dell'ultima operazione eseguita da ciascuno dei possessori (un'operazione può essere eseguita congiuntamente da più possessori). Ogni conto di risparmio è caratterizzado da un tasso di interesse, mentre ogni conto corrente è caratterizzato da uno scoperto accordato al cliente. \
  Un prestito (ad esempio, un mutuo) viene emesso da una specifica filiale e può essere attribuito a uno o più clienti congiuntamente. Ogni prestito è identificato univocamente da un codice numerico. Ogni prestito è caratterizzato da un ammontare e da un insieme di rate per la restutuzione del prestito. Ogni rata di un dato prestito è contraddistinta da un numreo d'ordine (prima rata, seconda rata...). Di ogni rata vengono memorizzati anche la data e l'ammontare. \
]


== Analisi dei Requisiti
=== Assunzioni
Al fine di proseguire con la progettazione concettuale, sono state effettuate le seguenti assunzioni:

- Gli *attivi* sono la somma della liquidità dei conti meno la somma dei prestiti erogati. Sono relativi alla singola filiale.
- Un *cliente* può avere conti in filiali diverse e ogni conto è associato ad una singola filiale. 
- I *prestiti* sono legati al conto, non al cliente.
- Un *dipendente* non può gestire se stesso.
- Un *dipendente* può gestire clienti al di fuori della propria filiale e lavora in una sola filiale.
- Il *capo* di un dipendente è l'unico responsabile della filiale in cui il dipendente lavora.
- Nei *conti cointestati* i clienti devono avere lo stesso dipendente (gestore) che li gestisce.
- In caso di *ri-assunzione* di un dipendente, si tiene conto solo dell'ultima assunzione per il calcolo dell'anzianità.
- Tutte le *rate* di un determinato prestito hanno lo stesso ammontare. 





=== Glossario
Per chiarire il significato e le relazioni dei termini chiave definite nei requisiti viene fornito un glossario esplicativo: 

#show table.cell.where(x: 0).or(table.cell.where(y: 0)): strong

#figure(
  table(
    columns: 3, 
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#ddd") },
    align: (x, y) =>
      if y == 0 { center } else {
        if x < 1 { center + horizon } else { left }
      },
  table.header([Termine], [Descrizione], [Collegamenti]),
  [Filiale] , [Unità operativa della banca situata in  una determinata città. È gestita da un unico capo. ], [Conto, Dipendente, Capo],
  //[Attivi] , [Ammontare totale della liquidità di una filiale.], [], [],
  [Cliente] , [Persona fisica con almeno un conto aperto nella banca], [Conto, Gestore],
  [Conto] , [Servizio di gestione del denaro che permette diverse operazioni. Può essere esclusivamente corrente o di risparmio], [Cliente, Filiale], 
  [Conto Corrente] , [Tipo di conto caratterizzao da uno scoperto ], [Conto],
  [Conto di risparmio] , [Tipo di conto caratterizzato da un tasso di interessse], [Conto],
  // [Rata] , [], [], [],
  // [Dipendente] , [], [], [],
  [Gestore] , [Dipendente che prende in carico le pratiche di uno o più clienti], [ ],
  [Capo] , [Unico responsabile della filiale presso cui lavora], [Dipendente],
  // [Persona a carico] , [Cliente con il privilegio di essere seguita da un gestore], [],
  //[Possessore (di conto)] , [Altro modo di definire cliente], [], [],
  // [] , [], [], [],
  // [] , [], [], [],
  ),
  caption: [Glossario dei termini chiave]
)

= Progettazione Concettuale
== Costruzione dello schema Entità Relazione
#figure(
  image("ER_Banca_1.svg", width: 120%),
  caption: [Schema concettuale nel modello Entità Relazioni]
)
=== 
===
== Schema Concettuale
= Progettazione Logica
== Tabella dei volumi
== Analisi della ridondanze
=== 
===
== Selelezione delle chiavi primarie
== Schema E-R ristrutturato 
== Schema Logico 