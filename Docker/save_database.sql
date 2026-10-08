/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.6.28-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: hopital
-- ------------------------------------------------------
-- Server version	10.6.28-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Admission`
--

DROP TABLE IF EXISTS `Admission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Admission` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Id_Patient` int(11) DEFAULT NULL,
  `Date_Admission` date DEFAULT NULL,
  `Date_Depart` date DEFAULT NULL,
  `Raison_Admission` varchar(200) DEFAULT NULL,
  `Chambre` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `Id_Patient` (`Id_Patient`),
  CONSTRAINT `Admission_ibfk_1` FOREIGN KEY (`Id_Patient`) REFERENCES `Patient` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Admission`
--

LOCK TABLES `Admission` WRITE;
/*!40000 ALTER TABLE `Admission` DISABLE KEYS */;
/*!40000 ALTER TABLE `Admission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Medecin`
--

DROP TABLE IF EXISTS `Medecin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Medecin` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Nom` varchar(50) DEFAULT NULL,
  `Prenom` varchar(50) DEFAULT NULL,
  `Specialite` varchar(50) DEFAULT NULL,
  `Contact` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Medecin`
--

LOCK TABLES `Medecin` WRITE;
/*!40000 ALTER TABLE `Medecin` DISABLE KEYS */;
/*!40000 ALTER TABLE `Medecin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Operation`
--

DROP TABLE IF EXISTS `Operation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Operation` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Id_Patient` int(11) DEFAULT NULL,
  `Id_Medecin` int(11) DEFAULT NULL,
  `Date` date DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `Id_Patient` (`Id_Patient`),
  KEY `Id_Medecin` (`Id_Medecin`),
  CONSTRAINT `Operation_ibfk_1` FOREIGN KEY (`Id_Patient`) REFERENCES `Patient` (`ID`),
  CONSTRAINT `Operation_ibfk_2` FOREIGN KEY (`Id_Medecin`) REFERENCES `Medecin` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Operation`
--

LOCK TABLES `Operation` WRITE;
/*!40000 ALTER TABLE `Operation` DISABLE KEYS */;
/*!40000 ALTER TABLE `Operation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Patient`
--

DROP TABLE IF EXISTS `Patient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Patient` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Nom` varchar(50) DEFAULT NULL,
  `Prenom` varchar(50) DEFAULT NULL,
  `Age` int(11) DEFAULT NULL,
  `Contact` varchar(50) DEFAULT NULL,
  `Groupe_Sanguin` varchar(3) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Patient`
--

LOCK TABLES `Patient` WRITE;
/*!40000 ALTER TABLE `Patient` DISABLE KEYS */;
/*!40000 ALTER TABLE `Patient` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RFID`
--

DROP TABLE IF EXISTS `RFID`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `RFID` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `id_carte` varchar(20) DEFAULT NULL,
  `Droits` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RFID`
--

LOCK TABLES `RFID` WRITE;
/*!40000 ALTER TABLE `RFID` DISABLE KEYS */;
/*!40000 ALTER TABLE `RFID` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-06 15:35:52
