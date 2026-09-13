/*  =============== Purpose of the Script ==================
	The purpose of this script is to drop old/already existing database named
	data_warehouse and create a fresh on from scratch. The script also creates
	three schemas for the three layers of medallion arhcitecture namely the 
	bronze, silver and gold layers.

	======= Warning!! =========
	Please backup your data if its essential for you because after running this
	script all the old data/schemas everything from the old database will be 
	deleted...
*/


use master ;
go

if exists (select 1 from sys.databases where name = 'data_warehouse')
begin 
		alter database data_warehouse set single_user with rollback immediate
		drop database data_warehouse
end 

create database data_warehouse ;
go 

use data_warehouse ; 
go 

create schema bronze ; 
go 
create schema silver ;
go 
create schema gold ;
go 


