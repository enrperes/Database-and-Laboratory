/* ------------ Document Setup ------------- */
#set heading(numbering: "1.")
#set text(lang: "it")
#set page(numbering: "1")
#set quote(block: true)
#set par(justify: true)
#show figure.caption: (emph)

/* ------------ Variabili ------------- */
#let title = text(25pt)[Relazione progetto di Laboratorio]
#let subtitle = text(20pt)[Corso di Basi di Dati]
#let date = text(15pt)[Università degli studi di Udine, A.A. 2024-2025]
#let er(text) = upper(emph(text))


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
L'analisi dei requisiti ha portato alla definizione di un insieme di entità e relazioni che costituiscono il modello concettuale della base di dati.

- L'entità #er[dipendente] è caratterizzata da un codice univoco _ID_ che funge da chiave primaria. _Nome_, _Cognome_, _Numero di telefono_, _Data di assunzione_ sono gli altri attributi che la descrivono. è stato scelto di tenere traccia dell'anzianità aziendale sulla base della data di assunzione. \ Il capo viene descritto da una specializzazione parziale di #er[dipendente], chiamata  #er[capo]. 

- L'entità #er[capo] rappresenta il capo di una filiale. Essendo una generalizzazione dell'eneità #er[dipendente], eredita tutti gli attributi di quest'ultima. Un capo è univoco per ogni filiale. 

- L'enittà #er[filiale] rappresenta una unità operativa della banca situata in una determinata città. La chiave primaria è il _Nome_, mentre gli altri attributi sono _Città_ e _Indirizzo_.  Inoltre, per ogni filiale è presente l'attributo derivato _Attivi_, che rappresenta l'ammontare totale della liquidità della filiale e viene calcolato sulla base dei conti, prestiti e rate ad esso associati.

- La relazione #er[è capo] collega l'entità #er[capo] con l'entità #er[filiale], definendo il legame tra il capo di una filiale e la filiale stessa. La cardinalità di (1,1) tra la relazione e l'entità Filiale indica che ogni #er[filiale] ha un solo capo, mentre la cardinalità di (0,1) tra la relazione e l'entità #er[Capo] indica che un dipendente può essere al più capo di una sola filiale.

- La relazione #er[lavora] collega l'entità #er[dipendente] con l'entità #er[filiale]. La cardinalità di (1,1) tra la relazione e l'entità Dipendente indica che ogni dipendente lavora in una e in una sola filiale, mentre la cardinalità di (1,N) tra la relazione e l'entità #er[filiale] indica che in una filiale lavora uno o più dipendenti.

- La relazione #er[di] lega l'entità #er[dipendente] con l'entità #er[capo]. La cardinalità di (1,N) tra la relazione e l'entità #er[capo] indica che un capo dirige uno o più dipendenti, mentre la cardinalità di (1,1) tra la relazione e l'entità #er[dipendente] indica che un dipendente ha uno e un solo capo. 

- L'entità #er[Prestito] costituisce il servizio creditizio della banca. Essa è caratterizzata innanzitutto da un codice univoco che funge da chiave primaria, garantendo l’identificazione sicura di ogni singolo prestito all’interno del sistema. L’attributo _ammontare_ fornisce invece l'informazione relativa alla somma di denaro effettivamente erogata, mentre l’attributo  _inizio_ registra la data in cui il prestito ha avuto origine. Un aspetto interessante di questa entità è la presenza di un attributo derivato, _somma rate_ calcolato sulla base dell’insieme delle rate associate a quel prestito. Questo calcolo deriva appunto dalla relazione con l’entità #er[Rata], che verrà descritta successivamente. 

- L’entità #er[rata] è una entità debole ed ha il compito di rappresentare in modo dettagliato ogni singolo pagamento periodico associato a un determinato prestito. L’identificazione univoca di ciascuna rata è garantita da una chiave primaria composta, costituita dal suo numero (indicante la “posizione” della rata nella sequenza dei pagamenti) e dalla chiave esterna che fa riferimento all’entità Prestito.  Tra gli attributi figurano inoltre la _data scadenza_, ossia il giorno entro cui la rata deve essere corrisposta, e la _data pagamento_, che riporta il momento in cui il versamento è stato effettivamente effettuato. Infine, l’attributo _ammontare_ specifica l’importo dovuto per quella singola rata.

