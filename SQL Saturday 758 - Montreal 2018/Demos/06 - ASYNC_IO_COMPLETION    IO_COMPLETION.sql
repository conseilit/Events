--==============================================================================
--
--  Summary:  SQLSaturday Montréal #758 - 2018
--  Date:     06/2018
--
--  ----------------------------------------------------------------------------
--  Written by Christophe LAPORTE, SQL Server MVP / MCM
--	Blog    : http://conseilit.wordpress.com
--	Twitter : @ConseilIT
--  
--  You may alter this code for your own *non-commercial* purposes. You may
--  republish altered code as long as you give due credit.
--  
--  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
--  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
--  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
--  PARTICULAR PURPOSE.
--==============================================================================



USE [master]
GO

SELECT * FROM sys.dm_exec_session_wait_stats WHERE session_id = @@spid
ORDER BY wait_time_ms DESC;
GO

CREATE DATABASE [DemoDB]
 ON  PRIMARY 
( NAME = N'DemoDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\DemoDB.mdf' , SIZE = 1GB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'DemoDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\DemoDB_log.ldf' , SIZE = 2GB , MAXSIZE = 2048GB , FILEGROWTH = 1024KB )
GO

-- ASYNC_IO_COMPLETION
SELECT * FROM sys.dm_exec_session_wait_stats WHERE session_id = @@spid
ORDER BY wait_time_ms DESC;
GO

CREATE TABLE [DemoDB].[dbo].[orders](
	[id] uniqueidentifier default NEWID() PRIMARY KEY CLUSTERED,
	[orderid] [int] NOT NULL,
	[custid] [char](11) NOT NULL,
	[empid] [int] NOT NULL,
	[shipperid] [varchar](5) NOT NULL,
	[orderdate] [datetime] NOT NULL,
	[filler] [char](155) NOT NULL
) ON [PRIMARY]
GO

-- new session
SELECT * FROM sys.dm_exec_session_wait_stats WHERE session_id = @@spid
ORDER BY wait_time_ms DESC;

INSERT INTO [DemoDB].dbo.orders ([orderid], [custid], [empid], [shipperid], [orderdate], [filler] ) 
SELECT [orderid], [custid], [empid], [shipperid], [orderdate], [filler] 
FROM Performance.dbo.Orders 
OPTION (MAXDOP 1)

-- IO_COMPLETION
SELECT * FROM sys.dm_exec_session_wait_stats WHERE session_id = @@spid
ORDER BY wait_time_ms DESC;


-- new session
SELECT * FROM sys.dm_exec_session_wait_stats WHERE session_id = @@spid
ORDER BY wait_time_ms DESC;

CHECKPOINT

-- PAGEIOLATCH_UP
SELECT * FROM sys.dm_exec_session_wait_stats WHERE session_id = @@spid
ORDER BY wait_time_ms DESC;



-- informations about LDF file (SQL14 +)
SELECT * 
FROM sys.dm_db_log_stats(db_id('DemoDB'))

SELECT * 
FROM sys.dm_db_log_info(db_id('DemoDB'))


USE [master]
GO

DROP DATABASE [DemoDB]
GO
