/* ------------ Libraries ------------- */
// #import "@preview/wrap-it:0.1.0": wrap-content
#import "@preview/zebraw:0.5.2": *

/* ------------ Document Setup ------------- */
#set heading(numbering: "1.")
#set text(lang: "it")
#set page(numbering: "1")
#set quote(block: true)
#set par(justify: true)
#show heading.where(level: 1): set text(20pt)
#show heading.where(level: 2): set text(15pt)
#show heading.where(level: 3): set text(12pt)
#show heading: set block(below: 1.5em)
#show figure.caption: it => [
 #text(9pt)[ 
 #it.supplement
 #context it.counter.display(it.numbering)]:
 #emph[#it.body]
]
#show outline.entry.where(level: 1): set text(weight: "bold", size: 13pt)
#show outline.entry.where(level: 1): set block(above: 1.5em)

// Code Blocks styling
 #show: zebraw-init.with(numbering: false)


/* ------------ Variables ------------- */
#let title = text(25pt)[Relazione progetto di Laboratorio]
#let subtitle = text(20pt)[Corso di Basi di Dati]
#let date = text(15pt)[Università degli studi di Udine, A.A. 2024-2025]
#let er(text) = upper(emph(text))
#let erb(text) = upper(emph(strong(text)))
#let figure-r(..args) = {
  show figure: set align(right)
  figure(..args)
}
#let u(text) = underline(offset: 0.2em, stroke: 1pt, text)



/* ------------ Document Starts Here ------------- */

#align(center, text(25pt)[
  #v(15%)
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
  #text(17pt)[#strong()[#upper[Progettazione e implementazione \ di una base di dati per la gestione di una banca]]]
  #v(2em)
]
#pagebreak()

/* ------------Outline------------- */

#outline(
  indent: 2.5em, title: "Indice",
  // target: selector.or(heading, figure.where(kind:table))
  )


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
  La banca è organizzata in un certo numero di filiali. Ogni filiale si trova in una determinata città ed è identificata univocamente da un nome (si noti che in una città vi possono essere più filiali). La banca tiene traccia dei risultati (attivi) conseguiti da ciascuna filiale. \
  Ai clienti della banca è assegnato un codice che li identifica univocamente. La banca tiene traccia del nome del cliente e della sua residenza. I clienti possono possedere uno o più conti e possono chiedere prestiti. A un cliente può essere associato un particolare dipendente della banca, che segue personalmente tutte le pratiche del cliente (si tenga presente che non tutti i clienti godono di tale privilegio e che ad un dipendente della banca possono essere associati zero, uno o più clienti). \ 
  I dipendenti della banca sono identificati da un codice. La banca memorizza nome e recapito telefonico di ogni dipendente, il nome delle persone a suo carico e il codice dell'eventuale capo. La banca tiene inoltre traccia della data di assunzione di ciascun dipendente e dell'anzianità aziendale di ciascun dipendente (da quanto tempo tale dipendente lavora per la banca). \
  La banca offre due tipi di conto: conto corrente (con la possibilità di emettere assegni, ma senza interessi) e conto di risparmio (senza la possibilità di emettere assegni, ma con interessi). Un conto può essere posseduto congiuntamente da più clienti e un cliente può possedere più conti. Ogni conto è caratterizzato da un numero che lo identifica univocamente. Per ogni conto, la banca tiene traccia del saldo corrente e della data dell'ultima operazione eseguita da ciascuno dei possessori (un'operazione può essere eseguita congiuntamente da più possessori). Ogni conto di risparmio è caratterizzado da un tasso di interesse, mentre ogni conto corrente è caratterizzato da uno scoperto accordato al cliente. \
  Un prestito (ad esempio, un mutuo) viene emesso da una specifica filiale e può essere attribuito a uno o più clienti congiuntamente. Ogni prestito è identificato univocamente da un codice numerico. Ogni prestito è caratterizzato da un ammontare e da un insieme di rate per la restutuzione del prestito. Ogni rata di un dato prestito è contraddistinta da un numero d'ordine (prima rata, seconda rata...). Di ogni rata vengono memorizzati anche la data e l'ammontare. \
]


== Analisi dei Requisiti
=== Assunzioni
Al fine di proseguire con la progettazione concettuale, sono state effettuate le seguenti assunzioni:

- Gli *attivi* sono la somma della liquidità dei conti meno la somma dei prestiti erogati. Sono relativi alla singola filiale.
- Un *cliente* può avere conti in filiali diverse e ogni conto è associato ad una singola filiale. 
- I *prestiti* sono legati al conto, non al cliente.
- Un *dipendente* non può gestire se stesso.
- Un *dipendente* lavora in una sola filiale con la possibilità di gestire clienti al di fuori della propria filiale.
- Il *capo* di un dipendente è l'unico responsabile della filiale in cui il dipendente lavora.
- Nei *conti cointestati* i clienti non possono essere seguiti da dipendenti (gestori) diversi.
- In caso di *ri-assunzione* di un dipendente, si tiene conto solo dell'ultima assunzione per il calcolo dell'anzianità.
- Tutte le *rate* di un determinato prestito hanno lo stesso ammontare e devono essere pagate in ordine. 