- La relazione #er[é composto] collega l’entità #er[prestito] con l’entità #er[Rata], dando forma al legame logico tra un finanziamento e i singoli pagamenti previsti per il suo rimborso. Dal lato di #er[Rata], la cardinalità è di (1,1), poiché ogni rata è necessariamente associata ad uno e un solo prestito specifico data la natura di #er[Rata] come entità debole. Dal lato di Prestito, invece, la cardinalità è di (1,N), poiché un singolo prestito può essere suddiviso in una o più rate. In sintesi, questa relazione rispecchia un legame di composizione, dove ogni prestito è scomponibile in un insieme di rate, ma ogni rata non può prescindere dal proprio prestito di appartenenza.

- La relazione #er[è associato] collega l’entità Conto con l’entità Prestito, definendo il legame tra un finanziamento e il conto bancario a cui è associato. Dal lato di #er[Prestito], la cardinalità è (1,1), poiché ogni prestito deve fare riferimento obbligatoriamente a un solo conto bancario. Dal lato di Conto, invece, la cardinalità è (0,N): questo riflette il fatto che un conto può non avere alcun prestito associato, ma può anche essere collegato a uno o più prestiti contemporaneamente.

- L'entità #er[Cliente] rappresenta una persona fisica che ha aperto nella banca almeno un conto. Essa è caratterizzata da un _codice univoco_ assegnato dalla banca ad ogni cliente e dal _codice fiscale_, entrambi questi attributi fungono da chiavi primarie in quanto sono univoche per ogni cliente. Gli altri attributi servono per tenere traccia dell’anagrafica del cliente, quali _Nome_, _Cognome_, _numero di Telefono_, _Data di nascita_ e _residenza_.

- L’entità #er[Conto] serve per identificare un servizio della banca messo a disposizione per il cliente. Ogni entità viene identificata univocamente da un attributo _IBAN_ e un attributo _Saldo_ tiene traccia dell’ammontare in denaro presente su tale conto. La banca inoltre mette a disposizione due tipi di conto, quindi l’entità Conto è stata specializzata in due sottoentità: #er[Conto Corrente] e #er[Conto di Risparmio]. La specializzazione è totale e disgiunta: l’insieme dei conti correnti e dei conti di risparmio è disgiunto e la loro unione è esattamente l’insieme di tutti i conti all’interno della filiale.

- L’entità #er[Conto Corrente] è una specializzazione dell’entità #er[conto] pertanto ne eredita tutti gli attributi e tutte le relazioni, la chiave primaria è quindi quella dell’entità #er[Conto]. L' attributo che caratterizza #er[Conto Corrente] è _Scoperto_ che indica il valore, concordato tra cliente e banca, di quanto la banca può concedere di debito nei confronti del cliente.

- L’entità #er[Conto di Risparmio] è una specializzazione dell’entità #er[conto] pertanto ne eredita tutti gli attributi e tutte le relazioni, la chiave primaria è quindi quella dell’entità di Conto. L'attributo che lo caratterizza è Tasso di interesse che indica il valore, concordato tra cliente e banca, di quanto rende mensilmente il deposito su quel conto.

- La relazione #er[Possiede] collega le entità #er[Cliente] e #er[Conto]. Un cliente deve possedere almeno un conto e più clienti possono possedere lo stesso conto (caso di conto cointestato), da cui deriva la cardinalità (1, N) della relazione sul lato di #er[Cliente]. D’altro canto un #er[conto] deve essere posseduto da almeno un cliente e più conti possono fare riferimento allo stesso cliente (caso in cui uno stesso cliente ha aperto più conti con la banca), da cui deriva la cardinalità (1, N) della relazione sul lato di #er[conto]. Gli attributi _Operazione_ e _Data_ sulla relazione indicano l’ultima operazione svolta e la data in cui è stata effettuata. Nel caso di operazione congiunta di più clienti possessori dello stesso conto gli attributi _Operazione/Data_ vengono aggiornati per entrambi.

- La relazione #er[Gestisce] lega #er[Dipendente] e #er[Cliente]. Un sottoinsieme dei dipendente possono seguire le pratiche di un certo numero di clienti della banca, da cui ne deriva la cardinalità (0, N) della relazione sul lato di #er[dipendente]. D’altro canto un #er[Cliente] può avere al più un solo gestore che monitora e consiglia le sue attività nella banca, da cui ne deriva la cardinalità (0, 1) della relazione sul lato di cliente.

- La relazione #er[Contiene] collega #er[Filiale] a #er[Conto] in quanto ogni #er[Conto] deve fare riferimento ad una e una sola #er[filiale]. Una filiale può contenere uno o più conti (anche zero se la filiale è appena stata aperta), da cui ne deriva la cardinalità (0, N) della relazione sul lato di FIliale. D’altro canto un #er[conto] deve essere associato ad una e una sola #er[filiale], da cui ne deriva la cardinalità (1, 1) della relazione sul lato di Conto.


