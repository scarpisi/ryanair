-- Popolamento delle tabelle di base
INSERT INTO Aeroporti (AirportCode, Nome, Citta, Paese) VALUES
('DUB', 'Dublin Airport', 'Dublino', 'Irlanda'),
('STN', 'London Stansted Airport', 'Londra', 'Regno Unito'),
('BGY', 'Orio al Serio International Airport', 'Milano', 'Italia'),
('CIA', 'Rome Ciampino Airport', 'Roma', 'Italia'),
('WMI', 'Warsaw Modlin Airport', 'Varsavia', 'Polonia'),
('MAD', 'Adolfo Suárez Madrid–Barajas Airport', 'Madrid', 'Spagna'),
('ATH', 'Athens International Airport', 'Atene', 'Grecia');

INSERT INTO ModelliAereo (Produttore, NomeModello, CapacitaPosti, Autonomia) VALUES
('Boeing', '737-800', 189, 5436),
('Boeing', '737-MAX-10', 228, 6110);

INSERT INTO Aerei (ModelloID, NumeroRegistrazione, DataAcquisto) VALUES
(1, 'EI-DHH', '2005-03-29'),
(1, 'EI-JFK', '2022-05-10'),
(2, 'EI-MAX', '2024-08-01');

INSERT INTO Passeggeri (Nome, Cognome, DataNascita, Email, Nazionalita, DocumentoIdentita) VALUES
('Mario', 'Rossi', '1985-05-20', 'mario.rossi@email.com', 'Italiana', 'YA12345BC'),
('Laura', 'Bianchi', '1992-11-10', 'laura.bianchi@email.com', 'Italiana', 'AB54321CD'),
('John', 'Smith', '1978-02-15', 'john.smith@email.com', 'Britannica', '500123456'),
('Ana', 'García', '2001-07-30', 'ana.garcia@email.com', 'Spagnola', '12345678Z'),
('Paolo', 'Verdi', '1995-03-12', 'paolo.verdi@email.com', 'Italiana', 'CA98765FG');

INSERT INTO Tariffe (NomeTariffa, PrezzoAggiuntivo) VALUES
('Basic', 0.00),
('Regular', 27.78),
('Plus', 37.11),
('Flexi Plus', 99.55);

INSERT INTO Servizi (NomeServizio, CostoBase) VALUES
('Bagaglio piccolo', 0.00),
('Posto prenotato', 8.00),
('Imbarco prioritario', 15.00),
('Bagaglio a mano 10kg', 25.00),
('Bagaglio da stiva 20kg', 40.00),
('Controlli rapidi', 12.00),
('Check-in online gratuito', 0.00),
('Cambio volo gratuito', 50.00),
('Anticipa la partenza', 30.00);

INSERT INTO Equipaggi (Nome, Cognome, Ruolo) VALUES
('John', 'Doe', 'Pilota'),
('Jane', 'Smith', 'Co-pilota'),
('Emily', 'Jones', 'Assistente di Volo Capo'),
('Michael', 'Brown', 'Assistente di Volo'),
('David', 'Wilson', 'Pilota'),
('Sarah', 'Taylor', 'Co-pilota');

-- Popolamento dei servizi inclusi nelle tariffe
-- Basic
INSERT INTO ServiziInclusi (TariffaID, ServizioID, Quantita) VALUES (1, 1, 1), (1, 7, 1);
-- Regular
INSERT INTO ServiziInclusi (TariffaID, ServizioID, Quantita) VALUES (2, 1, 1), (2, 7, 1), (2, 2, 1), (2, 3, 1), (2, 4, 1);
-- Plus
INSERT INTO ServiziInclusi (TariffaID, ServizioID, Quantita) VALUES (3, 1, 1), (3, 7, 1), (3, 2, 1), (3, 5, 1);
-- Flexi Plus
INSERT INTO ServiziInclusi (TariffaID, ServizioID, Quantita) VALUES (4, 1, 1), (4, 7, 1), (4, 2, 1), (4, 3, 1), (4, 4, 1), (4, 6, 1), (4, 8, 1), (4, 9, 1);

-- Popolamento delle tabelle dipendenti
INSERT INTO Rotte (AeroportoPartenza, AeroportoArrivo, Distanza) VALUES
('DUB', 'STN', 480),
('STN', 'DUB', 480),
('BGY', 'MAD', 1185),
('MAD', 'BGY', 1185),
('DUB', 'BGY', 1430), -- Per volo con scalo
('BGY', 'ATH', 1300); -- Per volo con scalo

INSERT INTO Voli (NumeroVolo, RottaID, AereoID, OrarioPartenzaPrevisto, OrarioArrivoPrevisto) VALUES
('FR101', 1, 1, '2025-11-15 08:00:00', '2025-11-15 09:30:00'),
('FR102', 2, 1, '2025-11-22 10:00:00', '2025-11-22 11:30:00'),
('FR201', 3, 2, '2025-11-15 12:00:00', '2025-11-15 14:15:00'),
('FR202', 4, 2, '2025-11-22 15:00:00', '2025-11-22 17:15:00'),
('FR901', 5, 3, '2025-12-01 07:00:00', '2025-12-01 09:00:00'),
('FR902', 6, 3, '2025-12-01 10:30:00', '2025-12-01 13:00:00'),
('FR301', 1, 1, '2025-11-15 09:00:00', '2025-11-15 10:30:00'); -- Volo con sovrapposizione per test Query 5