=== Glossario
Per chiarire il significato e le relazioni dei termini chiave definite nei requisiti viene fornito un glossario esplicativo: 

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
  [Conto], [Servizio di gestione del denaro che permette diverse operazioni. Può essere esclusivamente corrente o di risparmio.], 
  [Conto Corrente], [Tipo di conto caratterizzato da uno scoperto.],
  [Conto di risparmio], [Tipo di conto caratterizzato da un tasso di interesse.],
  [Dipendente], [Persona fisica che lavora in una certa filiale della banca.],
  [Gestore], [Dipendente che prende in carico le pratiche di uno o più clienti.],
  [Operazione], [Transazioni bancarie effettuate su un conto da uno o più intestatari. Sono operazioni l'apertura di un conto, il prelievo, il pagamento elettronico (bancomat) e il versamento.],
  [Prestito], [Somma di denaro concessa alla banca a un cliente.],
  ),
  caption: [Glossario dei termini chiave]
)

#pagebreak()

= Progettazione Concettuale
== Costruzione dello schema Entità Relazione
L'analisi dei requisiti ha portato alla definizione di un insieme di entità e relazioni che costituiranno il modello concettuale della base di dati.

#v(1em)

- L'entità #erb[filiale] rappresenta una unità operativa della banca situata in una determinata città. La chiave primaria è il _Nome_, mentre gli altri attributi sono _Città_ e _Indirizzo_.  Inoltre, per ogni filiale è presente l'attributo derivato _Attivi_, che rappresenta l'ammontare totale della liquidità della filiale e viene calcolato sulla base dei conti, prestiti e rate ad esso associati.
#figure(
  image("media/filiale.svg", width: 22%),
  caption: [Entità FILIALE]
)
#v(2.5em)

- L'entità #erb[Cliente] rappresenta una persona fisica che ha aperto nella banca almeno un conto. Essa è caratterizzata da un _codice univoco_ assegnato dalla banca ad ogni cliente e dal _codice fiscale_, entrambi questi attributi possono essere due chiavi primarie differenti in quanto sono univoche per ogni cliente. Gli altri attributi servono per tenere traccia dell'anagrafica del cliente: _Nome_, _Cognome_, _Telefono_, _Data di nascita_ e _Residenza_.
#v(-1em)
#figure(
  image("media/cliente.svg", width: 30%),
  caption: [Entità CLIENTE]
)
#v(2.5em)

- L'entità #erb[dipendente] è caratterizzata da un codice univoco _ID_ che funge da chiave primaria. _Nome_, _Cognome_, _Numero di telefono_, _Data di assunzione_ sono gli altri attributi che la descrivono. È stato scelto di tenere traccia dell'anzianità aziendale sulla base della data di assunzione. \ La qualifica di capo viene descritta da una specializzazione parziale di #er[dipendente], chiamata #er[capo]. 
#v(-0.7em)
#figure(
  image("media/dipendente.svg", width: 30%),
  caption: [Entità DIPENDENTE]
)
#v(2.5em)

- L'entità #erb[Capo] rappresenta il capo di una filiale. Essendo una specializzazione dell'entità #er[dipendente], eredita tutti gli attributi di quest'ultima. Un capo è univoco per ogni filiale. 
#figure(
  image("media/capo.svg", width: 16%),
  caption: [Entità CAPO]
)
#v(2.5em)

- L'entità #erb[Conto] serve per identificare un servizio della banca messo a disposizione per il cliente. Ogni entità viene identificata univocamente da un attributo _IBAN_, un attributo _Saldo_ tiene traccia dell'ammontare di denaro presente sul conto. La banca inoltre mette a disposizione due tipi di conto, quindi l'entità Conto è stata specializzata in due sottoentità: #er[Conto Corrente] e #er[Conto di Risparmio]. La specializzazione è totale e disgiunta.

  - L'entità #erb[Conto Corrente] è una specializzazione dell'entità #er[conto] pertanto ne eredita tutti gli attributi e tutte le relazioni, la chiave primaria è quindi quella dell'entità #er[Conto]. L'attributo che lo caratterizza è _Scoperto_ che indica quanto la banca può concedere di debito nei confronti del cliente.

  - L'entità #erb[Conto di Risparmio] è una specializzazione dell'entità #er[conto] pertanto ne eredita tutti gli attributi e tutte le relazioni, la chiave primaria è quindi quella dell'entità di #er[Conto]. L'attributo che lo caratterizza è _Tasso d'interesse_ che indica il valore di rendita mensile del conto.
#figure(
  image("media/conto.svg", width: 25%),
  caption: [Entità CONTO]
)
#v(2em)

- L'entità #erb[Prestito] costituisce il servizio creditizio della banca. Essa è caratterizzata da un codice univoco che funge da chiave primaria. L'attributo _Ammontare_ fornisce l'informazione relativa alla somma di denaro prestata, mentre l'attributo _Inizio_ registra la data in cui il prestito ha avuto origine. L'attributo _Somma rate_ è un attributo derivato, che tiene traccia dell'importo saldato dal cliente. L'attributo _Mensilità_ indica il numero di rate complessive del prestito.
#v(-1em)
#figure(
  image("media/prestito.svg", width: 30%),
  caption: [Entità PRESTITO]
)

- L'entità #erb[rata] è una entità debole ed ha il compito di rappresentare ogni singolo pagamento periodico associato a un determinato prestito. L'identificazione univoca di ciascuna rata è garantita da una chiave primaria composta, costituita dal suo numero (indicante la “posizione” della rata nella sequenza dei pagamenti) e dalla chiave esterna che fa riferimento all'entità #er[Prestito]. Tra gli attributi figurano inoltre la _Data scadenza_, ossia il giorno entro cui la rata deve essere corrisposta, e la _Data pagamento_, che riporta il momento in cui il versamento è stato effettuato. Infine, l'attributo _Ammontare_ specifica l'importo dovuto per quella singola rata.
#figure(
  image("media/rata.svg", width: 25%),
  caption: [Entità RATA]
)
#v(2.5em)

