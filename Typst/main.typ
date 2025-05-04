/* ------------ Libraries ------------- */
#import "@preview/zebraw:0.5.2": *

/* ------------ Document Setup ------------- */
#set text(lang: "it")
#set page(numbering: "1")
#set par(justify: true)


// Debug
// #set block(stroke: 0.5pt)

// Quotes
#set quote(block: true)
#show quote: set text(font: "", size: 12pt, style: "italic")

// Headings
#set heading(numbering: "1.")
#show heading: set block(below: 1.5em)
#show heading.where(level: 1): set text(20pt)
#show heading.where(level: 2): set text(14pt)
#show heading.where(level: 3): set text(12pt)
//#show heading.where(level: 4): set heading(numbering: none)


// Figures
#show figure.caption: it => [
 #text(9pt)[ 
 #it.supplement
 #context it.counter.display(it.numbering)]:
 #emph[#it.body]
]

// Outline
#show outline.entry.where(level: 1): set text(weight: "bold", size: 13pt)
//#show outline.entry.where(level: 1): set block(below: 2.5em)
#show outline.entry.where(level: 1): set block(below: 1.2em)


// Code Blocks styling
#show: zebraw-init.with(
  numbering: false,
  lang: true,
  comment-font-args: (font: "Courier", size: 10pt),
  comment-color: rgb("#ddd"),
)

/* ------------ Variables ------------- */
#let title = text(25pt)[Relazione progetto di Laboratorio]
#let subtitle = text(20pt)[Corso di Basi di Dati]
#let date = text(15pt)[Università degli studi di Udine, A.A. 2024-2025]
#let er(text) = upper(emph(text))
#let err(text) = (emph(text))
#let erb(text) = upper(emph(strong(text)))
#let erbr(text) = (emph(strong(text)))
#let figure-r(..args) = {
  show figure: set align(right)
  figure(..args)
}
#let u(text) = underline(offset: 0.2em, stroke: 1pt, text)



/* ------------ Document Starts Here ------------- */

#align(center, text(25pt)[
  #v(15%)
  #image("media/logo_uniud.svg", width: 20%)
  #title \
  #subtitle \
  #date
])

#grid(
  columns: (1fr, 1fr),
  align(center)[
    Daniele De Martin [162521\@spes.uniud.it] \
    Enrico Peressin [163503\@spes.uniud.it] \
  ],
  align(center)[
    Massimiliano Di Marco [144714\@spes.uniud.it] \
    Michele Vecchiato [162101\@spes.uniud.it] \
  ]
)

#align(center)[
  #v(5em)
  #text(17pt)[#strong()[#upper[Progettazione e implementazione \ di una base di dati per la gestione di una banca]]]
  #v(2em)
]
#pagebreak()

/* ------------Outline------------- */
#outline(
  indent: 2.5em, title: "Indice",
)

#pagebreak()

/* ------------------------- */

= Raccolta e analisi dei requisiti
== Richiesta Originale
#quote[
  Si vuole progettare una base di dati di supporto ad alcune delle attività di una banca. \
  La banca è organizzata in un certo numero di filiali. Ogni filiale si trova in una determinata città ed è identificata univocamente da un nome (si noti che in una città vi possono essere più filiali). La banca tiene traccia dei risultati (attivi) conseguiti da ciascuna filiale. \
  Ai clienti della banca è assegnato un codice che li identifica univocamente. La banca tiene traccia del nome del cliente e della sua residenza. I clienti possono possedere uno o più conti e possono chiedere prestiti. A un cliente può essere associato un particolare dipendente della banca, che segue personalmente tutte le pratiche del cliente (si tenga presente che non tutti i clienti godono di tale privilegio e che ad un dipendente della banca possono essere associati zero, uno o più clienti). \ 
  I dipendenti della banca sono identificati da un codice. La banca memorizza nome e recapito telefonico di ogni dipendente, il nome delle persone a suo carico e il codice dell'eventuale capo. La banca tiene inoltre traccia della data di assunzione di ciascun dipendente e dell'anzianità aziendale di ciascun dipendente (da quanto tempo tale dipendente lavora per la banca). \
  La banca offre due tipi di conto: conto corrente (con la possibilità di emettere assegni, ma senza interessi) e conto di risparmio (senza la possibilità di emettere assegni, ma con interessi). Un conto può essere posseduto congiuntamente da più clienti e un cliente può possedere più conti. Ogni conto è caratterizzato da un numero che lo identifica univocamente. Per ogni conto, la banca tiene traccia del saldo corrente e della data dell'ultima operazione eseguita da ciascuno dei possessori (un'operazione può essere eseguita congiuntamente da più possessori). Ogni conto di risparmio è caratterizzato da un tasso di interesse, mentre ogni conto corrente è caratterizzato da uno scoperto accordato al cliente. \
  Un prestito (ad esempio, un mutuo) viene emesso da una specifica filiale e può essere attribuito a uno o più clienti congiuntamente. Ogni prestito è identificato univocamente da un codice numerico. Ogni prestito è caratterizzato da un ammontare e da un insieme di rate per la restituzione del prestito. Ogni rata di un dato prestito è contraddistinta da un numero d'ordine (prima rata, seconda rata...). Di ogni rata vengono memorizzati anche la data e l'ammontare. \

]


== Analisi dei Requisiti
=== Assunzioni
Al fine di proseguire con la progettazione concettuale, sono state effettuate le seguenti assunzioni:

- Gli *attivi* sono la somma della liquidità dei conti meno la somma delle rate non pagate dei prestiti erogati. Sono relativi alla singola filiale.
- Un *cliente* può avere conti in filiali diverse e ogni conto è associato ad una singola filiale. 
- I *prestiti* sono legati al conto, non al cliente.
- Un *dipendente* non può gestire se stesso.
- Un *dipendente* lavora in una sola filiale con la possibilità di gestire clienti al di fuori della propria filiale.
- Il *capo* di un dipendente è l'unico responsabile della filiale in cui il dipendente lavora.
- Nei *conti cointestati* i clienti non possono essere seguiti da dipendenti (gestori) diversi.
- In caso di *ri-assunzione* di un dipendente, si tiene conto solo dell'ultima assunzione per il calcolo dell'anzianità.
- Tutte le *rate* di un determinato prestito hanno lo stesso ammontare e devono essere pagate in ordine. 





=== Glossario
Per chiarire il significato dei termini chiave definite nei requisiti viene fornito un glossario esplicativo: 

#show table.cell.where(x: 0).or(table.cell.where(y: 0)): strong

#figure(
  table(
    columns: 2, 
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#ddd") },
    align: (x, y) =>
      if y == 0 { center } else {
        if x < 1 { center + horizon } else { left }
      },
  table.header([Termine], [Descrizione]),
  [Filiale], [Unità operativa della banca situata in una determinata città. È gestita da un unico capo.],
  [Cliente], [Persona fisica con almeno un conto aperto nella banca.],
  [Conto], [Servizio di gestione del denaro che permette diverse operazioni. Può essere esclusivamente di tipo corrente o di risparmio.], 
  [Conto corrente], [Tipo di conto caratterizzato da uno scoperto.],
  [Conto di risparmio], [Tipo di conto caratterizzato da un tasso di interesse.],
  [Dipendente], [Persona fisica che lavora in una certa filiale della banca.],
  [Gestore], [Dipendente che prende in carico le pratiche di uno o più clienti.],
  [Operazione], [Transazioni bancarie effettuate su un conto da uno o più intestatari. Sono operazioni l'apertura di un conto, il prelievo, il pagamento elettronico (bancomat) e il versamento.],
  [Prestito], [Somma di denaro concessa dalla banca a un cliente.],
  ),
  caption: [Glossario dei termini chiave]
)

