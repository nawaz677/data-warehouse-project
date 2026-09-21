/*
	============== Database Initialization Script ===================

	Purpose :
		This script creates a new database from scratch.  
		Additionally three new schemas are created for the three
		layers. 
	Warning : 
		Running this script will drop and close all existing connections
		of 'data_warehouse' named database. 
*/


IF EXISTS (SELECT 1 FROM sys.databases WHERE NAME = 'data_warehouse')
BEGIN 
	ALTER DATABASE data_warehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE ;
	DROP DATABASE data_warehouse ;
END 
GO 

-- Creating a new database 
CREATE DATABASE data_warehouse ;
GO 

USE data_warehouse ;
GO 

-- Creating schemas 
CREATE SCHEMA bronze ;
GO 

CREATE SCHEMA silver ;
GO 

CREATE SCHEMA gold ;
GO 