- La relazione #erb[è capo] collega l'entità #er[capo] con l'entità #er[filiale], definendo il legame tra il capo di una filiale e la filiale stessa. La cardinalità di (1,1) tra la relazione e l'entità #er[Filiale] indica che ogni filiale ha un solo capo, mentre la cardinalità di (0,1) tra la relazione e l'entità #er[Capo] indica che un dipendente può essere al più capo di una sola filiale.
#figure(
  image("media/iscapo.svg", width: 80%),
  caption: [Relazione è capo]
)
#v(2.5em)

- La relazione #erb[lavora] collega l'entità #er[dipendente] con l'entità #er[filiale]. La cardinalità di (1,1) tra la relazione e l'entità #er[Dipendente] indica che ogni dipendente lavora in una e in una sola filiale, mentre la cardinalità di (1,N) tra la relazione e l'entità #er[filiale] indica che in una filiale lavorano uno o più dipendenti.
#figure(
  image("media/lavora.svg", width: 80%),
  caption: [Relazione lavora]
)
#v(2.5em)


- La relazione #erb[di] collega l'entità #er[dipendente] con l'entità #er[capo]. La cardinalità di (1,N) tra la relazione e l'entità #er[capo] indica che un capo dirige uno o più dipendenti, mentre la cardinalità di (1,1) tra la relazione e l'entità #er[dipendente] indica che un dipendente ha uno e un solo capo. 
#figure(
  image("media/di.svg", width: 80%),
  caption: [Relazione di]
)
#v(2.5em)


- La relazione #erb[è composto] collega l'entità #er[prestito] con l'entità #er[Rata], dando forma al legame logico tra un finanziamento e i singoli pagamenti previsti per il suo rimborso. Dal lato di #er[Rata], la cardinalità è di (1,1), poiché ogni rata è necessariamente associata ad uno e un solo prestito essendo #er[Rata] un'entità debole. Dal lato di Prestito, invece, la cardinalità è di (1,N), poiché un singolo prestito può essere suddiviso in una o più rate.
#figure(
  image("media/composto.svg", width: 80%),
  caption: [Relazione è composto]
)
#v(2.5em)

- La relazione #erb[è associato] collega l'entità Conto con l'entità #er[Prestito], definendo il legame tra esso e il conto bancario a cui è associato. Dal lato di #er[Prestito], la cardinalità è (1,1), poiché ogni prestito deve fare riferimento a un solo conto bancario. Dal lato di #er[Conto] la cardinalità è (0,N), infatti un conto non necessariamente ha prestiti associati.
#figure(
  image("media/isassociato.svg", width: 80%),
  caption: [Relazione è associato]
)
#v(2.5em)

- La relazione #erb[Possiede] collega le entità #er[Cliente] e #er[Conto]. Un cliente deve possedere almeno un conto e più clienti possono possedere lo stesso conto (caso di conto cointestato), da cui deriva la cardinalità (1,N) della relazione sul lato di #er[Cliente]. D'altro canto un #er[conto] deve essere posseduto da almeno un cliente e più conti possono fare riferimento allo stesso cliente (caso in cui uno stesso cliente ha aperto più conti con la banca), da cui deriva la cardinalità (1,N) della relazione sul lato di #er[conto]. \ Gli attributi _Operazione_ e _Data_ sulla relazione indicano l'ultima operazione svolta e la data in cui è stata effettuata. Nel caso di operazione congiunta di più clienti gli attributi _Operazione/Data_ vengono aggiornati per entrambi.
#figure(
  image("media/possiede.svg", width: 80%),
  caption: [Relazione possiede]
)
#v(2.5em)

- La relazione #erb[Gestisce] collega #er[Dipendente] e #er[Cliente]. Un sottoinsieme dei dipendenti può seguire le pratiche di un certo numero di clienti della banca, da cui ne deriva la cardinalità (0,N) della relazione sul lato di #er[dipendente]. D'altro canto un #er[Cliente] può avere al più un solo gestore che segue le sue attività nella banca, da cui ne deriva la cardinalità (0,1) della relazione sul lato di #er[cliente].
#figure(
  image("media/gestisce.svg", width: 80%),
  caption: [Relazione gestisce]
)
#v(2.5em)

- La relazione #erb[Contiene] collega #er[Filiale] a #er[Conto] in quanto ogni #er[Conto] deve fare riferimento ad una e una sola #er[filiale]. Una filiale può contenere uno o più conti (anche zero se la filiale è appena stata aperta), da cui ne deriva la cardinalità (0,N) della relazione sul lato di filiale. D'altro canto un #er[conto] deve essere associato ad una e una sola #er[filiale], da cui ne deriva la cardinalità (1,1) della relazione sul lato di #er[Conto].
#figure(
  image("media/contiene.svg", width: 80%),
  caption: [Relazione contiene]
)
#v(2.5em)

== Scelte particolari
- La specializzazione non totale #er[capo - dipendente] ci permette di inserire la molteplicità (1,1) nella relazione #er[è capo] e di non dover tenere la molteplicità (0,1) nel caso in cui #er[dipendente] non avesse avuto la specializzazione. Favorisce inoltre una maggiore chiarezza nella relazione #er[di].
- La specializzazione totale di #er[conto] è dovuta alla presenza dei diversi attributi che caratterizzazno le due specializzazioni.
- La scelta di assegnare il ruolo di entità a #er[rata] è dovuto alla numerosità degli attributi e alla gestione dell'ammontare dei prestiti. Avendo un numero seriale che non è univoco, è necessario che una parte della chiave sia il codice del prestito.
#v(2.5em)

#pagebreak()