#pagebreak()

= Progettazione Concettuale
== Costruzione dello schema Entità-Relazione
L'analisi dei requisiti ha portato alla definizione di un insieme di entità e relazioni che costituiranno il modello concettuale della base di dati.

=== Entità


- L'entità #erb[filiale] rappresenta un'unità operativa della banca situata in una determinata città. La chiave primaria è il _Nome_, mentre gli altri attributi sono _Città_ e _Indirizzo_.  Inoltre, per ogni filiale è presente l'attributo derivato _Attivi_, che rappresenta l'ammontare totale della liquidità della filiale e viene calcolato sulla base dei conti, prestiti e rate ad esso associati.
#figure(
  image("media/filiale.svg", width: 20%),
  caption: [Entità FILIALE]
)
#v(2em)

- L'entità #erb[Cliente] rappresenta una persona fisica che ha aperto nella banca almeno un conto. Essa è caratterizzata da un codice univoco (_ID_) assegnato dalla banca ad ogni cliente e dal _Codice Fiscale_, entrambi questi attributi possono essere due chiavi primarie differenti in quanto sono uniche per ogni cliente. Gli altri attributi servono per tenere traccia dell'anagrafica del cliente: _Nome_, _Cognome_, _Telefono_, _Data di nascita_ e _Residenza_.

#v(-0.5em)
#figure(
  image("media/cliente.svg", width: 30%),
  caption: [Entità CLIENTE]
)
#v(2em)

- L'entità #erb[dipendente] è caratterizzata da un codice univoco _ID_ che funge da chiave primaria. _Nome_, _Cognome_, _Numero di telefono_, _Data di assunzione_ sono gli altri attributi che la descrivono. È stato scelto di tenere traccia dell'anzianità aziendale sulla base della data di assunzione. \ La qualifica di capo viene descritta da una specializzazione parziale di #er[dipendente], chiamata #erb[capo]. 
#v(-1.4em)
#figure(
  image("media/dipendente.svg", width: 30%),
  caption: [Entità DIPENDENTE]
)
#v(2em)

- L'entità #erb[Capo] rappresenta il capo di una filiale. \Essendo una specializzazione di #er[dipendente], eredita tutti gli attributi di quest'ultima. Un capo è unico per ogni filiale. 
#figure(
  image("media/capo.svg", width: 18%),
  caption: [Entità CAPO]
)
#v(2em)

- L'entità #erb[Conto] serve per identificare un servizio della banca messo a disposizione per il cliente. Ogni entità viene identificata univocamente da un attributo _IBAN_, un attributo _Saldo_ tiene traccia dell'ammontare di denaro presente sul conto. La banca inoltre mette a disposizione due tipi di conto, quindi #er[Conto] è stato specializzato in due sottoentità: #er[Conto Corrente] e #er[Conto di Risparmio]. La specializzazione è totale e disgiunta.

  - L'entità #erb[Conto Corrente] è una specializzazione di #er[conto] pertanto ne eredita tutti gli attributi e tutte le relazioni, la chiave primaria è quindi quella di #er[Conto]. L'attributo che lo caratterizza è _Scoperto_ che indica quanto la banca può concedere di debito nei confronti del cliente.

  - L'entità #erb[Conto di Risparmio] è una specializzazione di #er[conto] pertanto ne eredita tutti gli attributi e tutte le relazioni, la chiave primaria è quindi quella di di #er[Conto]. L'attributo che lo caratterizza è _Tasso d'interesse_ che indica il valore di rendita mensile del conto.
#figure(
  image("media/conto.svg", width: 28%),
  caption: [Entità CONTO]
)
#v(2em)

- L'entità #erb[Prestito] costituisce il servizio creditizio della banca. Essa è caratterizzata da un codice univoco che funge da chiave primaria. L'attributo _Ammontare_ fornisce l'informazione relativa alla somma di denaro prestata, mentre l'attributo _Inizio_ registra la data in cui il prestito ha avuto origine. _Somma rate_ è un attributo derivato, che tiene traccia dell'importo saldato dal cliente. L'attributo _Mensilità_ indica il numero di rate complessive del prestito.
#figure(
  image("media/prestito.svg", width: 30%),
  caption: [Entità PRESTITO]
)
#v(2em)

- L'entità #erb[rata] è un'entità debole che ha il compito di rappresentare ogni singolo pagamento periodico associato a un determinato prestito. L'identificazione univoca di ciascuna rata è garantita da una chiave primaria composta, costituita dal suo numero (indicante la “posizione” della rata nella sequenza dei pagamenti) e dalla chiave esterna che fa riferimento a #er[Prestito]. Tra gli attributi figurano inoltre la _Data scadenza_, ossia il giorno entro cui la rata deve essere corrisposta, e la _Data pagamento_, che riporta il momento in cui il versamento è stato effettuato. Infine, l'attributo _Ammontare_ specifica l'importo dovuto per quella singola rata.
#figure(
  image("media/rata.svg", width: 25%),
  caption: [Entità RATA]
)
#v(2em)

=== Relazioni
- La relazione #erbr[#upper[è] capo] collega #er[capo] e #er[filiale], definendo il legame tra il capo di una filiale e la filiale stessa. Le cardinalità di (1,1) indicano che ogni filiale ha uno e un solo capo e non esiste un capo che non faccia riferimento a una sola filiale. 
#figure(
  image("media/iscapo.svg", width: 80%),
  caption: [Relazione #upper[è] capo]
)
#v(2em)

- La relazione #erbr[Lavora] collega #er[dipendente] e #er[filiale]. La cardinalità di (1,1) tra la relazione e #er[Dipendente] indica che ogni dipendente lavora in una e in una sola filiale, mentre la cardinalità di (1,N) tra la relazione e #er[filiale] indica che in una filiale lavorano uno o più dipendenti.
#figure(
  image("media/lavora.svg", width: 80%),
  caption: [Relazione Lavora]
)
#v(2em)


- La relazione #erbr[Di] collega #er[dipendente] e #er[capo]. La cardinalità di (1,N) tra la relazione e #er[capo] indica che un capo dirige uno o più dipendenti, mentre la cardinalità di (1,1) tra la relazione e #er[dipendente] indica che un dipendente ha uno e un solo capo. 
#figure(
  image("media/di.svg", width: 80%),
  caption: [Relazione Di]
)
#v(2em)


- La relazione #erbr[#upper[è] composto] collega #er[prestito] e #er[Rata], dando forma al legame logico tra un finanziamento e i singoli pagamenti previsti per il suo rimborso. Dal lato di #er[Rata], la cardinalità è di (1,1), poiché ogni rata è necessariamente associata ad uno e un solo prestito, essendo #er[Rata] un'entità debole. Dal lato di #er[Prestito], invece, la cardinalità è di (1,N), poiché un singolo prestito può essere suddiviso in una o più rate.
#v(-1em)
#figure(
  image("media/composto.svg", width: 80%),
  caption: [Relazione #upper[è] composto]
)
#v(2em)

- La relazione #erbr[#upper[è] associato] collega #er[Conto] e #er[Prestito], definendo il legame tra esso e il conto bancario a cui è associato. Dal lato di #er[Prestito], la cardinalità è (1,1), poiché ogni prestito deve fare riferimento a un solo conto bancario. Dal lato di #er[Conto] la cardinalità è (0,N), infatti un conto non necessariamente ha prestiti associati e può averne più di uno.
#figure(
  image("media/isassociato.svg", width: 80%),
  caption: [Relazione #upper[è] associato]
)
#v(2em)

