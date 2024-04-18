-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Creato il: Mar 02, 2018 alle 16:22
-- Versione del server: 5.7.17
-- Versione PHP: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `progetto_db`
--

-- --------------------------------------------------------

--
-- Struttura della tabella `attivita`
--

CREATE TABLE `attivita` (
  `Partita IVA` varchar(11) NOT NULL,
  `Nome` varchar(255) NOT NULL,
  `Descrizione` varchar(255) DEFAULT NULL,
  `Città` varchar(255) NOT NULL,
  `Via` varchar(255) NOT NULL,
  `Orario_apertura` time NOT NULL,
  `Orario_chiusura` time NOT NULL,
  `Giorni_lavorativi` varchar(255) NOT NULL,
  `telefono` varchar(10) DEFAULT NULL,
  `Sito` varchar(255) DEFAULT NULL,
  `Logo` varchar(255) DEFAULT NULL,
  `ID_CatAtt` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `attivita_vende_prodotti`
--

CREATE TABLE `attivita_vende_prodotti` (
  `P.iva` varchar(255) CHARACTER SET utf8 NOT NULL,
  `ID_Prod` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struttura della tabella `categoria_attivita`
--

CREATE TABLE `categoria_attivita` (
  `ID_CatAtt` int(11) NOT NULL,
  `Nome` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `categoria_prodotti`
--

CREATE TABLE `categoria_prodotti` (
  `ID_CatProd` int(11) NOT NULL,
  `nome` varchar(255) NOT NULL,
  `sconto` int(2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `cliente`
--

CREATE TABLE `cliente` (
  `email` varchar(255) NOT NULL,
  `nome_cognome` varchar(255) NOT NULL,
  `città` varchar(255) NOT NULL,
  `via` varchar(255) NOT NULL,
  `telefono` varchar(10) NOT NULL,
  `password` varchar(255) NOT NULL,
  `data_registrazione` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `metodi_di_pagamento_scelti`
--

CREATE TABLE `metodi_di_pagamento_scelti` (
  `ID_pagamento` int(11) NOT NULL,
  `P.Iva` varchar(10) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struttura della tabella `mod_pagamento`
--

CREATE TABLE `mod_pagamento` (
  `ID_Pag` int(11) NOT NULL,
  `mode` int(11) NOT NULL,
  `codice_versamento` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `ordini`
--

CREATE TABLE `ordini` (
  `data` datetime NOT NULL,
  `Prezzo_tot` double DEFAULT NULL,
  `mod_pag` int(11) NOT NULL,
  `service` int(11) NOT NULL,
  `cliente` varchar(255) NOT NULL,
  `venditore` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Trigger `ordini`
--
DELIMITER $$
CREATE TRIGGER `attivita_compra_da_se_stessa` BEFORE INSERT ON `ordini` FOR EACH ROW BEGIN
	IF (NEW.cliente = NEW.venditore) THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Non puoi vendere prodotti a te stesso';
	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `prezzo_totale` AFTER INSERT ON `ordini` FOR EACH ROW BEGIN
	DECLARE totale DOUBLE;
    SELECT SUM(prezzo) INTO totale FROM prodotti_ordinati, prodotti, ordini WHERE ordini.data = NEW.data AND ordini.cliente = 				NEW.cliente AND ordini.venditore = NEW.venditore AND ordini.data = prodotti_ordinati.data AND ordini.cliente = 						prodotti_ordinati.cliente AND ordini.venditore = prodotti_ordinati.vend AND prodotti.ID_prod = 										prodotti_ordinati.ID_prod ;
    
    UPDATE ordini SET Prezzo_tot = totale WHERE ordini.data = NEW.data AND ordini.cliente = NEW.cliente AND ordini.venditore = 					NEW.venditore;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `prodotti`
--

CREATE TABLE `prodotti` (
  `ID_prod` int(11) NOT NULL,
  `nome` varchar(255) NOT NULL,
  `prezzo` double NOT NULL,
  `disponibilita` int(11) NOT NULL,
  `sconto` int(2) DEFAULT NULL,
  `ID_CatProd` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `prodotti_ordinati`
--

CREATE TABLE `prodotti_ordinati` (
  `ID_prod` int(11) NOT NULL,
  `data` datetime NOT NULL,
  `cliente` varchar(255) CHARACTER SET utf8 NOT NULL,
  `vend` varchar(255) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struttura della tabella `recensioni`
--

CREATE TABLE `recensioni` (
  `Descrizione` varchar(255) NOT NULL,
  `Voto` int(11) NOT NULL,
  `ID_Cliente` varchar(255) NOT NULL,
  `ID_Att` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Trigger `recensioni`
--
DELIMITER $$
CREATE TRIGGER `permesso_recensioni` BEFORE INSERT ON `recensioni` FOR EACH ROW BEGIN  
  IF (NOT EXISTS (SELECT * FROM ordini WHERE cliente = NEW.ID_CLiente AND venditore = NEW.ID_Att)) 
THEN  
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Non puoi recensire un negozio da cui non hai effettuato acquisti';
END IF;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `voto_compreso` BEFORE INSERT ON `recensioni` FOR EACH ROW begin
    if (Voto NOT BETWEEN 1 AND 10) then
        SIGNAL SQLSTATE '45000'
      	SET MESSAGE_TEXT = 'An error occurred';
    end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `servizi`
--

CREATE TABLE `servizi` (
  `ID_Ser` int(11) NOT NULL,
  `Tipo` int(11) NOT NULL,
  `Prezzo` double DEFAULT NULL,
  `dettagli` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `servizi_offerti`
--

CREATE TABLE `servizi_offerti` (
  `ID_servizio` int(11) NOT NULL,
  `P.iva` varchar(10) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `attivita`
--
ALTER TABLE `attivita`
  ADD PRIMARY KEY (`Partita IVA`),
  ADD UNIQUE KEY `ID_CatAtt` (`ID_CatAtt`);

--
-- Indici per le tabelle `attivita_vende_prodotti`
--
ALTER TABLE `attivita_vende_prodotti`
  ADD PRIMARY KEY (`P.iva`,`ID_Prod`),
  ADD UNIQUE KEY `attivita_vende` (`P.iva`),
  ADD KEY `prodotto_venduto` (`ID_Prod`);

--
-- Indici per le tabelle `categoria_attivita`
--
ALTER TABLE `categoria_attivita`
  ADD PRIMARY KEY (`ID_CatAtt`);

--
-- Indici per le tabelle `categoria_prodotti`
--
ALTER TABLE `categoria_prodotti`
  ADD PRIMARY KEY (`ID_CatProd`);

--
-- Indici per le tabelle `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`email`);

--
-- Indici per le tabelle `metodi_di_pagamento_scelti`
--
ALTER TABLE `metodi_di_pagamento_scelti`
  ADD PRIMARY KEY (`ID_pagamento`,`P.Iva`),
  ADD KEY `attività_sceglie` (`P.Iva`),
  ADD KEY `pagamento_scelto` (`ID_pagamento`);

--
-- Indici per le tabelle `mod_pagamento`
--
ALTER TABLE `mod_pagamento`
  ADD PRIMARY KEY (`ID_Pag`);

--
-- Indici per le tabelle `ordini`
--
ALTER TABLE `ordini`
  ADD PRIMARY KEY (`data`,`cliente`,`venditore`),
  ADD UNIQUE KEY `service` (`service`),
  ADD UNIQUE KEY `mod_pag` (`mod_pag`),
  ADD KEY `cliente_effettua_ordine` (`cliente`);

--
-- Indici per le tabelle `prodotti`
--
ALTER TABLE `prodotti`
  ADD PRIMARY KEY (`ID_prod`),
  ADD UNIQUE KEY `ID_CatProd` (`ID_CatProd`);

--
-- Indici per le tabelle `prodotti_ordinati`
--
ALTER TABLE `prodotti_ordinati`
  ADD PRIMARY KEY (`ID_prod`,`data`,`cliente`,`vend`),
  ADD UNIQUE KEY `prodotto_in_ordine` (`ID_prod`),
  ADD KEY `ordine_contiene` (`data`,`cliente`,`vend`);

--
-- Indici per le tabelle `recensioni`
--
ALTER TABLE `recensioni`
  ADD PRIMARY KEY (`ID_Cliente`,`ID_Att`),
  ADD UNIQUE KEY `ID_Cliente` (`ID_Cliente`),
  ADD UNIQUE KEY `ID_Att` (`ID_Att`);

--
-- Indici per le tabelle `servizi`
--
ALTER TABLE `servizi`
  ADD PRIMARY KEY (`ID_Ser`);

--
-- Indici per le tabelle `servizi_offerti`
--
ALTER TABLE `servizi_offerti`
  ADD PRIMARY KEY (`ID_servizio`,`P.iva`),
  ADD KEY `attività_che_sceglie` (`P.iva`),
  ADD KEY `servizi_scelti` (`ID_servizio`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `categoria_attivita`
--
ALTER TABLE `categoria_attivita`
  MODIFY `ID_CatAtt` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT per la tabella `categoria_prodotti`
--
ALTER TABLE `categoria_prodotti`
  MODIFY `ID_CatProd` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT per la tabella `prodotti`
--
ALTER TABLE `prodotti`
  MODIFY `ID_prod` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT per la tabella `servizi`
--
ALTER TABLE `servizi`
  MODIFY `ID_Ser` int(11) NOT NULL AUTO_INCREMENT;
--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `attivita`
--
ALTER TABLE `attivita`
  ADD CONSTRAINT `categoria_attivita` FOREIGN KEY (`ID_CatAtt`) REFERENCES `categoria_attivita` (`ID_CatAtt`) ON UPDATE CASCADE;

--
-- Limiti per la tabella `attivita_vende_prodotti`
--
ALTER TABLE `attivita_vende_prodotti`
  ADD CONSTRAINT `attivita_vende` FOREIGN KEY (`P.iva`) REFERENCES `attivita` (`Partita IVA`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `prodotto_venduto` FOREIGN KEY (`ID_Prod`) REFERENCES `prodotti` (`ID_prod`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `metodi_di_pagamento_scelti`
--
ALTER TABLE `metodi_di_pagamento_scelti`
  ADD CONSTRAINT `attività_sceglie` FOREIGN KEY (`P.Iva`) REFERENCES `attivita` (`Partita IVA`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pagamento_scelto` FOREIGN KEY (`ID_pagamento`) REFERENCES `mod_pagamento` (`ID_Pag`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `ordini`
--
ALTER TABLE `ordini`
  ADD CONSTRAINT `attivita_effettua_ordine` FOREIGN KEY (`cliente`) REFERENCES `attivita` (`Partita IVA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `cliente_effettua_ordine` FOREIGN KEY (`cliente`) REFERENCES `cliente` (`email`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `pagamento_ordine` FOREIGN KEY (`mod_pag`) REFERENCES `mod_pagamento` (`ID_Pag`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `servizio_ordine` FOREIGN KEY (`service`) REFERENCES `servizi` (`ID_Ser`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limiti per la tabella `prodotti`
--
ALTER TABLE `prodotti`
  ADD CONSTRAINT `categoria_prodotto` FOREIGN KEY (`ID_CatProd`) REFERENCES `categoria_prodotti` (`ID_CatProd`) ON UPDATE CASCADE;

--
-- Limiti per la tabella `prodotti_ordinati`
--
ALTER TABLE `prodotti_ordinati`
  ADD CONSTRAINT `ordine_contiene` FOREIGN KEY (`data`,`cliente`,`vend`) REFERENCES `ordini` (`data`, `cliente`, `venditore`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `prodotto_in_ordine` FOREIGN KEY (`ID_prod`) REFERENCES `prodotti` (`ID_prod`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `recensioni`
--
ALTER TABLE `recensioni`
  ADD CONSTRAINT `riceve_recensioni` FOREIGN KEY (`ID_Att`) REFERENCES `attivita` (`Partita IVA`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `scrittura_recensioni` FOREIGN KEY (`ID_Cliente`) REFERENCES `cliente` (`email`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `servizi_offerti`
--
ALTER TABLE `servizi_offerti`
  ADD CONSTRAINT `attività_che_sceglie` FOREIGN KEY (`P.iva`) REFERENCES `attivita` (`Partita IVA`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `servizio_offerto` FOREIGN KEY (`ID_servizio`) REFERENCES `servizi` (`ID_Ser`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