== Schema Concettuale
Dopo le analisi fatte, lo schema concettuale nel modello Entità Relazione è il seguente:
#figure(
  image("media/ER_Banca_1.svg", width: 130%),
  caption: [Schema concettuale nel modello Entità Relazione]
)

== Analisi dei cicli
=== Ciclo #er[dipendente - fliale - capo]:

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
- Due clienti con gestore differente non possono avere un conto condiviso.
- Un dipendente non può gestire se stesso.
- Le rate vanno pagate in ordine cronologico.
- La somma dell'importo delle rate deve corrispondere all'ammontare del prestito.

#pagebreak()
= Progettazione Logica
Nel processo di ottimizzazione delle prestazioni, nell’analisi delle ridondanze e nella semplificazione dello schema ER concettuale in vista della sua ristrutturazione, sono stati presi in considerazione volumi di dati stimati sulla base di una banca reale di riferimento, Intesa Sanpaolo S.p.A

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
  [Cliente] , [Entità], [15.000.000],
  [Conto] , [Entità], [12.000.000],
  [Conto Corrente] , [Entità], [10.000.000],
  [Conto Risparmio] , [Entità], [2.000.000],
  [Dipendente] , [Entità], [100.000],
  [Filiale] , [Entità], [3.000],
  [Prestito] , [Entità], [7.000.000],
  [Contiene] , [Relazione], [12.000.000],
  [Di] , [Relazione], [100.000],
  [#upper[è] associato] , [Relazione], [7.000.000],
  [#upper[è] capo] , [Relazione], [3.000],
  [#upper[è] composto] , [Relazione], [7.000.000],
  [Gestisce] , [Relazione], [10.000.000],
  [Lavora] , [Relazione], [100.000],
  [Possiede] , [Relazione], [19.000.000],
  ),
  caption: [Tabella dei volumi]
)

=== Considerazioni
Il numero di clienti, conti, dipendenti e filiali è stato stimato sulla base di dati reali dell' Intesa Sanpaolo. Abbiamo ipotizzato un numero di prestiti sulla base di una proporzione realistica rispetto ai conti. Per distinguere tra conti correnti e conti di risparmio, abbiamo utilizzato la percentuale media nazionale, applicandola al numero totale di conti. I volumi per le relazioni sono state calcolate tenendo conto delle cardinalità e della natura dei legami tra le entità coinvolte, in modo da mantenere coerenza con il modello concettuale.


== Analisi delle ridondanze


=== Studio dell'attributo derivato _Attivi_ di #er[filiale]
Il primo blocco di operazioni coinvolge l'attributo derivato _Attivi_ che produce una ridondanza ed è derivabile da altre entità, nel nostro caso da #er[Conto, Prestito] e #er[Rata]. Ipotizziamo delle operazioni e le loro relative frequenze che vanno a coinvolgere questo attributo e osserviamo se è conveniente eliminarlo o mantenerlo.

==== Operazione 1: 
Interrogazione per leggere il valore _attivi_ di ogni filiale con frequenza di una volta al giorno

*Con attributo _attivi_: *

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
$ "op1: (1 lettura)" dot 3.000 $ \

Per leggere il valore _attivi_ di ogni filiale, è necessario eseguire una lettura della tabella #er[Filiale] e leggere l'attributo derivato _attivi_.

*Senza attributo _attivi_: *

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

$ "op1:" ((3 "letture" {"Filiale, contiene, conto"} dot 4000) + (2 "letture" {"è associato", "Prestito"} dot 2333)) dot 3000 $

Senza l'attributo _attivi_, per calcolare gli _attivi_ di ogni filiale vengono lette le 3.000 righe della tabella #er[Filiale]. Poi, per ogni filiale, si risale ai conti che possiede: in media sono circa 4.000. Vengono poi effettuati altri 4.000 accessi alla tabella Conto per ottenere i saldi. 

Lo stesso vale per i prestiti: per ogni filiale si leggono in media 4.000 righe nella tabella Associato e poi si accede a Prestito per recuperarne l'importo.

In totale quindi, come si vede dalla tabella, bisognerà leggere interamente le relazioni _contiene_, _è associato_ e tutte le entità Conto e Prestito.

==== Operazione 2
Inserimento di un conto nella base di dati con frequenza 150 volte al giorno

*Con attributo _attivi_:*
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
  [Filiale], [Entità], [150], [Scrittura],
  [Filiale], [Entità], [150], [Lettura],
  ),
  caption: [Operazione 2]
)

$ "op2: (4 scrittura{conto, contiene, possiede, filiale}" + 1 "lettura{filiale})" dot 150 $

Per inserire un conto bisogna scrivere nell'entità Conto e nelle due relazioni Contiene e Possiede, poichè un conto deve avere un cliente che lo possiede e il conto deve essere contenuto da una filiale. 
Infine bisogna leggere e scrivere nell'entità Filiale per aggiornare l'attributo _Attivi_ con il saldo del conto appena inserito. 

*Senza attributo _attivi_:*
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

$ "op2: (3 scrittura{conto, contiene, possiede})" dot 150 $

La logica è come quella vista sopra, con l'eccezione che non serve aggiornare l'attributo _Attivi_, che non è presente. 

==== Operazione 3
Inserimento di una operazione in possiede con frequenza 1.000.000 al giorno

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

$ "op3: (3 scrittura{Possiede, conto, filiale} + 4 letture{Possiede, conto, filiale, contiene})" dot 1.000.000 $