- La relazione #erbr[Possiede] collega #er[Cliente] e #er[Conto]. Un cliente deve possedere almeno un conto e più clienti possono possedere lo stesso conto (caso di conto cointestato), da cui deriva la cardinalità (1,N) della relazione sul lato di #er[Cliente]. D'altro canto, un #er[conto] deve essere posseduto da almeno un cliente e più conti possono fare riferimento allo stesso cliente (caso in cui uno stesso cliente ha aperto più conti con la banca), da cui deriva la cardinalità (1,N) della relazione sul lato di #er[conto]. \ Gli attributi _Operazione_ e _Data_ sulla relazione indicano l'ultima operazione svolta e la data in cui è stata effettuata da quel particolare cliente su quel particolare conto. Nel caso di operazione congiunta di più clienti gli attributi _Operazione/Data_ vengono aggiornati per tutti.
#figure(
  image("media/possiede.svg", width: 80%),
  caption: [Relazione Possiede]
)
#v(2em)

- La relazione #erbr[Gestisce] collega #er[Dipendente] e #er[Cliente]. Un sottoinsieme dei dipendenti può seguire le pratiche di un certo numero di clienti della banca, da cui ne deriva la cardinalità (0,N) della relazione sul lato di #er[dipendente]. D'altro canto un cliente può avere al più un solo gestore che segue le sue attività nella banca, da cui ne deriva la cardinalità (0,1) della relazione sul lato di #er[cliente].
#figure(
  image("media/gestisce.svg", width: 80%),
  caption: [Relazione Gestisce]
)
#v(2em)

- La relazione #erbr[Contiene] collega #er[Filiale] e #er[Conto] in quanto ogni conto deve fare riferimento ad una e una sola filiale. Una filiale può contenere uno o più conti (anche zero se la filiale è appena stata aperta), da cui ne deriva la cardinalità (0,N) della relazione sul lato di #er[filiale]. D'altro canto un conto deve essere associato ad una e una sola filiale, da cui ne deriva la cardinalità (1,1) della relazione sul lato di #er[Conto].
#figure(
  image("media/contiene.svg", width: 80%),
  caption: [Relazione Contiene]
)
#v(2em)

== Scelte particolari
- La specializzazione non totale #er[capo - dipendente] ci permette di inserire la molteplicità (1,1) nella relazione _#upper[è] capo_ e di non dover tenere la molteplicità (0,1) nel caso in cui #er[dipendente] non avesse avuto la specializzazione. Favorisce inoltre una maggiore chiarezza nella relazione _Di_.
- La specializzazione totale di #er[conto] è dovuta alla presenza dei diversi attributi che caratterizzano le due specializzazioni.
- La scelta di assegnare il ruolo di entità a #er[rata] è dovuta alla numerosità degli attributi e alla gestione dell'ammontare dei prestiti. Avendo un numero seriale non univoco, è necessario che una parte della chiave sia il codice del prestito.
#v(2.5em)

#pagebreak()

== Schema Concettuale
A seguito delle analisi effettuate, lo schema concettuale nel modello Entità-Relazione risultante è il seguente:
#figure(
  image("media/ER_Banca_1.svg", width: 125%),
  caption: [Schema concettuale nel modello Entità Relazione]
)

== Analisi dei cicli
=== Ciclo #er[dipendente - filiale - capo]:

#figure(
  image("media/ciclo_cap_dip_fil.svg", width: 50%),
  caption: [Ciclo DIPENDENTE - FILIALE - CAPO]
)
Questo ciclo è problematico in quanto potrebbe accadere che il capo di una filiale non lavori presso la filiale di cui è responsabile. È necessario imporre dei vincoli di integrità per evitare che ciò accada.
#v(2.5em)

=== Ciclo #er[dipendente - cliente - conto - filiale]:
#figure(
  image("media/ciclo_dip_cli_conto_fil.svg", width: 70%),
  caption: [Ciclo DIPENDENTE - CLIENTE - CONTO - FILIALE]
)
Questo ciclo non genera problemi di inconsistenza, in quanto a un cliente è permesso avere un gestore che lavora presso una certa filiale e avere più conti aperti in filiali diverse.
#v(2.5em)

== Vincoli d'integrità 
// (da riprendere nella sezione di implementazione fisica)
Alcuni vincoli non possono essere catturati tramite il modello ER, vengono riportati di seguito e saranno tenuti in considerazione nella sezione di implementazione fisica:
- Il capo di una filiale deve lavorare nella filiale in cui è responsabile.

- Due clienti che hanno gestori differenti non possono avere un conto condiviso.
- Un dipendente non può gestire se stesso.
- Le rate vanno pagate in ordine cronologico, in base a _Numero_.
- La somma dell'importo delle rate deve corrispondere all'ammontare del prestito.

#pagebreak()
= Progettazione Logica
Nel processo di ottimizzazione delle prestazioni, nell’analisi delle ridondanze e nella semplificazione dello schema ER concettuale in vista della sua ristrutturazione, sono stati presi in considerazione volumi di dati stimati sulla base di una banca reale di riferimento: Intesa Sanpaolo S.p.A.

== Tabella dei volumi 


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
  [Capo] , [Entità], [3.000],
  [Cliente] , [Entità], [15.000.000],
  [Conto] , [Entità], [12.000.000],
  [Conto Corrente] , [Entità], [10.000.000],
  [Conto Risparmio] , [Entità], [2.000.000],
  [Dipendente] , [Entità], [100.000],
  [Filiale] , [Entità], [3.000],
  [Prestito] , [Entità], [7.000.000],
  [Rata] , [Entità], [84.000.000],
  [Contiene] , [Relazione], [12.000.000],
  [Di] , [Relazione], [100.000],
  [#upper[è] associato] , [Relazione], [7.000.000],
  [#upper[è] capo] , [Relazione], [3.000],
  [#upper[è] composto] , [Relazione], [84.000.000],
  [Gestisce] , [Relazione], [10.000.000],
  [Lavora] , [Relazione], [100.000],
  [Possiede] , [Relazione], [19.000.000],
  ),
  caption: [Tabella dei volumi]
)

=== Considerazioni
Il numero di clienti, conti, dipendenti e filiali è stato stimato sulla base dei dati reali di Intesa Sanpaolo. Il numero di prestiti è ipotizzato sulla base di una proporzione realistica rispetto ai conti e un numero di rate pagate (in media 12 per prestito). Per distinguere tra conti correnti e conti di risparmio, è stata presa come riferimento la percentuale media nazionale italiana, applicandola al numero totale di conti. I volumi per le relazioni sono stati calcolati tenendo conto delle cardinalità e della natura dei legami tra le entità coinvolte, in modo da mantenere coerenza con il modello concettuale.


== Analisi delle ridondanze


=== Studio dell'attributo derivato _Attivi_ di #er[filiale]
Il primo blocco di operazioni coinvolge l'attributo derivato _Attivi_ che produce una ridondanza ed è derivabile da altre entità, nel nostro caso da #er[Conto, Prestito] e #er[Rata]. Sono state ipotizzate delle operazioni e le loro relative frequenze che vanno a coinvolgere questo attributo e osservato se è conveniente eliminarlo o mantenerlo.

==== Operazione 1 
#quote[Interrogazione per leggere il valore _Attivi_ di ogni filiale con frequenza di una volta al giorno.]

#h(1em)
*Con attributo _Attivi_: *

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
  [Filiale], [Entità], [3000], [Lettura],
  ),
  caption: [Operazione 1]
)
$ "op1: (1 lettura {Filiale})" dot 3.000 $
$ "op1 = 3000" \ $

Per leggere il valore _Attivi_ di ogni filiale, è necessario eseguire una lettura della tabella #er[Filiale] e leggere l'attributo derivato _Attivi_.