#figure(
  image("ER_Banca_1.svg", width: 120%),
  caption: [Schema concettuale nel modello Entità Relazioni]
)

=== 
===
== Schema Concettuale
= Progettazione Logica
== Tabella dei volumi

Analizziamo ora i passi che abbiamo effettuato per le ridondanze ed i volumi del
nostro schema. Nella ottimizzazione delle prestazione e nella semplificazione dello
schema ER concettuale verso lo schema ristrutturato abbiamo considerato i volumi
dei dati, che sono stati ipotizzati secondo i volumi di una banca reale di riferimento
(Banca Intesa San Paolo) e delle operazioni che in seguito elencheremo. 

#figure(
  table(
    columns: 3, 
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#ddd") },
    align: (x, y) =>
      if y == 0 { center } else {
        if x < 1 { center + horizon } else { left }
      },
  table.header([Nome], [Costrutto], [Volume]),
  [Dipendente] , [Entità], [100.000],
  [Cliente] , [Entità], [15.000.000],
  [Filiale] , [Entità], [3.000],
  [Conto] , [Entità], [12.000.000],
  [Conto Corrente] , [Entità], [10.000.000],
  [Conto di Risparmio] , [Entità], [2.000.000],
  [Prestito] , [Entità], [7.000.000],
  [Gestisce] , [Relazione], [10.000.000],
  [Lavora] , [Relazione], [100.000],
  [#upper[è] capo] , [Relazione], [3.000],
  [Possiede] , [Relazione], [7.000.000],
  [Di] , [Relazione], [3.000],
  [Possiede] , [Relazione], [19.000.000],
  [Contiene] , [Relazione], [12.000.000],
  [#upper[è] associato] , [Relazione], [7.000.000],
  ),
  caption: [Tabella dei volumi]
)
== Analisi della ridondanze

Il primo blocco di operazioni coinvolge l'attributo derivato attivi che produce una ridondanza ed è derivalbile da altre entità, nel nostro caso da Conto, Prestito e Rata, seguendo il caso di attributo derivabile da altre entità secondo funzioni aggregative. Dobbiamo quindi ipotizzare delle operazioni e le loro relative frequenze che vanno a coinvolgere questo attributo ed osservare se è conveniente eliminarlo o mantenerlo. Consideriamo una serie di operazioni e la loro frequenza:

  + interrogazione per leggere il valore attivi di ogni filiale con frequenza 1 volta al giorno, 
  + inserimento di un conto nella base di dati con frequenza 150 volte al giorno, 
  + inserimento di una operazione in possiede con frequenza 1.000.000 al giorno, 
  + aggiornamento di tutti i prestiti con frequenza di 1 volta al mese.
Queste operazioni con la presenza dell'attributo ridondante _attivi_ portano ai seguenti costi:

=== Con ridondanza

#figure(
  table(
    columns: 4, 
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#ddd") },
    align: (x, y) =>
      if y == 0 { center } else {
        if x == 2 { center + horizon } else { left }
      },
  table.header([Nome], [Costrutto], [Acecssi], [Tipo]),
  [Filiale], [Entità], [3000], [Lettura],
  ),
  caption: [Operazione 1]
)

#figure(
  table(
    columns: 4, 
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#ddd") },
    align: (x, y) =>
      if y == 0 { center } else {
        if x == 2{ center + horizon } else { left }
      },
  table.header([Nome], [Costrutto], [Accessi], [Tipo]),
  [Conto], [Entità], [150], [Scrittura],
  [Contiene], [Entità], [150], [Scrittura],
  [Possiede], [Relazione], [150], [Scrittura],
  [Filiale], [Entità], [150], [Scrittura],
  [Filiale], [Entità], [150], [Lettura],
  ),
  caption: [Operazione 2]
)

#figure(
  table(
    columns: 4, 
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#ddd") },
    align: (x, y) =>
      if y == 0 { center } else {
        if x == 2 { center + horizon } else { left }
      },
  table.header([Nome], [Costrutto], [Accessi], [Tipo]),
  [Possiede], [Relazione], [1.000.000], [Scrittura],
  [Possiede], [Relazione], [1.000.000], [Lettura],
  [Conto], [Entità], [1.000.000], [Scrittura],
  [Conto], [Entità], [1.000.000], [Lettura],
  [Filiale], [Entità], [1.000.000], [Scrittura],
  [Filiale], [Entità], [1.000.000], [Lettura],
  [Contiene], [Relazione], [1.000.000], [Lettura],
  ),
  caption: [Operazione 3]
)

