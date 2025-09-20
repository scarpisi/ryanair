-- Creazione delle tabelle di base 

CREATE TABLE Aeroporti (
    AirportCode VARCHAR(3) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Citta VARCHAR(100) NOT NULL,
    Paese VARCHAR(100) NOT NULL
);

CREATE TABLE ModelliAereo (
    ModelloID SERIAL PRIMARY KEY,
    Produttore VARCHAR(50) NOT NULL,
    NomeModello VARCHAR(50) NOT NULL,
    CapacitaPosti INTEGER NOT NULL CHECK (CapacitaPosti > 0),
    Autonomia INTEGER NOT NULL CHECK (Autonomia > 0)
);

CREATE TABLE Passeggeri (
    PasseggeroID SERIAL PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Cognome VARCHAR(100) NOT NULL,
    DataNascita DATE NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Nazionalita VARCHAR(50) NOT NULL,
    DocumentoIdentita VARCHAR(50) NOT NULL
);

CREATE TABLE Tariffe (
    TariffaID SERIAL PRIMARY KEY,
    NomeTariffa VARCHAR(50) NOT NULL UNIQUE,
    PrezzoAggiuntivo NUMERIC(10, 2) NOT NULL DEFAULT 0.00
);

CREATE TABLE Servizi (
    ServizioID SERIAL PRIMARY KEY,
    NomeServizio VARCHAR(100) NOT NULL UNIQUE,
    Descrizione TEXT,
    CostoBase NUMERIC(10, 2) NOT NULL CHECK (CostoBase >= 0)
);

CREATE TABLE Equipaggi (
    MembroEquipaggioID SERIAL PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Cognome VARCHAR(100) NOT NULL,
    Ruolo VARCHAR(50) NOT NULL CHECK (Ruolo IN ('Pilota', 'Co-pilota', 'Assistente di Volo Capo', 'Assistente di Volo'))
);

-- Creazione delle tabelle per la gestione strutturata di tariffe e pacchetti
CREATE TABLE ServiziInclusi (
    TariffaID INTEGER NOT NULL REFERENCES Tariffe(TariffaID) ON DELETE CASCADE,
    ServizioID INTEGER NOT NULL REFERENCES Servizi(ServizioID) ON DELETE RESTRICT,
    Quantita INTEGER NOT NULL CHECK (Quantita > 0),
    PRIMARY KEY (TariffaID, ServizioID)
);

-- Creazione delle tabelle con dipendenze

CREATE TABLE Aerei (
    AereoID SERIAL PRIMARY KEY,
    ModelloID INTEGER NOT NULL REFERENCES ModelliAereo(ModelloID) ON DELETE RESTRICT,
    NumeroRegistrazione VARCHAR(10) NOT NULL UNIQUE,
    DataAcquisto DATE
);

CREATE TABLE Rotte (
    RottaID SERIAL PRIMARY KEY,
    AeroportoPartenza VARCHAR(3) NOT NULL REFERENCES Aeroporti(AirportCode) ON DELETE RESTRICT,
    AeroportoArrivo VARCHAR(3) NOT NULL REFERENCES Aeroporti(AirportCode) ON DELETE RESTRICT,
    Distanza INTEGER CHECK (Distanza > 0),
    UNIQUE (AeroportoPartenza, AeroportoArrivo)
);

CREATE TABLE Voli (
    VoloID SERIAL PRIMARY KEY,
    NumeroVolo VARCHAR(10) NOT NULL,
    RottaID INTEGER NOT NULL REFERENCES Rotte(RottaID) ON DELETE RESTRICT,
    AereoID INTEGER NOT NULL REFERENCES Aerei(AereoID) ON DELETE RESTRICT,
    OrarioPartenzaPrevisto TIMESTAMP NOT NULL,
    OrarioArrivoPrevisto TIMESTAMP NOT NULL,
    StatoVolo VARCHAR(20) NOT NULL DEFAULT 'Programmato' CHECK (StatoVolo IN ('Programmato', 'In Orario', 'In Ritardo', 'Cancellato', 'Decollato', 'Atterrato')),
    CHECK (OrarioArrivoPrevisto > OrarioPartenzaPrevisto)
);