#h(1em)
*Senza attributo _Attivi_: *

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
  [Filiale], [Entità], [3000], [Lettura],
  [Contiene], [Relazione], [12.000.000], [Lettura],
  [Conto], [Entità], [12.000.000], [Lettura],
  [#upper[è] associato], [Relazione], [7.000.000], [Lettura],
  [Prestito], [Entità], [7.000.000], [Lettura],
  ),
  caption: [Operazione 1]
)

$ "op1:" ((3 "letture" {"Filiale, Contiene, Conto"} dot 4000) + (2 "letture" {"È associato", "Prestito"} dot 2333)) dot 3000 $
$ "op1 = 49.998.000" $

Senza l'attributo _Attivi_, per calcolare gli attivi di ogni filiale vengono lette le 3.000 righe della tabella #er[Filiale]. Poi, per ogni filiale, si risale ai conti che possiede: in media sono circa 4.000. Vengono poi effettuati altri 4.000 accessi alla tabella #er[Conto] per ottenere i saldi. 

Lo stesso vale per i prestiti: per ogni filiale si leggono in media 2.333 righe nella tabella _È associato_ e poi si accede a #er[Prestito] per recuperarne l'importo delle rate pagate.

In totale quindi, come si vede dalla tabella, bisognerà leggere interamente le relazioni _Contiene_, _#upper[è] associato_ e tutte le entità #er[Conto] e #er[Prestito].
#v(2em)
==== Operazione 2
#quote[Inserimento di un conto nella base di dati con frequenza 150 volte al giorno.]

#h(1em)
*Con attributo _Attivi_:*

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
  [Contiene], [Relazione], [150], [Scrittura],
  [Possiede], [Relazione], [150], [Scrittura],
  [Filiale], [Entità], [150], [Lettura],
  [Filiale], [Entità], [150], [Scrittura],
  ),
  caption: [Operazione 2]
)

$ "op2: (4 scritture{Conto, Contiene, Possiede, Filiale}" + 1 "lettura{Filiale})" dot 150 $
$ "op2 = 1350" $

Per inserire un conto bisogna scrivere in #er[Conto] e nelle due relazioni _Contiene_ e _
Possiede_, poiché un conto deve avere un cliente che lo possiede e il conto deve essere contenuto da una filiale. 
Infine bisogna leggere e scrivere in #er[Filiale] per aggiornare l'attributo _Attivi_ con il saldo del conto appena inserito. 

#h(1em)
*Senza attributo _Attivi_:*
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
  [Contiene], [Relazione], [150], [Scrittura],
  [Possiede], [Relazione], [150], [Scrittura],
  ),
  caption: [Operazione 2]
)

$ "op2: (3 scrittura{Conto, contiene, possiede})" dot 150 $
$ "op2 = 900" $

La logica è come quella vista sopra, con l'eccezione che non serve aggiornare l'attributo _Attivi_, che non è presente. 

==== Operazione 3
#quote[Inserimento di un'operazione in _Possiede_ con frequenza 1.000.000 al giorno.]

#h(1em)
*Con attributo _Attivi_: *
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
  [Possiede], [Relazione], [1.000.000], [Lettura],
  [Possiede], [Relazione], [1.000.000], [Scrittura],
  [Conto], [Entità], [1.000.000], [Lettura],
  [Conto], [Entità], [1.000.000], [Scrittura],
  [Filiale], [Entità], [1.000.000], [Lettura],
  [Filiale], [Entità], [1.000.000], [Scrittura],
  [Contiene], [Relazione], [1.000.000], [Lettura],
  ),
  caption: [Operazione 3]
)

$ "op3: (3 scrittura{Possiede, Conto, Filiale} + 4 letture{Possiede, Conto, Filiale, Contiene})" dot 1.000.000 $
$ "op3 = 10.000.000" $

Poichè la relazione _Possiede_ contiene l'attributo operazione, ogni volta che un'operazione viene eseguita bisogna aggiornare l'attributo, ciò comporta una lettura e una scrittura. Dopodiché, bisogna anche in questo caso aggiornare il saldo del conto che fa riferimento a quella tupla in possiede, dopodiché solamente leggere la relazione _contiene_ per individuare la filiale in cui quel conto ha sede e aggiornare quindi l'attributo _Attivi_ della filiale.

#h(1em)
*Senza attributo _Attivi_:*
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
  ),
  caption: [Operazione 3]
)

$ "op3: (2 scritture{Possiede, Conto} + 2 letture{Possiede, Conto})" dot 1.000.000 $
$ "op3 = 6.000.000" $

La logica è la stessa di prima, ma non serve aggiornare l'attributo _Attivi_ della filiale, quindi non serve leggere e scrivere in #er[Filiale].

==== Operazione 4
#quote[Aggiornamento di tutti i prestiti con frequenza di una volta al mese.]

#h(1em)
*Con attributo _Attivi_:*
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
  [Rata], [Entità], [233.333], [Scrittura],
  [#upper[è] composto], [Relazione], [233.333], [Lettura],
  [Prestito], [Entità], [233.333], [Lettura],
  [Prestito], [Entità], [233.333], [Scrittura],
  [#upper[è] associato], [Relazione], [233.333], [Lettura],
  [Contiene], [Relazione], [233.333], [Lettura],
  [Filiale], [Entità], [233.333], [Lettura],
  [Filiale], [Entità], [233.333], [Scrittura],
  ),
  caption: [Operazione 4]
)

$ "op4: (3 scritture{Rata, Prestito, Filiale}" + \ 5 "Letture{È composto, Prestito, È associato, Contiene, Filiale})" dot 7.000.000 dot 1/30 $
$ "op4 = 2.566.667" $

L'aggiornamento mensile delle rate comporta: la scrittura della rata che viene saldata in quel mese, bisogna poi risalire al prestito a cui essa fa riferimento tramite la relazione _È composto_, aggiornare il prestito di riferimento, dopodiché tramite la relazione _È associato_ ricavare l'IBAN del conto a cui è associato, poter quindi leggere in _Contiene_ la filiale in cui quel prestito fa riferimento e quindi operare un aggiornamento dell'attributo attivi della filiale. 

#h(1em)
*Senza attributo _attivi_:*
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

  [Rata], [Entità], [233.333], [Scrittura],
  [#upper[è] composto], [Relazione], [233.333], [Lettura],
  [Prestito], [Entità], [233.333], [Lettura],
  [Prestito], [Entità], [233.333], [Scrittura],
  ),
  caption: [Operazione 4]
)

$ "op4: (2 scritture{Rata, Prestito} + 2 Letture{È composto, Prestito})" dot 7.000.000 dot 1/30$ 
$ "op4 = 1.400.000" $

Anche in questo caso la logica rimane la stessa, ma non serve aggiornare l'attributo _Attivi_ della filiale, quindi non serve leggere e scrivere in #er[Filiale] e nelle relazioni _È associato_ e _Contiene_.
#v(1em)
$ "Totale con attributo attivi": 12.571.017 $ 
$ "Totale senza attributo attivi": 52.398.900 $ 
#v(1em)
Questa analisi ci suggerisce che la conservazione dell'attributo derivato _Attivi_ sia utile e quindi verrà mantenuto nel nostro schema ER ristrutturato. 

=== Studio dell'attributo derivato _Somma rate_ di #er[prestito]
Il secondo blocco di operazioni riguarda la ridondanza introdotta dall'attributo derivato _Somma rate_ di #er[Prestito] che misura il numero di rate che sono state pagate. Anche in questo caso si tratta di un attributo derivato secondo funzioni aggregative e le entità coinvolte sono #er[Rata] e #er[Prestito]. Possiamo considerare due operazioni (per coerenze con lo studio precedente riportiamo il numero di operazioni giornaliere):

==== Operazione 1
#quote[Inserimento di una rata una volta al mese per ogni prestito della banca.]