#figure(
  table(
    columns: 4, 
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#ddd") },
    align: (x, y) =>
      if y == 0 { center } else {
        if x == 2 { center + horizon } else { left }
      },
  table.header([Nome], [Costrutto], [Accessi], [Tipo]),
  [Rata], [Entità], [], [Scrittura],
  [#upper[è] composto], [Relazione], [], [Scrittura],
  [#upper[è] composto], [Relazione], [], [Lettura],
  [Prestito], [Entità], [], [Lettura],
  [#upper[è] associato], [Relazione], [], [Lettura],
  [Conto], [Entità], [], [Lettura],
  [Contiene], [Relazione], [], [Lettura],
  [Filiale], [Entità], [], [Lettura],
  [Filiale], [Entità], [], [Scrittura],
  ),
  caption: [Operazione 4]
)

=== Senza ridondanza

#figure(
  table(
    columns: 4, 
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#ddd") },
    align: (x, y) =>
      if y == 0 { center } else {
        if x == 2 { center + horizon } else { left }
      },
  table.header([Nome], [Costrutto], [Accessi], [Tipo]),
  [Rata], [Entità], [], [Scrittura],
  [#upper[è] composto], [Relazione], [], [Scrittura],
  [#upper[è] composto], [Relazione], [], [Lettura],
  [Prestito], [Entità], [], [Lettura],
  [#upper[è] associato], [Relazione], [], [Lettura],
  [Conto], [Entità], [], [Lettura],
  [Contiene], [Relazione], [], [Lettura],
  [Filiale], [Entità], [], [Lettura],
  [Filiale], [Entità], [], [Scrittura],
  ),
  caption: [Operazione 1]
)

$ "op1: (1 lettura)" dot 3.000$ \
$"op2: (4 scrittura{conto, contiene, possiede, filiale}" + 1 "lettura{filiale})" dot 150$
op3: (3 scrittura{Possiede, conto, filiale} + 4 letture{Possiede, conto, filiale, contiene}) x 1.000.000
op4: (3 scritture{Rata, Prestito, Filiale} + 5 Letture{}) x 7.000.000 x 1/30
totale: 12.107.500

Senza ridondanza
op1: ((2 letture * 4000 {Contenuto, Conto}) + (2 letture * 2333{è associato, Prestito})) * 3000
op2: (3 scritture{Possiede, Conto, Contenuto}) * 150 
op3 : (2 letture{Possiede, Conto}, 2 scritture{Possiede, Conto}) * 1.000.000 
op4: (1 scrittura, 1 lettura) * 7.000.000 x 1/30 
totale: 44.700.900

La seguente analisi ci suggerisce che la conservazione dell'attributo derivato attivi sia utile e quindi lo manteniamo nel nostro schema ristrutturato. 

Il secondo blocco di operazioni riguardano la ridondanza introdotta dall'attributo derivato somma rate dell'entità Prestito, anche in questo caso è il caso di un attributo derivato secondo funzioni aggregative e le entità che sono coinvolte sono Rata e Prestito. Possiamo considerare due operazioni che sono:
1- inserimento di una rata una volta al mese per ogni prestito della banca 
2- lettura del valore della somma delle rate pagate per ogni prestito con frequenza di 2 volte all'anno.
Per questa analisi abbiamo dovuto introdurre una ulteriore ipotesi e cioè il numero medio di rate presenti nella nostra base di dati per ogni prestito. Abbiamo supposto essere questo numero 12, che equivale ad un anno di rate pagate.

Con ridondanza
Inserimento di una rata: 2 (scritture) * 7.000.000 (prestiti) * 1 (volta al mese) = 28 mln
Lettura: 1 (lettura) * 7.000.000 (prestiti) * 1/6 mese = 7/6 mln
totale: 29.160.000

Senza ridondanza
Inserimento di una rata: 1 (scrittura) * 7.000.000 (prestiti) * 1 (volta al mese) = 14 mln
Lettura = 12 * 7.000.000 * 1/6 = 84 mln
totale: 28.000.000

Per questa ridondanza abbiamo concluso quindi che l'attributo somma rate potesse essere rimosso dal nostro schema e non utilizzato nello schema ER ristrutturato.


=== 
===
== Selelezione delle chiavi primarie
== Schema E-R ristrutturato 
== Schema Logico 

/*
#figure(
  table(
    columns: 4, 
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#ddd") },
    align: (x, y) =>
      if y == 0 { center } else {
        if x < 1 { center + horizon } else { left }
      },
  table.header([Nome], [Costrutto], [Accessi], [Tipo]),
  [], [], [], [],
  [], [], [], [],
  [], [], [], [],
  [], [], [], [],
  [], [], [], [],
  [], [], [], [],
  [], [], [], [],
  ),
  caption: [Operazione 1]
)
*/