-- Assegnazione equipaggio a un volo che si sovrappone con FR101
INSERT INTO AssegnazioniEquipaggio (VoloID, MembroEquipaggioID) VALUES
(7, 5), -- David Wilson (Pilota) su FR301
(7, 6); -- Sarah Taylor (Co-pilota) su FR301

-- Simulazione di una prenotazione A/R per 2 passeggeri (senza scalo)
BEGIN;
INSERT INTO Prenotazioni (CodicePrenotazione) VALUES ('R1A2N3') RETURNING PrenotazioneID;
-- Supponiamo che l'ID restituito sia 1
INSERT INTO Itinerari (PrenotazioneID, PasseggeroID) VALUES (1, 1), (1, 1), (1, 2), (1, 2);
-- ItinerarioID 1: Andata Mario (Plus), 2: Ritorno Mario (Plus), 3: Andata Laura (Basic), 4: Ritorno Laura (Basic)
INSERT INTO SegmentiVolo (ItinerarioID, VoloID, TariffaID, OrdineSegmento, PrezzoBase) VALUES
(1, 1, 3, 1, 89.99), (2, 2, 3, 1, 95.50), (3, 1, 1, 1, 79.99), (4, 2, 1, 1, 95.50);
-- Creazione benefit per Mario (Tariffa Plus)
INSERT INTO BenefitPasseggero (SegmentoVoloID, ServizioID, Origine, PrezzoPagato) VALUES
(1, 1, 'Tariffa', 0.00), (1, 7, 'Tariffa', 0.00), (1, 2, 'Tariffa', 0.00), (1, 5, 'Tariffa', 0.00);
-- Creazione benefit per Laura (Tariffa Basic)
INSERT INTO BenefitPasseggero (SegmentoVoloID, ServizioID, Origine, PrezzoPagato) VALUES
(3, 1, 'Tariffa', 0.00), (3, 7, 'Tariffa', 0.00);
-- Laura (Basic) aggiunge un bagaglio da 10kg
INSERT INTO BenefitPasseggero (SegmentoVoloID, ServizioID, Origine, PrezzoPagato) VALUES (3, 4, 'Acquisto', 25.00);
INSERT INTO Checkin (SegmentoVoloID, PostoAssegnato, TipoDocumento, NumeroDocumento) VALUES
(1, '10A', 'Passaporto', 'YA12345BC'), (2, '11A', 'Passaporto', 'YA12345BC'),
(3, '25B', 'Carta d''Identità', 'AB54321CD'), (4, '26C', 'Carta d''Identità', 'AB54321CD');
-- Simulazione utilizzo di un servizio: il bagaglio di Mario viene imbarcato
UPDATE BenefitPasseggero SET Stato = 'Utilizzato' WHERE SegmentoVoloID = 1 AND ServizioID = 5;
INSERT INTO Pagamenti (PrenotazioneID, Importo, MetodoPagamento, StatoPagamento) VALUES
(1, 418.10, 'Carta di Credito', 'Completato'); -- (89.99+37.11) + (95.50+37.11) + 79.99 + 95.50 + 25.00
COMMIT;

-- Simulazione di una prenotazione con scalo per 1 passeggero
BEGIN;
INSERT INTO Prenotazioni (CodicePrenotazione) VALUES ('SCA4O5') RETURNING PrenotazioneID;
-- Supponiamo che l'ID restituito sia 2
INSERT INTO Itinerari (PrenotazioneID, PasseggeroID) VALUES (2, 5) RETURNING ItinerarioID;
-- Supponiamo che l'ID restituito sia 5
INSERT INTO SegmentiVolo (ItinerarioID, VoloID, TariffaID, OrdineSegmento, PrezzoBase) VALUES
(5, 5, 2, 1, 120.00), (5, 6, 2, 2, 90.00);
-- Creazione benefit per Paolo (Tariffa Regular) per entrambi i segmenti
INSERT INTO BenefitPasseggero (SegmentoVoloID, ServizioID, Origine, PrezzoPagato) VALUES
(5, 1, 'Tariffa', 0.00), (5, 7, 'Tariffa', 0.00), (5, 2, 'Tariffa', 0.00), (5, 3, 'Tariffa', 0.00), (5, 4, 'Tariffa', 0.00),
(6, 1, 'Tariffa', 0.00), (6, 7, 'Tariffa', 0.00), (6, 2, 'Tariffa', 0.00), (6, 3, 'Tariffa', 0.00), (6, 4, 'Tariffa', 0.00);
INSERT INTO Checkin (SegmentoVoloID, PostoAssegnato, TipoDocumento, NumeroDocumento) VALUES
(5, '15C', 'Passaporto', 'CA98765FG'), (6, '20F', 'Passaporto', 'CA98765FG');
INSERT INTO Pagamenti (PrenotazioneID, Importo, MetodoPagamento, StatoPagamento) VALUES
(2, 265.56, 'PayPal', 'Completato'); -- 120.00 + 90.00 + (2 * 27.78)
COMMIT;