#h(1em)
*Con attributo _Somma rate_: *
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
  [Rata], [Entità], [7.000.000], [Scrittura],
  [Prestito], [Entità], [7.000.000], [Lettura],
  [Prestito], [Entità], [7.000.000], [Scrittura],
  [#upper[è] composto], [Relazione], [7.000.000], [Lettura],

  ),
  caption: [Operazione 1]
)

$ "op1: (2 scritture{Rata, Prestito} + 2 Letture{Prestito, è composto})" dot 7.000.000 dot 1/30 $ 
$ "op1 = 1.400.000" $

L'inserimento di una nuova rata comporta la scrittura di una istanza dell'entità #er[rata], seguito dalla lettura nella relazione _#upper[è] composto_ per risalire al prestito corrispondente.
La lettura del prestito corretto comporta poi la scrittura per aggiornare l'attributo _Somma rate_.

#h(1em)
*Senza attributo _Somma rate_:* 

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
  [Rata], [Entità], [7.000.000], [Scrittura],
  ),
  caption: [Operazione 1]
)

$ "op1: (1 scrittura{Rata})" dot 7.000.000 dot 1/30 $ 
$ "op1 = 233.333" $

In questo caso l'operazione di inserimento di una rata comporta semplicemente la scrittura della rata, senza la necessità di leggere il prestito per aggiornare l'attributo somma rate.


==== Operazione 2
#quote[Lettura del valore della somma delle rate pagate per ogni prestito con frequenza semestrale.]

Per questa analisi è stata introdotta un'ulteriore ipotesi, ovvero il numero medio di rate saldate presenti nella nostra base di dati per ogni prestito. Questo numero è stato supposto essere 12, che equivale ad un anno di rate pagate.

#h(1em)
*Con attributo _Somma rate_: *

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
  [Prestito], [Entità], [7.000.000], [Lettura],
  ),
  caption: [Operazione 2]
)

$ "op2: (1 lettura{Prestito})" dot 7.000.000 dot 1/180 $ 
$ "op2 = 38.889" $

In questo caso è necessaria una semplice lettura dell'attributo dal prestito corretto, senza la necessità di leggere ogni rata ad esso associata.

#h(1em)
*Senza attributo _Somma rate_:* 

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
  [Prestito], [Entità], [7.000.000], [Lettura],
  [È composto], [Relazione], [84.000.000], [Lettura],
  [Rata], [Entità], [84.000.000], [Lettura],
  ),
  caption: [Operazione 2]
)

$ "op2: (1 lettura{Prestito} + 12" dot 2 "letture{Rata, È composto}") dot 7.000.000 dot 1/180 $
$ "op2 = 972.222" $

Senza l'attributo ridondante oltre alla lettura del prestito corretto bisogna leggere anche nella relazione _è associato_ per ottenere tutte le rate associate al mio prestito.
Tra le rate associate mediamente 12 sono state pagate, è da aggiungere quindi una media di ulteriori 12 letture per risalire all'ammontare effettivo già pagato.
#v(1em)
$ "Totale con ridondanza di Somma rate: " 1.438.889 $
  
$ "Totale senza ridondanza di Somma rate: " 1.205.555 $
#v(1em)

Per questa ridondanza la conclusione è quindi che l'attributo somma rate possa essere rimosso e non essere utilizzato nello schema ER ristrutturato.


== Selezione delle chiavi primarie
In #er[Cliente] è stato scelto come chiave primaria l'attributo _ID_ rispetto a _Codice Fiscale_ per mantenere una linearità con #er[DIPENDENTE] il quale è identificato a sua volta da un codice univoco.
In tutti gli altri casi la chiave candidata a essere primaria era unica.

== Rimozione delle specializzazioni
Per le analisi fatte in precedenza, il blocco #er[Capo-]_Di_#er[-Dipendente] può essere "compresso", riducendo la complessità visiva e pratica del problema, eliminando la specializzazione #er[Capo] e la relativa relazione #err[Di], sostituendo il tutto con un nuovo attributo derivato posto nell'entità #er[Dipendente]: _Capo_.
Di conseguenza viene anche cambiato il riferimento della relazione #er[è capo] che non farà più riferimento all'entità #er[capo] in quanto è stata eliminata ma bensì a #er[Dipendente] richiedendo un cambio di cardinalità dal lato di #er[dipendente].

Non c'è perdita di informazione in quanto il nuovo attributo _Capo_ viene ricavato dalle relazioni #er[Lavora] ed #er[è capo].
Per ricavare il capo di un certo dipendente si va andare a vedere la filiale in cui lavora (che è unica per le cardinalità della relazione), tale filiale sarà gestita da uno e un solo capo (deducibile dalle cardinalità della relazione _è capo_).
Si può quindi, in maniera univoca, ricavare il capo di un certo dipendente passando attraverso le relazioni e salvare il dato di interesse nell'attributo _Capo_.

Successivamente la specializzazione di #er[CONTO] è stata ristrutturata aggiungendo due nuove relazioni: #err[Tipo-Corrente] e #err[Tipo-Risparmio] che legano rispettivamente le entità #er[CORRENTE] e #er[RISPARMIO] a #er[conto].



Gli attributi delle tre entità coinvolte nella specializzazione sono rimasti invariati.
Le cardinalità delle due nuove relazioni sono (0,1) dal lato di #er[conto]. Dal lato di #er[CORRENTE] e #er[RISPARMIO] sono (1,1) in quanto i due tipi di conto sono associati a uno e un solo conto. 

Questa scelta non permette di catturare tutti i requisiti su conto, il quale deve essere esclusivamente un conto corrente o un conto di risparmio. Ciò va tenuto in considerazione aggiungendolo ai vincoli di integrità. 

Le chiavi primarie di #er[CORRENTE] e di #er[RISPARMIO] sono delle chiavi primarie legate alla relazione con #er[conto], ne ereditano quindi la chiave primaria _IBAN_.
Da notare il fatto che l'insieme degli _IBAN_ di #er[CORRENTE] deve essere disgiunto dall'insieme degli _IBAN_ di #er[RISPARMIO] (non esiste un conto che è sia corrente che di risparmio in quanto la specializzazione originariamente era disgiunta).


== Schema ER ristrutturato 
#figure(
  image("media/flowchart-ER-ristrutturato-v2.svg", width: 120%),
  caption: [Schema ER ristrutturato]
)

== Schema Logico 

#erb[CLIENTE] (#u[ID], CF, Residenza, DataDiNascita, Telefono, Cognome, Nome, _Gestore_)
- _CF_: UNIQUE

#erb[CONTO] (#u[_IBAN_], Saldo, _Filiale_)
- _FilialeAppartenenza_: NOT NULL

#erb[CONTO_CORRENTE] (#u[_IBAN_], Scoperto)
- _IBAN_: UNIQUE

#erb[CONTO_RISPARMIO] (#u[_IBAN_], TassoInteresse)
- _IBAN_: UNIQUE

#erb[POSSIEDE] (#u[_Cliente_, _Conto_], Operazione, Data)

#erb[PRESTITO] (#u[Codice], Ammontare, Inizio, Mensilità, _ContoAssociato_)
- _ContoAssociato_: NOT NULL

#erb[RATA] (#u[Numero, _CodicePrestito_], Ammontare, DataPagamento, DataScadenza)
- _CodicePrestito_: NOT NULL

#erb[FILIALE] (#u[Nome], Città, Attivi (derivato), Indirizzo, _Capo_)
- _Capo_: NOT NULL

#erb[DIPENDENTE] (#u[ID], Nome, Cognome, Telefono, DataAssunzione, _Capo_ (derivato), _Filiale_)
- _Filiale_: NOT NULL
- _Capo_: NOT NULL