Poichè la relazione Possiede contiene l'attributo operazione, ogni volta che un'operazione viene eseguita bisogna aggiornare l'attributo, ciò comporta una lettura e una scrittura. dopodiché, bisogna anche in questo caso aggiornare il saldo del conto che fa riferimento a quella tupla in possiede, dopodiché solamente leggere la relazione Contiene per individuare la filiale in cui quel conto ha sede e aggiornare quindi l'attributo _Attivi_ della filiale.


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
  [Possiede], [Relazione], [1.000.000], [Scrittura],
  [Possiede], [Relazione], [1.000.000], [Lettura],
  [Conto], [Entità], [1.000.000], [Scrittura],
  [Conto], [Entità], [1.000.000], [Lettura],
  ),
  caption: [Operazione 3]
)

$ "op3: (2 scritture{Possiede, conto} + 2 letture{Possiede, conto})" dot 1.000.000 $

La logica è la stessa di prima, ma non serve aggiornare l'attributo _Attivi_ della filiale, quindi non serve leggere e scrivere nell'entità Filiale.

==== Operazione 4
Aggiornamento di tutti i prestiti con frequenza di una volta al mese.


*Con attributo _attivi_:*
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

$ "op4: (3 scritture{Rata, Prestito, Filiale}" + \ 5 "Letture{è composto, Prestito, è associato, Contiene, Filiale})" dot 7.000.000 dot 1/30 $ ⚠️

Abbiamo considerato l'aggiornamento mensile delle rate e quindi questo comporta la  scrittura della rata che viene saldata in quel mese e da cui poi bisogna risalire al prestito a cui essa fa riferimento tramite la relazione _è composto_, aggiornare il prestito di riferimento, dopodiché tramite la relazione _è associato_ ricavare l'iban del conto a cui è associato, poter quindi leggere in Contiene la filiale in cui quel prestito fa riferimento e quindi operare un aggiornamento dell'attributo attivi della filiale. 

*Senza attributo attivi:*
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

$ "op4: (2 scritture{Rata, Prestito} + 2 Letture{è composto, Prestito})" dot 7.000.000 dot 1/30$ 

Anche in questo caso la logica rimane la stessa, ma non serve aggiornare l'attributo _Attivi_ della filiale, quindi non serve leggere e scrivere nell'entità Filiale e nelle relazioni _è associato_ e _contiene_.

 $ "Totale con attributo attivi": 13.274.017 $ 
 $ "Totale senza attributo attivi": 45.865.567 $ 
 
Questa analisi ci suggerisce che la conservazione dell'attributo derivato attivi sia utile e quindi lo manterremo nel nostro schema ER ristrutturato. 

=== Studio dell'attributo derivato _Somma rate_ di #er[prestito]
Il secondo blocco di operazioni riguardano la ridondanza introdotta dall'attributo derivato somma rate dell'entità Prestito che misura il numero di rate che sono state pagate. Anche in questo caso è il caso di un attributo derivato secondo funzioni aggregative e le entità che sono coinvolte sono Rata e Prestito. Possiamo considerare due operazioni che sono:

==== Operazione 1
Inserimento di una rata una volta al mese per ogni prestito della banca 

*Con attributo ridondante _Somma rate_: *
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
  [è composto], [Relazione], [7.000.000], [Lettura],

  ),
  caption: [Operazione 1]
)

$ "op1: (2 scritture{Rata, Prestito} + 2 Letture{Prestito, è composto})" dot 7.000.000 dot 12/365 $ 

*Senza attributo ridondante _Somma rate_:* 

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

$ "op1: (1 scrittura{Rata})" dot 7.000.000 dot 12/365 $ 

In questo caso, l'operazione di inserimento di una rata comporta la scrittura della rata e la scrittura del prestito, senza la necessità di leggere il prestito per aggiornare l'attributo somma rate.


==== Operazione 2
Lettura del valore della somma delle rate pagate per ogni prestito con frequenza di 2 volte all'anno.

Per questa analisi abbiamo dovuto introdurre un' ulteriore ipotesi, ovvero il numero medio di rate presenti nella nostra base di dati per ogni prestito. Abbiamo supposto questo numero essere 12, che equivale ad un anno di rate pagate.

*Con attributo ridondante _Somma rate_: *

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

$ "op2: (1 lettura{Prestito})" dot 7.000.000 dot 2/365 $ 

*Senza attributo ridondante _Somma rate_:* 

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
  [è associato], [Entità], [7.000.000], [Lettura],
  [Rata], [Entità], [7.000.000], [Lettura],
  ),
  caption: [Operazione 2]
)

$ "op2: (2 letture{Prestito, è associato} + 1 lettura{Rata}" dot 12) dot 7.000.000 dot 2/365$ 

$ "Totale con ridondanza: " 1.419.178,08 $
$ "Totale senza ridondanza: " 997.960,27 $ ⚠️

Per questa ridondanza abbiamo concluso quindi che l'attributo somma rate possa essere rimosso e non essere utilizzato nello schema ER ristrutturato.


== Selelezione delle chiavi primarie
Nell'entità #er[Cliente] abbiamo scelto come chiave primaria l'attributo _ID_ rispetto a _Codice Fiscale_ per mantenere una linearità con l'entità #er[DIPENDENTE] la quale è identificata a sua volta da un codice identificativo.
In tutti gli altri casi la chiave candidata a essere primaria era unica.

