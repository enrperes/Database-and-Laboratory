import csv, random, string
from faker import Faker

fake = Faker('it_IT')

# === Configurazione di base ===================================================================================================
# Definiamo il numero di entità per simulare il database
NUM_CLIENTI = 30000    # Numero di clienti totali
NUM_FILIALI = 5        # Numero di filiali
NUM_DIPENDENTI = 200   # Numero totale di dipendenti
NUM_CONTI = 20000      # Numero totale di conti bancari
NUM_CORRENTI = 15385   # Numero di conti correnti
NUM_RISPARMI = 4615    # Numero di conti risparmio
NUM_PRESTITI = 11667   # Numero di prestiti totali



with open('./data_assunzione.txt', mode='w', encoding='utf-8') as file:
    for _ in range(NUM_DIPENDENTI):
        data_assunzione = fake.date_between(start_date='-20y', end_date='today').isoformat()
        file.write(data_assunzione + '\n')

with open('./telefono.txt', mode='w', encoding='utf-8') as file:
    telefoni_generati = set()

    while len(telefoni_generati) < (NUM_DIPENDENTI + NUM_CLIENTI):  
        telefono = '+39' + ''.join(random.choices('0123456789', k=10))
        if telefono not in telefoni_generati:
            telefoni_generati.add(telefono)
            file.write(telefono + '\n')

