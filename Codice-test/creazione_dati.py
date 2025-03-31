import csv, random, string, os
from faker import Faker
os.makedirs('./dati', exist_ok=True)
fake = Faker('it_IT')

# === Configurazione di base ===================================================================================================
# Definiamo il numero di entità per simulare il database
NUM_CLIENTI = 30000    # Numero di clienti totali
NUM_FILIALI = 6        # Numero di filiali
NUM_DIPENDENTI = 200   # Numero totale di dipendenti
NUM_CONTI = 24000      # Numero totale di conti bancari
NUM_CORRENTI = 20000   # Numero di conti correnti
NUM_RISPARMI = 4000    # Numero di conti risparmio
NUM_PRESTITI = 14000   # Numero di prestiti totali

with open('./dati/data_assunzione.txt', mode='w', encoding='utf-8') as file:
    for _ in range(NUM_DIPENDENTI):
        data_assunzione = fake.date_between(start_date='-20y', end_date='today').isoformat()
        file.write(data_assunzione + '\n')

with open('./dati/data_nascita.txt', mode='w', encoding='utf-8') as file:
    for _ in range(NUM_CLIENTI):
        data = fake.date_between(start_date='-95y', end_date='-18y').isoformat()
        file.write(data + '\n')

with open('./dati/telefono.txt', mode='w', encoding='utf-8') as file:
    telefoni_generati = set()

    while len(telefoni_generati) < (NUM_DIPENDENTI + NUM_CLIENTI):  
        telefono = '+39' + ''.join(random.choices('0123456789', k=10))
        if telefono not in telefoni_generati:
            telefoni_generati.add(telefono)
            file.write(telefono + '\n')

with open('./dati/residenza.txt', mode='w', encoding='utf-8') as file:
    residenze_generate = set()

    while len(residenze_generate) < NUM_CLIENTI:
        indirizzo = fake.address().replace('\n', ', ')
        if indirizzo not in residenze_generate:
            residenze_generate.add(indirizzo)
            file.write(indirizzo + '\n')

with open('./dati/iban.txt', mode='w', encoding='utf-8') as file:
    iban_generati = set()

    while len(iban_generati) < NUM_CONTI:
        iban = 'IT' + ''.join(random.choices(string.digits + string.ascii_uppercase, k=25))
        if iban not in iban_generati:
            iban_generati.add(iban)
            file.write(iban + '\n')

with open('./dati/cf.txt', mode='w', encoding='utf-8') as file:
    cf_generati = set()

    while len(cf_generati) < NUM_CLIENTI:
        cf = ''.join(random.choices(string.ascii_uppercase + string.digits, k=16))
        if cf not in cf_generati:
            cf_generati.add(cf)
            file.write(cf + '\n')

with open('./dati/saldo.txt', mode='w', encoding='utf-8') as file:
    for _ in range(NUM_CONTI):
        saldo = round(random.uniform(-100.00, 500000.00), 2) 
        file.write(f"{saldo}\n")

with open('./dati/scoperto.txt', mode='w', encoding='utf-8') as file:
    for _ in range(NUM_CORRENTI):
        scoperto = round(random.uniform(0.00, 10000.00), 2)  # Permette conti senza scoperto
        file.write(f"{scoperto}\n")

with open('./dati/interesse.txt', mode='w', encoding='utf-8') as file:
    for _ in range(NUM_RISPARMI):
        interesse = round(random.uniform(0.01, 4.00), 4)
        file.write(f"{interesse}\n")

with open('./dati/data_prestito.txt', mode='w', encoding='utf-8') as file:
    for _ in range(NUM_PRESTITI):
        data_prestito = fake.date_between(start_date='-20y', end_date='today').isoformat()
        file.write(data_prestito + '\n')

with open('./dati/ammontare_prestito.txt', mode='w', encoding='utf-8') as file:
    for _ in range(NUM_PRESTITI):
        ammontare_prestito = round(random.uniform(1000.00, 100000.00), 2)
        file.write(f"{ammontare_prestito}\n")

with open('./dati/mensilità.txt', mode='w', encoding='utf-8') as file:
    for _ in range(NUM_PRESTITI):
        mensilità = random.randint(12, 240)  # Genera mesi invece di una data errata
        file.write(f"{mensilità}\n")