== Rimozione delle specializzazioni
Per le analisi fatte in precedenza siamo giunti alla conclusione che il blocco #er[Capo-Di-Dipendente] può essere "compresso", riducendo la complessità visiva e pratica del problema, eliminando la specializzazione capo e la relativa relazione #er[DI], sostituendo il tutto con un nuovo attributo derivato posto nell'entità #er[Dipendente]: _Id capo_.
Di conseguenza viene anche cambiato il riferimento della relazione #er[è capo] che non farà più riferimento all'entità #er[capo] in quanto è stata eliminata ma bensì a #er[Dipendente] mantenendo le cardinalità invariate.
Non c'è perdita di informazione in quanto il nuovo attributo _ID capo_ viene ricavato dalle relazioni #er[Lavora] ed #er[è capo].
Per ricavare il capo di un certo dipendente posso andare a vedere la filiale in cui lavora (che è unica per le cardinalità della relazione), tale filiale sarà gestita da uno e un solo capo (deducibile dalle cardinalità della relazione è capo).
Si può quindi, in maniera univoca, ricavare il capo di un certo dipendente passando attraverso le relazioni e salvare il dato di interesse nell'attributo _ID capo_.

Successivamente la specializzazione di #er[CONTO] è stata ristrutturata aggiungendo due nuove relazioni: #er[Tipo-Corrente] e #er[Tipo-Risparmio] che legano rispettivamente le entità #er[CORRENTE] e #er[RISPARMIO].
Gli attributi delle tre relazioni coinvolte nella specializzazione sono rimasti invariati.
Le cardinalità delle due nuove relazioni sono (0,1) dal lato di #er[conto] in quanto un conto è sicuramente di uno dei due tipi e sicuramente non di entrambi, e dal lato di #er[CORRENTE] e #er[RISPARMIO] è (1,1) in quanto i due tipi di conto esistono e sono associate a uno e un solo conto.
Le chiavi primarie di #er[CORRENTE] e di #er[RISPARMIO] sono delle chiavi primarie legate alla relazione con conto, ne ereditano quindi la chiave primaria _IBAN_.
Da notare il fatto che l'insieme degli _IBAN_ di #er[CORRENTE] deve essere disgiunto dall'insieme _IBAN_ di #er[RISPARMIO] (non esiste un conto che è sia corrente che di risparmio in quanto la specializzazione originariamente era disgiunta).


== Schema ER ristrutturato 
#figure(
  image("media/flowchart-ER-ristrutturato.svg", width: 120%),
  caption: [Schema ER ristrutturato]
)

== Schema Logico 

#erb[CLIENTE] (#u[ID], CF, Residenza, DataDiNascita, Telefono, Cognome, Nome, _Gestore_)
- _CF_: UNIQUE

#erb[CONTO] (#u[_IBAN_], Saldo, _FilialeAppartenenza_)
- FilialeAppartenenza: NOT NULL

#erb[CONTO_CORRENTE] (#u[_IBAN_], Scoperto)
- _IBAN_: UNIQUE

#erb[CONTO_RISPARMIO] (#u[_IBAN_], TassoInteresse)
- _IBAN_: UNIQUE

#erb[POSSIEDE] (#u[_Cliente_, _Conto_], Operazione, Data)

#erb[PRESTITO] (#u[Codice], Ammontare, Inizio, Tipo, _ContoAssociato_)
- _ContoAssociato_: NOT NULL

#erb[RATA] (#u[Numero], _CodicePrestito_, Ammontare, DataPagamento, DataScadenza)

#erb[FILIALE] (#u[Nome], Città, Attivi(derivato), Indirizzo, _Capo_)
- _Capo_ NOT NULL

#erb[DIPENDENTE] (#u[ID], Nome, Cognome, Telefono, DataAssunzione, _IDCapo_ (derivato), _Filiale_)
- _Filiale_ NOT NULL

Legenda: Le chiavi primarie sono sottolineate e le chiavi esterne sono in corsivo. 

=== Chiavi esterne
- _Gestore_ è chiave esterna di #er[cliente] rispetto a #er[DIPENDENTE]

- _FilialeAppartenenza_ è chiave esterna di #er[conto] rispetto a #er[filiale]
- _IBAN_ è chiave esterna di #er[conto corrente, conto risparmio] rispetto a #er[conto]
- _Conto_ chiave esterna di #er[possiede] rispetto a #er[CONTO].
- _Cliente_ è chiave esterna di #er[possiede] rispetto a #er[cliente]
- _ContoAssociato_ è chiave esterna di #er[prestito] rispetto a CONTO
- _Capo_ è chiave esterna di #er[filiale] rispetto a #er[DIPENDENTE]
- _CodicePrestito_ è chiave esterna di #er[rata] rispetto a #er[PRESTITO]
- _IDCapo_ è chiave esterna di #er[dipendente] rispetto a DIPENDENTE
- _Filiale_ è chiave esterna di #er[cliente] rispetto a #er[FILIALE]

#pagebreak()

= Popolamento del database

== Creazione delle tabelle
Per ogni entità è stata creata una tabella nello schema fisico dove gli attributi dell'entità corrispondono ai campi della tabella. I campi della tabella sono stati opportunamente dichiarati in base al tipo di dato e aggiunto eventuali controlli sul loro valore per avere coerenza logica con quanto richiesto tramite l'utilizzo della condizione `CHECK()`.

Campi particolari che richiedevano di essere ad esempio chiave primaria, unici, o non nulli sono stati settati tramite gli appositi comandi.

Le tabelle sono state create in un ordine preciso; in particolare i vincoli di chiave esterna sono stati aggiunti solo quando tutte le tabelle coinvolte erano esistenti. 

La tabella possiede è stata creata in quanto corrisponde alla relazione molti a molti tra l'entità #er[conto] e l'entità #er[cliente].