Legenda: Le chiavi primarie sono sottolineate e le chiavi esterne sono in corsivo.

La traduzione delle relazioni è stata fatta secondo i canoni standard seguendo le cardinalità di esse. 

=== Chiavi esterne
- _Gestore_ è chiave esterna di #er[cliente] rispetto a #er[DIPENDENTE]

- _Filiale_ è chiave esterna di #er[conto] rispetto a #er[filiale]
- _IBAN_ è chiave esterna di #er[conto corrente, conto risparmio] rispetto a #er[conto]
- _Conto_ chiave esterna di #er[possiede] rispetto a #er[CONTO]
- _Cliente_ è chiave esterna di #er[possiede] rispetto a #er[cliente]
- _ContoAssociato_ è chiave esterna di #er[prestito] rispetto a CONTO
- _Capo_ è chiave esterna di #er[filiale] rispetto a #er[DIPENDENTE]
- _CodicePrestito_ è chiave esterna di #er[rata] rispetto a #er[PRESTITO]
- _Capo_ è chiave esterna di #er[dipendente] rispetto a DIPENDENTE


#pagebreak()

= Popolamento del database

== Creazione delle tabelle
Per ogni entità è stata creata una tabella nello schema fisico dove gli attributi dell'entità corrispondono ai campi della tabella. I campi della tabella sono stati opportunamente dichiarati in base al tipo di dato e aggiunti eventuali controlli sul loro valore per avere coerenza logica con quanto richiesto tramite l'utilizzo della condizione `CHECK()`.

Campi particolari che richiedevano di essere ad esempio chiave primaria, unici, o non nulli sono stati settati tramite gli appositi comandi.

Le tabelle sono state create in un ordine preciso; in particolare i vincoli di chiave esterna sono stati aggiunti solo quando tutte le tabelle coinvolte erano esistenti. 

La tabella possiede è stata creata in quanto corrisponde alla relazione molti a molti tra l'entità #er[conto] e l'entità #er[cliente].


== Modalità di generazione dei dati
Riportiamo di seguito la tabella dei volumi debitamente proporzionata sulla quale il nostro database è stato creato.

#figure(
  table(
    columns: 2, 
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#ddd") },
    align: (x, y) =>
      if y == 0 { center } else {
        if x < 1 { center + horizon } else { left }
      },
  table.header([Nome], [Volume]),
  [Cliente], [30.000],
  [Conto] , [24.000],
  [Conto Corrente], [20.000],
  [Conto Risparmio] , [4.000],
  [Dipendente] , [200],
  [Filiale] , [6],
  [Prestito] , [14.000],
  [Rata\*], [1.764.000],
  [Possiede], [38.000],
  ),
  caption: [Tabella dei volumi proporzionata]
)

\* 1.764.000 include tutte le rate, pagate e non, con una media di 126 rate per prestito (prestiti tra 12 e 240 rate).

=== Dati #er[filiale]
Questi dati non richiedevano particolari attenzioni poiché non soggetti a nessun tipo di vincolo particolare. Per comodità è stato scelto di nominare le filiali con numeri interi crescenti, e per la logica di popolamento e vincoli di cardinalità, per ogni record di filiale, il codice del suo manager è pari al suo nome. 

=== Dati #er[dipendente]
I dipendenti sono composti da dati che per ciò che concerne gli attributi _Nome, Cognome, Data di assunzione, Telefono_ sono stati generati e assegnati casualmente, mentre più delicato è il nome (numero) di filiale che per i primi 6 dipendenti è stato assegnato progressivamente per mantenere la logica dei dati di #er[Filiale] mentre per i restanti in maniera casuale, inoltre il campo _Capo_ è stato inizializzato a -1 per poi essere assegnato correttamente durante il popolamento.

Solo i primi 100 dipendenti sono gestori. 

=== Dati #er[cliente]
Il campo _Gestore_ è il più delicato. I clienti con _ID_ da 1 a 4.000 e da 24.001 a 28.000 hanno nell'ordine lo stesso gestore (il cliente con _ID_ = 1 ha lo stesso gestore del cliente con _ID_ = 24.001, quello con _ID_ = 2 ha lo stesso gestore del cliente con _ID_ = 24.002 e così via). I clienti con _ID_ da 4001 a 16.000 hanno un gestore (eventualmente ripetuto) e i rimanenti ne sono privi. 

=== Dati #er[conto]

Per assegnare gli _IBAN_ in maniera coerente, i primi 20.000 sono stati assegnati ai conti correnti, i restanti 4.000 ai conti di risparmio. 

=== Dati #er[possiede]

Per garantire la coerenza e i vincoli di integrità, i primi 4.000 _IBAN_ sono stati assegnati ai primi 4.000 clienti cointestati con i clienti con _ID_ compreso tra 24.001 e 28.000, in maniera tale da rispettare il vincolo sui gestori (entrambi hanno lo stesso gestore). \
I successivi 2.000 _IBAN_ sono cointestati ma solo uno dei clienti ha il gestore. \
I restanti _IBAN_ hanno un unico proprietario, alcuni con gestore e altri senza.




== Creazione dei trigger

Sono stati creati dei trigger per gestire le problematicità tra dipendente e filiale che non è stato possibile catturare con i vincoli tramite lo schema relazionale.

=== Trigger #er[filiale-dipendente]

Il manager di una filiale deve fare riferimento alla filiale che gestisce, pertanto non deve essere possibile cambiare la filiale di un manager. Il trigger controlla che su ogni inserimento o modifica nella tabella dipendente venga rispettato il vincolo appena descritto, sollevando un'eccezione in caso di problemi e bloccando di conseguenza l'inserimento o la modifica.

Un altro trigger simile controlla che una volta assegnato il manager in una filiale esso lavori effettivamente in quella filiale. 


=== Trigger #er[filiale-conto-prestito-rata]
La creazione delle rate di un prestito è stata gestita in modo automatico da un trigger il quale dopo l'inserimento di un prestito, calcola l'importo mensile di ogni rata in base all'ammontare e il numero di mensilità, creando le rate (tutte con lo stesso importo mensile) e mettendo la data di scadenza in modo coerente e sequenziale.

Un altro trigger controlla la possibilità di poter pagare una rata bloccando l'aggiornamento in caso la rata fosse già stata pagata. In caso di pagamento concesso, il trigger si occupa anche di aggiornare gli attivi della filiale corrispondente.

In modo analogo un altro trigger aggiorna gli attivi della filiale ogni volta che un nuovo prestito viene creato.


=== Trigger #er[possiede-conto-filiale]
Il calcolo degli attivi, analogamente a quanto avviene per prestiti e rate, viene fatto in automatico da un trigger ogni volta che è aggiornato il saldo di un conto.

Per le scelte fatte nessun IBAN in conto corrente deve comparire in conto di risparmio e viceversa ma tutti gli IBAN di #er[conto corrente] e di #er[conto risparmio] devono comparire in #er[conto], tale vincolo viene fatto rispettare da due opportuni trigger.

La coerenza delle operazioni eseguibili su un determinato conto anch'essa è verificata da due appositi trigger. Viene controllato che l'operazione sia sensata sul conto (non posso aprire un conto due volte e non posso fare operazioni sul conto di risparmio) e in caso di prelievo un trigger si occupa di verificare il saldo rimanente e di aggiornarlo.



== Inserimento tabelle e dati nel database
Per creare il database richiesto, popolarlo e testare le query assegnate è stata seguita una particolare logica affinché tutto venisse inserito correttamente.

Per prima cosa è stato creato il database, assegnando i volumi dei dati in base alla _Tabella 15_. /* link */

