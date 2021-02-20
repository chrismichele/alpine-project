CREATE DATABASE `alpine`;

USE `alpine`;

CREATE TABLE `users` (
 `userID` int(11) NOT NULL AUTO_INCREMENT,
 `lastName` varchar(255) DEFAULT NULL,
 `firstName` varchar(255) DEFAULT NULL,
 `emailAddress` varchar(255) DEFAULT NULL,
 `password` varchar(255) NOT NULL,
 `isAdmin` tinyint(1) NOT NULL DEFAULT 0,
 `dateCreated` timestamp NOT NULL DEFAULT current_timestamp(),
 PRIMARY KEY (`userID`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1