== Modalità di generazione dei dati
Riportiamo di seguito la tabella dei volumi debitamente proporzionata sulla quale abbiamo creato i dati per il nostro database.

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
  [Cliente] , [Entità], [30.000],
  [Conto] , [Entità], [24.000],
  [Conto Corrente] , [Entità], [20.000],
  [Conto Risparmio] , [Entità], [4.000],
  [Dipendente] , [Entità], [200],
  [Filiale] , [Entità], [6],
  [Prestito] , [Entità], [14.000],
  [Contiene] , [Relazione], [24.000],
  [Di] , [Relazione], [200],
  [#upper[è] associato] , [Relazione], [14.000],
  [#upper[è] capo] , [Relazione], [6],
  [#upper[è] composto] , [Relazione], [14.000],
  [Gestisce] , [Relazione], [20.000],
  [Lavora] , [Relazione], [200],
  [Possiede] , [Relazione], [38.000],
  ),
  caption: [Tabella dei volumi proporzionata]
)

=== Dati #er[filiale]
Questi dati non richiedevano particolari attenzioni poiché non soggetti a nessun tipo di vincolo particolare.

=== Dati #er[diepndente]
 ... To be continued by you 🥰


== Creazione dei trigger

=== Trigger #er[filiale-dipendente]
Sono stati creati dei trigger per gestire le problematicità tra dipendente e filiale che non sono stati possibili catturare coi vincoli tramite lo schema relazionale.

Il manager di una filiale deve fare riferimento alla filiale che gestisce, pertanto non deve essere possibile cambiare la filiale di un manager. Il trigger controlla che su ogni inserimento o modifica nella tabella dipendente venga rispettato il vincolo appena descritto, sollevando un'eccezione in caso di problemi bloccando di conseguenza l'inserimento o la modifica.

Un altro trigger simile controlla che una volta assegnato il manager in una filiale esso lavori effettivamente in quella filiale.


=== Trigger #er[filiale-conto-prestito-rata]
La creazione delle rate di un prestito sono state gestite in modo automatico da un trigger il quale dopo l'inserimento di un prestito, calcola l'importo mensile di ogni rata in base all'ammontare e il numero di mensilità, creando le rate (tutte con lo stesso importo mensile) e mettendo la data di scadenza in modo coerente e sequenziale.

Un altro trigger controlla la possibilità di poter pagare una rata bloccando l'aggiornamento in caso la rata fosse già stata pagata, in caso di pagamento concesso, il trigger si occupa anche di aggiornare gli attivi della filiale corrispondente.

In modo analogo un trigger aggiorna gli attivi della filiale ogni volta che un nuovo prestito viene creato.


=== Trigger #er[possiede-conto-filiale]
Il calcolo degli attivi, analogamente come quello di prestiti/rate, viene fatto in automatico da un trigger ogni volta che viene aggiornato il saldo di un conto.

Per le scelte fatte nessun IBAN in conto corrente deve comparire in conto di risparmio e viceversa ma tutti gli IBAN di #er[conto corrente] e di #er[conto risparmio] devono comparire in #er[conto], tale vincolo viene rispettato da due opportuni trigger.

La coerenza delle operazioni eseguibili su un determinato conto anch'essa è verificata da due appositi trigger. Viene controllato che l'operazione sia sensata sul conto (non posso aprire un conto due volte e non posso fare operazioni sul conto di risparmio) e in caso di prelievo un trigger si occupa di verificare il saldo rimanente e di aggiornarlo.



== Inserimento tabelle e dati nel database
Per creare il database richiesto, popolarlo e testare le query assegnate è stata seguita una particolare logica affinché tutto venisse inserito correttamente.

Per prima cosa è stato creato il database, assegnando i volumi dei dati con valori proporzionati alla tabella dei volumi precedentemente proposta.

Vengono poi caricati nel sistema tutti i trigger utilizzati e temporaneamente disabilitati per possibili inconsistenze momentanee nell'inserimento dei dati. La modalità di generazione casuale dei dati è stata pensata in modo tale che, al termine degli inserimenti iniziali, tutto sia coerente e non ci siano errori.

Le prime tabelle popolate sono #er[filiale] e #er[dipendente]. Al termine del popolamento vengono eseguiti forzatamente due trigger in maniera tale da assegnare automaticamente i manager (che non erano stati inseriti) e verificare la presenza di eventuali errori (di base i dati sono stati generati consistentemente).

Estratti dei possibili gestori vengono inseriti i clienti, successivamente la tabella #er[conto] con le relative #er[conto corrente] e #er[Conto di risparmio]. Una volta inseriti questi dati è possibile procedere al popolamento della tabella #er[possiede] che gestisce tutte le connessioni tra i clienti e i loro conti.

Per la macrocategoria dei prestiti, una volta generati quest'ultimi e le relative rate andiamo, tramite apposito script, a pagare le rate che hanno una data di scadenza antecedente a quella odierna. Inseriti tutti i prestiti aggiorniamo l'attributo _attivi_ della tabella #er[Filiale] in maniera automatica sui dati inseriti e al termine riattiviamo tutti i trigger.

Gli script utilizzati non potevano essere sempre sostituiti dai trigger, infatti non era possibile tenerli tutti attivi e inserire tutti i valori in maniera ordinata e raggruppati per tabelle, ma avremmo dovuto fare attenzione volta per volta. Degli esempi di inserimenti di record sono presentati più avanti.


== Test 
Finito di popolare tutto il database ci assicuriamo tramite dei test che tutto sia perfettamente funzionante, che rispetti i requisiti che ci siamo imposti e che ci dia i risultati attesi. Questa verifica viene effettuata confrontando il risultato ottenuto dalle operazioni con i risultati attesi.

== Test Dipendente-Filiale

+	Tentiamo di modificare la filiale di riferimento di un manager senza aggiornare il ruolo di managaer. Il trigger ci protegge e ci vieta l'inserimento (un dipendente non può lavorare nella filiale #er[A] ed essere manager della filiale #er[B]).

+	Simile al precedente, proviamo ad assegnare il ruolo di manager di una filiale a un dipendente che lavora presso una filiale diversa. Il trigger blocca l'azione e ci restituisce l'errore (la modifica non viene effettuata).

+	Inseriamo un nuovo dipendente: non è necessario specificare il campo manager in quanto il trigger apposito si occupa di ricercare l'id del manager nella filiale dove lavora il nuovo dipendente e assegnare il campo corrispondente.

+ Come il caso (3) ma con l'aggiunta che questo dipendente diventi manager della filiale in cui lavora. Il trigger che viene innescato sulla modifica del campo manager (che passa da -1 [non manager] a un id di filiale valido) provvede ad aggiornare il campo manager di tutti i dipendenti che lavorano nella filiale dove è appena stato modificato il manager.

+	Controlliamo una semplice operazione di rimozione di un dipendente che non è manager.


== Test Prestito-Rata

+	Inseriamo un nuovo prestito. Le rate relative verranno generate in maniera automatica dal trigger che si occupa di andare a recuperare il valore di _Mensilità_ e generare altrettanti record nella tabella #er[rata] riempiendo in maniera adeguata tutti i campi.

+	Modifichiamo la data di pagamento di una rata, portandola da NULL a una data valida. Il controllo del trigger sarà di verificare che non ci siano rate precedenti ancora da pagare.


== Test Conto-Filiale

+	Simuliamo un versamento e un prelievo, quindi andiamo a modificare il valore del saldo dei conti. A questo punto dei trigger controllano (solo nel secondo caso) che il prelievo possa essere effettuato, quindi che il saldo sia un numero valido (non minore dello scoperto), dopodiché in entrambi i casi vengono automaticamente aggiornati gli attivi delle filiali. Lo scopo del test è comunque di verificare che il saldo venga correttamente modificato.

+	Controlliamo che il trigger che controlla la validità dei saldi funzioni, forzando la modifica di un saldo a un valore non valido. Ci attendiamo un errore.

+	Simile al primo test con il focus sull'aggiornamento degli attivi della filiale di riferimento.

+	Proviamo a inserire un IBAN valido nella tabella #er[conto] (necessario per i vincoli di chiave esterna) e poi nella tabella #er[Conto Corrente]. Questo non dovrebbe generare problemi. Proviamo a inserire l'IBAN anche in #er[Conto Risparmio], il trigger vieta tale operazione e, dato che siamo all'interno di una transazione, tutti e tre gli inserimenti vengono rimossi (rollback).

+ Test di consistenza dei gestori diversi su conti cointestati


= Query 
PER PERE: METTERE LE QUERY IN SQL DOPO LA QUOTE E PRIMA DEL COMMENTO \
Dopo aver verificato che anche i test restituivano i risultati attesi, procediamo con l'esecuzione delle query assegnate:

== QUERY 1:
#quote[Restituire il numero medio di rate dei prestiti associati a conti nelle filiali di Udine.]
Richiesta immediata, necessario l'utilizzo della funzione aggregata `AVG()`

== QUERY 2:	
#quote[Restituire i clienti con solo conti di risparmio in filiali che hanno tra i 30 e i 32 dipendenti.]
Per comodità è stata creata una vista dove è stat fatta una selezione sulla tabella #er[filiale], tenendo solamente quelle che rispettavano il vincolo sul numero dei dipendenti.
La query poi si appoggia su questa vista per cercare i clienti che hanno almeno un conto di risparmio in queste filiali e che non hanno nessun conto corrente associato.

== QUERY 3:
#quote[Restituire i capi che gestiscono almeno 3 clienti che possiedono almeno 100 000€.]
La vista creata è una restrizione sui clienti che rispettano il vincolo. È stata effettuata con l'utilizzo della funzione `SUM()` poiché il saldo era relativo a tutti i conti posseduti.
Per validare un capo è stato fatto il prodotto cartesiano triplo della vista e, dopo essere state selezionati solamente le righe con gestore uguale, è stato controllato che i clienti fossero tutti e tre diversi.

== QUERY 4:
#quote[Restituire i dipendenti non capo che gestiscono esattamente 2 clienti, uno con solo conti correnti e uno son solo conti di risparmio.]
La prima (seconda) vista seleziona solamente i clienti che hanno almeno un conto corrente (di risparmio) e che non hanno nessun conto di risparmio (corrente).
La query seleziona i dipendenti non capo (con la verifica _ID_ <> _Capo_) e poi controlla che esista un unico cliente nella prima vista e un unico cliente nella seconda vista.

== QUERY 5:
#quote[Restituire il cliente con il prestito più alto nella filiale di Roma che non ha come gestore un dipendente con meno di 3 anni di esperienza.]
La prima vista ci restringe i possibili clienti a quelli che hanno un gestore assunto da almeno 3 anni.
La seconda vista, a partire dalla prima, fa un ulteriore filtro prendendo i clienti solo della filiale di Roma.
La query si occupa di verificare, per ogni cliente, che tra i clienti della seconda vista non ce ne sia qualcuno con saldo maggiore del proprio, in tal caso stampa il cliente.


= Analisi dei dati
== Visualizzazione dei dati
=== Distribuzione mensilità prestiti
=== Analisi attivi per anzianità gestori
=== Analisi conti cointestati

= Conclusioni
== Risultati ottenuti
== Possibili miglioramenti
== Considerazioni finali



#line(length: 100%)
#pagebreak()
 (test)

#zebraw(
  header: [*Creazione Tabelle*],
```sql
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
```
)