CREATE TABLE Prenotazioni (
    PrenotazioneID SERIAL PRIMARY KEY,
    CodicePrenotazione VARCHAR(6) NOT NULL UNIQUE,
    DataPrenotazione TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    StatoPrenotazione VARCHAR(20) NOT NULL DEFAULT 'Confermata' CHECK (StatoPrenotazione IN ('In attesa', 'Confermata', 'Cancellata'))
);

CREATE TABLE Pagamenti (
    PagamentoID SERIAL PRIMARY KEY,
    PrenotazioneID INTEGER NOT NULL REFERENCES Prenotazioni(PrenotazioneID) ON DELETE CASCADE,
    Importo NUMERIC(10, 2) NOT NULL CHECK (Importo > 0),
    DataPagamento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    MetodoPagamento VARCHAR(50) NOT NULL,
    StatoPagamento VARCHAR(20) NOT NULL CHECK (StatoPagamento IN ('Completato', 'Fallito', 'Rimborsato'))
);

-- Creazione delle tabelle di associazione e delle entità centrali

CREATE TABLE Itinerari (
    ItinerarioID SERIAL PRIMARY KEY,
    PrenotazioneID INTEGER NOT NULL REFERENCES Prenotazioni(PrenotazioneID) ON DELETE CASCADE,
    PasseggeroID INTEGER NOT NULL REFERENCES Passeggeri(PasseggeroID) ON DELETE CASCADE
);

CREATE TABLE SegmentiVolo (
    SegmentoVoloID SERIAL PRIMARY KEY,
    ItinerarioID INTEGER NOT NULL REFERENCES Itinerari(ItinerarioID) ON DELETE CASCADE,
    VoloID INTEGER NOT NULL REFERENCES Voli(VoloID) ON DELETE RESTRICT,
    TariffaID INTEGER NOT NULL REFERENCES Tariffe(TariffaID) ON DELETE RESTRICT,
    OrdineSegmento INTEGER NOT NULL,
    PrezzoBase NUMERIC(10, 2) NOT NULL CHECK (PrezzoBase >= 0),
    UNIQUE(ItinerarioID, OrdineSegmento)
);

CREATE TABLE Checkin (
    CheckinID SERIAL PRIMARY KEY,
    SegmentoVoloID INTEGER NOT NULL REFERENCES SegmentiVolo(SegmentoVoloID) ON DELETE CASCADE UNIQUE,
    DataCheckin TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PostoAssegnato VARCHAR(4) NOT NULL,
    TipoDocumento VARCHAR(50) NOT NULL,
    NumeroDocumento VARCHAR(50) NOT NULL
);

CREATE TABLE BenefitPasseggero (
    BenefitID SERIAL PRIMARY KEY,
    SegmentoVoloID INTEGER NOT NULL REFERENCES SegmentiVolo(SegmentoVoloID) ON DELETE CASCADE,
    ServizioID INTEGER NOT NULL REFERENCES Servizi(ServizioID) ON DELETE RESTRICT,
    Origine VARCHAR(20) NOT NULL CHECK (Origine IN ('Tariffa', 'Acquisto')),
    PrezzoPagato NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    Stato VARCHAR(20) NOT NULL DEFAULT 'Disponibile' CHECK (Stato IN ('Disponibile', 'Utilizzato', 'Cancellato'))
);

CREATE TABLE AssegnazioniEquipaggio (
    VoloID INTEGER NOT NULL REFERENCES Voli(VoloID) ON DELETE CASCADE,
    MembroEquipaggioID INTEGER NOT NULL REFERENCES Equipaggi(MembroEquipaggioID) ON DELETE CASCADE,
    PRIMARY KEY (VoloID, MembroEquipaggioID)
);

-- Creazione di indici per migliorare le performance delle query
CREATE INDEX idx_voli_partenza ON Voli(OrarioPartenzaPrevisto);
CREATE INDEX idx_segmenti_volo ON SegmentiVolo(VoloID);
CREATE INDEX idx_passeggeri_email ON Passeggeri(Email);
CREATE INDEX idx_itinerari_prenotazione_passeggero ON Itinerari(PrenotazioneID, PasseggeroID);
CREATE INDEX idx_benefit_segmento ON BenefitPasseggero(SegmentoVoloID);