Vengono poi caricati nel sistema tutti i trigger utilizzati e temporaneamente disabilitati per possibili inconsistenze momentanee nell'inserimento dei dati. La modalità di generazione casuale dei dati è stata pensata in modo tale che, al termine degli inserimenti iniziali, tutto sia coerente e non ci siano errori.

Le prime tabelle popolate sono #er[filiale] e #er[dipendente]. Al termine del popolamento vengono eseguiti forzatamente due trigger in maniera tale da assegnare automaticamente i manager (che non erano stati inseriti) e verificare la presenza di eventuali errori (di base i dati sono stati generati consistentemente).

Successivamente vengono create le tabelle #er[cliente] e #er[conto] con le relative #er[conto corrente] e #er[Conto di risparmio]. Una volta inseriti questi dati è possibile procedere al popolamento della tabella #er[possiede] che gestisce tutte le connessioni tra i clienti e i loro conti.

Una volta generata #er[prestiti] (e le relative rate tramite trigger) viene innescato il trigger per pagare le rate con data di scadenza antecedente a quella odierna. Riattivando tutti i trigger, il sistema provvede a calcolare gli attivi delle filiali. 

I vincoli di integrità (vedi sezione 2.5), che non sono stati catturati dallo schema Entità-Relazione, vengono fatti rispettare dai trigger appena descritti. 

== Test 
Una volta finito di popolare tutto il database, tramite dei test, viene verificata la correttezza dei trigger su alcuni casi sensibili, in modo tale che vengano rispettati i requisiti che sono stati imposti e che vengano restituiti i risultati attesi.

== Test Dipendente-Filiale

+	Tentativo di modifica della filiale di riferimento di un manager senza aggiornare il ruolo di manager. Il trigger vieta l'inserimento (un dipendente non può lavorare nella filiale #er[A] ed essere manager della filiale #er[B]).

+	Simile al precedente, assegnamento del ruolo di manager di una filiale a un dipendente che lavora presso una filiale diversa. Il trigger blocca l'azione e restituisce l'errore (la modifica non viene effettuata).

+	Inserimento di un nuovo dipendente: non è necessario specificare il campo manager in quanto il trigger apposito si occupa di ricercare l'ID del manager nella filiale dove lavora e assegnare il campo corrispondente.

+ Come il caso (3) ma con l'aggiunta che questo dipendente diventi manager della filiale in cui lavora. Il trigger che viene innescato sulla modifica del campo manager (che passa da -1 [non manager] a un ID di filiale valido) provvede ad aggiornare il campo manager di tutti i dipendenti che lavorano nella filiale dove è appena stato modificato il manager.

+	Semplice operazione di rimozione di un dipendente che non è manager.


== Test Prestito-Rata

+	Inseriamento di un nuovo prestito. Le rate relative verranno generate in maniera automatica dal trigger che si occupa di andare a recuperare il valore di _Mensilità_ e generare altrettanti record nella tabella #er[rata] riempiendo in maniera adeguata tutti i campi.

+	Modifica della data di pagamento di una rata, portandola da NULL a una data valida. Il controllo del trigger sarà di verificare che non ci siano rate precedenti ancora da pagare.


== Test Conto-Filiale

+	Viene simuliato un versamento e un prelievo, quindi la modifica del valore del saldo dei conti. I trigger controllano (solo nel secondo caso) che il prelievo possa essere effettuato (quindi che il saldo sia maggiore dello scoperto). In entrambi i casi vengono automaticamente aggiornati gli attivi delle filiali. Lo scopo del test è quello di verificare che il saldo venga correttamente modificato.

+	Viene testato il trigger che controlla la validità dei saldi funzioni, forzando la modifica di un saldo a un valore non valido. 

+	Simile al primo test con il focus sull'aggiornamento degli attivi della filiale di riferimento.

+	Inserimento di un IBAN valido nella tabella #er[conto] (necessario per i vincoli di chiave esterna) e poi nella tabella #er[Conto Corrente]. Ciò non genera problemi. Inserendo l'IBAN anche in #er[Conto Risparmio], il trigger vieta tale operazione e, dato che siamo all'interno di una transazione, tutti e tre gli inserimenti vengono rimossi (rollback).

+ Test di consistenza di gestori diversi su conti cointestati.

#pagebreak()

= Query 
Dopo aver verificato il corretto funzionamento del database e dei trigger con i test sopra esposti, sono state sviluppate e testate le query richieste. 

== Query 1
#emph[#quote[Restituire il numero medio di rate dei prestiti associati a conti nelle filiali di Udine.]]

#zebraw(
  header: [Query 1], 
```sql
SELECT AVG(mensilità) AS media_rate
  FROM prestito, conto, filiale
  WHERE prestito.conto = conto.iban
    AND conto.filiale = filiale.nome
    AND filiale.città = 'Udine';
```
)
La richiesta è immediata con l'utilizzo della funzione aggregata `AVG()`.

== Query 2:	
#emph[#quote[Restituire i clienti con solo conti di risparmio in filiali che hanno tra i 30 e i 32 dipendenti.]]

#zebraw(
header: [Query 2], 
```sql
CREATE OR REPLACE VIEW filiali_3032 AS
  SELECT filiale, COUNT(*) AS n_dip
  FROM dipendente
  GROUP BY filiale
  HAVING COUNT(*) BETWEEN 30 AND 32;

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
```
)

Per comodità è stata creata una vista dove è stata fatta una selezione sulla tabella #er[filiale], tenendo solamente quelle che rispettavano il vincolo sul numero dei dipendenti.\
La query sfrutta questa vista per cercare i clienti che hanno almeno un conto di risparmio in queste filiali e che non hanno nessun conto corrente associato.

#pagebreak()

== Query 3: 

#emph[#quote[Restituire i capi che gestiscono almeno 3 clienti che possiedono almeno 100.000€.]]

#zebraw(
header: [Query 2], 
```sql
CREATE OR REPLACE VIEW clienti_ricchi AS
  SELECT cliente.id, SUM(conto.saldo) AS soldi, cliente.gestore
  FROM cliente, possiede, conto
  WHERE cliente.id = possiede.cliente
    AND conto.iban = possiede.conto
  GROUP BY cliente.id, cliente.gestore
  HAVING SUM(conto.saldo) > 100000;

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
```
)

La vista creata è una restrizione sui clienti che rispettano il vincolo. È stata effettuata con l'utilizzo della funzione `SUM()` poiché il saldo era relativo a tutti i conti posseduti.
Per validare un capo è stato fatto il prodotto cartesiano triplo della vista e, dopo essere state selezionati solamente le righe con gestore uguale, è stato controllato che i clienti fossero tutti e tre diversi.

#v(1em)
== Query 4:

#emph[#quote[Restituire i dipendenti non capo che gestiscono esattamente 2 clienti, uno con solo conti correnti e uno con solo conti di risparmio.]]

#zebraw(
  header: [Query 4],
```sql
CREATE OR REPLACE VIEW clienti_correnti AS
  SELECT possiede.cliente, cliente.gestore
  FROM possiede, cliente
  WHERE possiede.cliente = cliente.id
    AND NOT EXISTS (
      SELECT 1
      FROM contorisparmio
      WHERE contorisparmio.iban = possiede.conto
    );

  CREATE OR REPLACE VIEW clienti_risparmio AS
  SELECT possiede.cliente, cliente.gestore
  FROM possiede, cliente
  WHERE possiede.cliente = cliente.id
    AND NOT EXISTS (
      SELECT 1
      FROM contocorrente
      WHERE contocorrente.iban = possiede.conto
    );

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
```
)

