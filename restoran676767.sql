-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: restaurant_db
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `menu`
--

DROP TABLE IF EXISTS `menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` int NOT NULL,
  `category` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu`
--

LOCK TABLES `menu` WRITE;
/*!40000 ALTER TABLE `menu` DISABLE KEYS */;
INSERT INTO `menu` VALUES (1,'Борщ',350,'Супы'),(2,'Паста Карбонара',550,'Горячее'),(3,'Стейк Рибай',1200,'Горячее'),(4,'Цезарь с курицей',450,'Салаты'),(5,'Кола',150,'Напитки'),(6,'Чизкейк',300,'Десерты');
/*!40000 ALTER TABLE `menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `dish_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES (1,1,'Паста Карбонара',1),(2,1,'Кола',1),(3,2,'Паста Карбонара',1),(4,2,'Стейк Рибай',1),(5,2,'Цезарь с курицей',1),(6,3,'Паста Карбонара',1),(7,3,'Стейк Рибай',1),(8,3,'Цезарь с курицей',1),(9,3,'Кола',1),(10,3,'Борщ',1),(11,4,'Чизкейк',1),(12,4,'Борщ',1),(13,4,'Цезарь с курицей',1),(14,4,'Стейк Рибай',1),(15,5,'Паста Карбонара',1),(16,5,'Стейк Рибай',1),(17,5,'Цезарь с курицей',1),(18,6,'Паста Карбонара',1),(19,6,'Цезарь с курицей',1),(20,6,'Борщ',1),(21,6,'Чизкейк',2),(22,7,'Стейк Рибай',1),(23,7,'Цезарь с курицей',1),(24,7,'Борщ',1),(25,7,'Чизкейк',2),(26,8,'Борщ',2),(27,8,'Цезарь с курицей',2),(28,8,'Стейк Рибай',1),(29,8,'Кола',1),(30,9,'Паста Карбонара',1),(31,9,'Кола',3),(32,9,'Цезарь с курицей',4),(33,9,'Стейк Рибай',1),(34,9,'Чизкейк',1),(35,9,'Борщ',5),(36,10,'Стейк Рибай',1),(37,10,'Цезарь с курицей',1),(38,10,'Борщ',1),(39,10,'Чизкейк',1),(40,11,'Цезарь с курицей',1),(41,11,'Кола',1),(42,11,'Паста Карбонара',1),(43,12,'Борщ',1),(44,12,'Цезарь с курицей',1),(45,12,'Стейк Рибай',1),(46,12,'Чизкейк',1),(47,13,'Борщ',1),(48,13,'Цезарь с курицей',1),(49,13,'Стейк Рибай',1),(50,13,'Паста Карбонара',1);
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `table_id` int NOT NULL,
  `order_datetime` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('открыт','закрыт') COLLATE utf8mb4_unicode_ci DEFAULT 'открыт',
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `table_id` (`table_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`table_id`) REFERENCES `tables` (`id`),
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,1,'2026-03-10 22:32:45','закрыт',1),(2,1,'2026-03-10 22:41:37','закрыт',NULL),(3,2,'2026-03-10 22:42:30','закрыт',NULL),(4,3,'2026-03-20 21:22:29','открыт',NULL),(5,1,'2026-03-24 22:31:17','открыт',NULL),(6,1,'2026-03-24 22:37:30','закрыт',NULL),(7,8,'2026-03-24 22:37:35','закрыт',NULL),(8,6,'2026-03-24 22:37:41','закрыт',NULL),(9,6,'2026-03-27 21:33:27','закрыт',1),(10,1,'2026-03-27 21:34:10','открыт',1),(11,3,'2026-03-27 21:34:14','открыт',1),(12,8,'2026-03-27 21:34:18','открыт',1),(13,4,'2026-03-27 21:34:21','открыт',1);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservations`
--

DROP TABLE IF EXISTS `reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `client_phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reservation_datetime` datetime NOT NULL,
  `table_id` int NOT NULL,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `table_id` (`table_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`table_id`) REFERENCES `tables` (`id`),
  CONSTRAINT `reservations_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservations`
--

LOCK TABLES `reservations` WRITE;
/*!40000 ALTER TABLE `reservations` DISABLE KEYS */;
INSERT INTO `reservations` VALUES (1,'Сачков Максим','sachkovmaksim886@gmail.com','2026-03-13 22:41:00',1,NULL),(2,'Иванов Иван','+7435435345','2026-03-14 22:41:00',2,NULL),(3,'Дима Хапов','dimasd@gmail.com','2026-03-25 22:34:00',1,NULL),(4,'Шульгина Полина','+7823495345','2026-03-27 22:34:00',6,NULL),(5,'Медведев Роман','medved@mail.ru','2026-03-27 22:34:00',8,NULL),(6,'Устинова Василиса','+7453534554','2026-03-30 22:34:00',4,NULL);
/*!40000 ALTER TABLE `reservations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dish_id` int NOT NULL,
  `client_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rating` int NOT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `dish_id` (`dish_id`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`dish_id`) REFERENCES `menu` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_chk_1` CHECK (((`rating` >= 1) and (`rating` <= 5)))
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
INSERT INTO `reviews` VALUES (1,6,'admin',5,'топчик','2026-03-13 20:52:45'),(2,3,'Гость',1,'не вкусно','2026-03-24 19:31:28'),(3,2,'Гость',2,'нашел волос в блюде ','2026-03-24 19:31:50'),(4,2,'Гость',5,'шикарное блюдо \n','2026-03-24 19:32:01'),(5,2,'Гость',4,'хорошее вкусное блюдо \n','2026-03-24 19:32:20'),(6,2,'Гость',3,'норм','2026-03-24 19:32:32'),(7,3,'Гость',5,'топчик\n','2026-03-24 19:32:40'),(8,6,'Гость',4,'было вкусно ','2026-03-24 19:32:54'),(9,5,'Гость',3,'обычная кола','2026-03-24 19:33:10'),(10,5,'Гость',2,'нет колы зеро','2026-03-24 19:33:20'),(11,4,'Гость',5,'вкусная курица','2026-03-24 19:33:32'),(12,1,'Гость',4,'хороший борщ, нормально мясо положили ','2026-03-24 19:34:15'),(13,3,'Гость',5,'топ','2026-03-27 18:20:23');
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tables`
--

DROP TABLE IF EXISTS `tables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tables` (
  `id` int NOT NULL AUTO_INCREMENT,
  `table_number` int NOT NULL,
  `status` enum('свободен','занят') COLLATE utf8mb4_unicode_ci DEFAULT 'свободен',
  PRIMARY KEY (`id`),
  UNIQUE KEY `table_number` (`table_number`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tables`
--

LOCK TABLES `tables` WRITE;
/*!40000 ALTER TABLE `tables` DISABLE KEYS */;
INSERT INTO `tables` VALUES (1,1,'занят'),(2,2,'свободен'),(3,3,'занят'),(4,4,'занят'),(5,5,'свободен'),(6,6,'свободен'),(7,7,'свободен'),(8,8,'занят');
/*!40000 ALTER TABLE `tables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('администратор','официант','менеджер','гость') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin123','администратор'),(2,'waiter','1234','официант');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-27 22:26:15
