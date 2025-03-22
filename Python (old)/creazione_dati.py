import csv, random, string
from faker import Faker

fake = Faker('it_IT')

# === Configurazione di base ===================================================================================================
# Definiamo il numero di entità per simulare il database
NUM_CLIENTI = 25000    # Numero di clienti totali
NUM_FILIALI = 5        # Numero di filiali
NUM_DIPENDENTI = 200   # Numero totale di dipendenti
NUM_CONTI = 20000      # Numero totale di conti bancari
NUM_CORRENTI = 15385   # Numero di conti correnti
NUM_RISPARMI = 4615    # Numero di conti risparmio
NUM_PRESTITI = 11667   # Numero di prestiti totali


# === Creazione Dipendenti ===================================================================================================
# I primi 5 dipendenti sono manager delle prime 5 filiali.
# Gli altri dipendenti lavorano in filiali assegnate casualmente.
with open('./csvDati/Dipendente.csv', mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['id', 'nome', 'cognome', 'data_assunzione', 'telefono', 'filiale', 'capo'])

    for i in range(1, NUM_DIPENDENTI+1):
        nome = fake.first_name()
        cognome = fake.last_name()
        data_assunzione = fake.date_between(start_date='-20y', end_date='today').isoformat()
        telefono = '+39' + ''.join(random.choices('0123456789', k=10))
        
        if i <= NUM_FILIALI:
            filiale = f"{i}"
        else:
            filiale = f"{random.randint(1, NUM_FILIALI)}"

        writer.writerow([i, nome, cognome, data_assunzione, telefono, filiale, ''])


# === Creazione Filiali ================================================================================================
with open('./csvDati/Filiale.csv', mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['nome', 'città', 'indirizzo', 'manager', 'attivi'])

    for i in range(1, NUM_FILIALI+1):
        nome = f"{i}"
        città = fake.city()
        indirizzo = fake.address().replace('\n', ', ')
        manager = i  # Manager predefinito
        attivi = round(random.uniform(1e6, 1e7), 2)  

        writer.writerow([nome, città, indirizzo, manager, attivi])


# === Creazione Clienti ===================================================================================================
with open('./csvDati/Cliente.csv', mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['id', 'cf', 'nome', 'cognome', 'data_nascita', 'residenza', 'telefono', 'gestore'])

    for i in range(1, NUM_CLIENTI+1):
        nome = fake.first_name()
        cognome = fake.last_name()
        cf = ''.join(random.choices(string.ascii_uppercase + string.digits, k=16))
        data_nascita = fake.date_of_birth(minimum_age=18, maximum_age=90).isoformat()
        residenza = fake.address().replace('\n', ', ')
        telefono = '+39' + ''.join(random.choices('0123456789', k=10))
        gestore = random.choice([random.randint(1, NUM_DIPENDENTI), None])

        writer.writerow([i, cf, nome, cognome, data_nascita, residenza, telefono, gestore])


# === Creazione Conti ===================================================================================================
# Generiamo i conti principali
conti_ibans = []

with open('./csvDati/Conto.csv', mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['filiale', 'iban', 'saldo'])

    for i in range(1, NUM_CONTI+1):
        filiale = f"Filiale_{random.randint(1, NUM_FILIALI)}"
        iban = ''.join(random.choices(string.ascii_uppercase + string.digits, k=27))
        saldo = round(random.uniform(100, 50000), 2)

        conti_ibans.append(iban)  # Salviamo l'IBAN per le tabelle successive
        writer.writerow([filiale, iban, saldo])


# === Creazione Relazione Possiede ============================================================================================
with open('./csvDati/Possiede.csv', mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['cliente', 'conto', 'tipo_operazione', 'importo_operazione'])

    coppie_uniche = set()

    for iban in conti_ibans:
        cliente = random.randint(1, NUM_CLIENTI)
        tipo_operazione = 'apertura'

        if (cliente, iban) not in coppie_uniche:
            coppie_uniche.add((cliente, iban))
            writer.writerow([cliente, iban, tipo_operazione])

    
    for _ in range(int(NUM_CONTI * 0.2)):  # 20% dei conti hanno più clienti
        cliente = random.randint(1, NUM_CLIENTI)
        iban = random.choice(conti_ibans)
        tipo_operazione = 'apertura'

        if (cliente, iban) not in coppie_uniche:
            coppie_uniche.add((cliente, iban))
            writer.writerow([cliente, iban, tipo_operazione])


# === Creazione Conti Correnti ===============================================================================================
# Selezioniamo alcuni IBAN dalla lista principale per i conti correnti
with open('./csvDati/ContoCorrente.csv', mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['iban', 'scoperto'])

    # Scegliamo un sottoinsieme degli IBAN
    conti_correnti_ibans = random.sample(conti_ibans, NUM_CORRENTI)

    for iban in conti_correnti_ibans:
        scoperto = round(random.uniform(0, 5000), 2)
        writer.writerow([iban, scoperto])


# === Creazione Conti Risparmio ==============================================================================================
# Selezioniamo altri IBAN per i conti di risparmio
with open('./csvDati/ContoRisparmio.csv', mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['iban', 'tasso_interesse'])

    # Scegliamo un sottoinsieme degli IBAN rimanenti
    conti_risparmio_ibans = set(conti_ibans) - set(conti_correnti_ibans)
    conti_risparmio_ibans = random.sample(conti_risparmio_ibans, NUM_RISPARMI)

    for iban in conti_risparmio_ibans:
        tasso_interesse = round(random.uniform(0.01, 0.05), 4)
        writer.writerow([iban, tasso_interesse])


# === Creazione Prestiti ===================================================================================================
# Associa prestiti solo agli IBAN validi dalla tabella Conto
with open('./csvDati/Prestito.csv', mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['codice', 'conto_associato', 'ammontare', 'mensilità', 'data_apertura'])

    # Selezioniamo un sottoinsieme degli IBAN esistenti
    conti_prestiti_ibans = random.sample(conti_ibans, NUM_PRESTITI)

    for i, conto_associato in enumerate(conti_prestiti_ibans, start=1):
        ammontare = round(random.uniform(1000, 100000), 2)
        mensilità = random.randint(12, 120)  # 1-10 anni
        data_apertura = fake.date_between(start_date='-10y', end_date='today').isoformat()

        writer.writerow([i, conto_associato, ammontare, mensilità, data_apertura])