La prima (seconda) vista seleziona solamente i clienti che hanno almeno un conto corrente (di risparmio) e che non hanno nessun conto di risparmio (corrente).
La query seleziona i dipendenti non capo (con la verifica _ID_ <> _Capo_) e poi controlla che esista un unico cliente nella prima vista e un unico cliente nella seconda vista.
#v(1em)
== Query 5: 
#emph[#quote[Restituire il cliente con il prestito più alto nella filiale di Roma che non ha come gestore un dipendente con meno di 3 anni di esperienza.]]


#zebraw(
  header: [Query 5],  
```sql
 CREATE OR REPLACE VIEW clienti_gestiti_3 AS
  SELECT cliente.id
  FROM cliente, dipendente
  WHERE cliente.gestore = dipendente.id
    AND dipendente.data_assunzione < DATE '", data_limite, "';

 CREATE OR REPLACE VIEW candidati AS
  SELECT cliente.id, prestito.ammontare
  FROM cliente, clienti_gestiti_3, possiede, prestito, conto, filiale
  WHERE cliente.id = clienti_gestiti_3.id
    AND cliente.id = possiede.cliente
    AND possiede.conto = prestito.conto
    AND prestito.conto = conto.iban
    AND conto.filiale = filiale.nome
    AND filiale.città = 'Roma';

  SELECT id, ammontare
  FROM candidati c1
  WHERE NOT EXISTS (
    SELECT 1
    FROM candidati c2
    WHERE c2.ammontare > c1.ammontare
  );
```
)

La prima vista restringe i possibili clienti a quelli che hanno un gestore assunto da almeno 3 anni.
La seconda vista, a partire dalla prima, fa un ulteriore filtro prendendo i clienti solo della filiale di Roma.
La query si occupa di verificare, per ogni cliente, che tra i clienti della seconda vista non ce ne sia qualcuno con saldo maggiore del proprio, in tal caso seleziona il cliente.

#pagebreak()

= Analisi dei dati

Di seguito sono descritte le analisi eseguite sul database, per estrarre informazioni riguardanti i clienti, i loro conti, i prestiti e le rate pagate.

È importante sottolineare che, in quanto i dati sono stati generati in modo casuale, le tendenze, correlazioni e distribuzioni osservate non riflettono necessariamente situazioni reali.
La tendenza è quella di una distribuzione uniforme in tutti i campi, come si potrà notare dai grafici.

== Distribuzione dei prestiti per mensilità

Viene esaminata la distribuzione delle mensilità dei prestiti associati a conti con saldo superiore a 50.000€ gestiti da un gestore. 

#zebraw(
  header: [Query],  
```sql
  CREATE OR REPLACE VIEW clienti_gestiti AS
  SELECT cliente.id, cliente.gestore
  FROM cliente, dipendente
    WHERE cliente.gestore = dipendente.id;    

  SELECT mensilità, COUNT(*)
    FROM clienti_gestiti, possiede, conto, prestito
    WHERE clienti_gestiti.id = possiede.cliente
    AND possiede.conto = conto.iban
    AND conto.saldo > 50.000
    AND possiede.conto = prestito.conto
    GROUP BY mensilità
```
)

Per estrarre i dati è stata inizialmente creata una vista che contiene i clienti gestiti da un gestore. Viene poi eseguita una query che conta il numero di prestiti per ogni mensilità, filtrando i clienti con saldo maggiore di 50.000€.

#v(-1em)
#figure(
  image("media/grafico1.png", width: 90%),
  caption: [Distribuzione dei prestiti per mensilità]
)
Per la visualizzazione dei dati è stato creato un istogramma che mostra la frequenza delle mensilità, garantendo la migliore leggibilità dei dati estratti. 

== Analisi attivi per anzianità gestori

L'obiettivo è analizzare la relazione tra l'anzianità dei gestori (ricavata dalla data di assunzione) e l'ammontare totale dei conti gestiti.

#zebraw(
  header: [Query],
```sql
CREATE OR REPLACE VIEW dipendenti_gestori AS
SELECT dipendente.data_assunzione, dipendente.id
FROM cliente, dipendente
WHERE cliente.gestore = dipendente.id;

SELECT SUM(conto.saldo) as skey, dipendenti_gestori.data_assunzione 
  FROM clienti_gestiti, possiede, conto, dipendenti_gestori
  WHERE clienti_gestiti.id = possiede.cliente
  AND possiede.conto = conto.iban
  AND dipendenti_gestori.id = clienti_gestiti.gestore 
  GROUP BY dipendenti_gestori.data_assunzione
```
)

Viene creata una vista che contiene i gestori e la loro data di assunzione. La query finale calcola la somma dei saldi dei conti gestiti da ciascun gestore, raggruppando i risultati per data di assunzione.
I dati vengono visualizzati in un grafico a dispersione che rende chiaro il legame tra anzianità dei gestori e conti a loro assegnati. 

#figure(
  image("media/grafico2.png", width: 90%),
  caption: [Analisi attivi per anzianità gestori]
)


== Analisi conti cointestati
L'obiettivo è determinare il numero di conti cointestati che hanno un prestito associato, raggruppandoli per filiale. 

#zebraw(
  header: [Query],
```sql
 CREATE VIEW conti_cointestati AS
  SELECT p1.conto, conto.filiale
  FROM possiede AS p1, conto
  WHERE p1.conto = conto.iban AND EXISTS (
    SELECT *
    FROM possiede AS p2
    WHERE p1.conto = p2.conto AND p1.cliente < p2.cliente)

  SELECT filiale, COUNT(*) AS n_conti
    FROM conti_cointestati, prestito
    WHERE conti_cointestati.conto = prestito.conto
    AND ammontare > 50.000
    GROUP BY filiale
```
)

La vista `conti_cointestati` contiene i conti cointestati, raggruppati per filiale. 
La query finale conta il numero di conti cointestati con prestiti associati, filtrando per ammontare maggiore di 50.000€. 
I risultati vengono visualizzati in un grafico a barre, che mostra il numero di conti cointestati con prestito per filiale.
#figure(
  image("media/grafico3.png", width: 90%),
  caption: [Analisi conti cointestati]
)



= Conclusioni

L'analisi dei requisiti ha evidenziato quanto sia complesso ottenere una documentazione completa, priva di ambiguità e internamente coerente. Alcuni requisiti sono risultati immediatamente deducibili, altri sono stati definiti manualmente, mentre altri ancora sono emersi gradualmente, poiché inizialmente non considerati.

Le fasi di progettazione concettuale e logica hanno sottolineato l'importanza di distinguere tra entità e attributi e di definire relazioni e molteplicità in modo accurato, basandosi sui vincoli presenti. 
Ciò che non è stato catturato dallo schema ER (vincoli di integrità) è stato documentato per implementare dei trigger nella progettazione fisica.

Gran parte del lavoro ha riguardato la generazione dei dati, con l'obiettivo di mantenere la coerenza interna e il rispetto dei vincoli imposti, oltre al popolamento del database tramite R.
Per la creazione del database e delle tabelle è stato fondamentale l'ordine di generazione e l'assegnazione di chiavi primarie e/o esterne.

Per verificare il corretto funzionamento del database, sono stati condotti dei test mirati a casi specifici: per controllare la corretta attivazione dei trigger, il rispetto dei vincoli di integrità e l'aggiornamento automatico di attributi derivati.

Le query hanno evidenziato la potenza di SQL, rendendo evidente ciò che avviene a basso livello durante un'interrogazione al database. 
I grafici finali sfruttano la potenzialità del linguaggio SQL per analizzare dati che, tramite funzioni di R, sarebbero stati recuperati in maniera più complessa. \

In conclusione, questo progetto ha rappresentato un'opportunità per applicare concretamente le competenza teoriche e pratiche acquisite durante il corso, permettendo allo stesso tempo di approfondirne di nuove. 


