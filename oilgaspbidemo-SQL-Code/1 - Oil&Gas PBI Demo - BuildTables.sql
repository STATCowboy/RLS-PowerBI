-- 
-- Oil & Gas SQL Server Security Demo 
-- by Jamey Johnston, @STATCowboy, http://www.jameyjohnston.com
-- 10/28/2015
-- 
-- No Warranty, use at your own risk, not affliated with where I work.
-- 


-- 
-- Create OILGASRLSDEMO
-- 

if( Exists( SELECT * FROM sys.databases WHERE name = 'oilgaspbidemo'))
	DROP DATABASE oilgaspbidemo
go

CREATE DATABASE oilgaspbidemo
go

USE oilgaspbidemo
go


--
-- Create Master Well Table
--

CREATE TABLE [WELL_MASTER](
	[WELL_ID] [int] NOT NULL,
	[WELL_NAME] [varchar](100) NULL,
	[DIVISION] [varchar](100) NULL,
	[REGION] [varchar](100) NULL,
	[ASSET_GROUP] [varchar](100) NULL,
	[ASSET_TEAM] [varchar](100) NULL,
	[PROD_YEAR] [varchar](4) NULL,
	[TVD] [float] NULL
)

GO

CREATE UNIQUE CLUSTERED INDEX [WELL_MASTER_IDX1] ON [WELL_MASTER] ([WELL_ID] ASC)
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX [WELL_MASTER_NCIDX1] ON [dbo].[WELL_MASTER]
(
	[DIVISION],
	[REGION],
	[ASSET_GROUP],
	[ASSET_TEAM]
)
GO



-- 
-- Create Well Daily Production Table
-- 

CREATE TABLE [WELL_DAILY_PROD](
	[WELL_ID] [int] NOT NULL,
	[DTE] [datetime2](7) NOT NULL,
	[OIL] [float] NULL,
	[GAS] [float] NULL,
	[NGL] [float] NULL
)

GO

CREATE CLUSTERED COLUMNSTORE INDEX [WELL_DAILY_PROD_CIDX1] ON [WELL_DAILY_PROD] WITH (DROP_EXISTING = OFF)
GO

ALTER TABLE WELL_DAILY_PROD ADD CONSTRAINT WELL_DAILY_PROD_FK
 FOREIGN KEY (WELL_ID) REFERENCES WELL_MASTER(WELL_ID);
GO


--
-- Well Downtime Reason Code
--

CREATE TABLE [WELL_REASON_CODE](
	[REASON_CODE] [int] NOT NULL,
	[REASON] [varchar] (50) NOT NULL
)

GO

CREATE UNIQUE CLUSTERED INDEX [WELL_REASON_CODE_IDX1] ON [dbo].[WELL_REASON_CODE] ([REASON_CODE] ASC)
GO


-- 
-- Create Well Downtime Table
-- 

CREATE TABLE [WELL_DOWNTIME](
	[WELL_ID] [int] NOT NULL,
	[DTE] [datetime2](7) NOT NULL, 
	[REASON_CODE] [int] NOT NULL,
	[HOURS] [int] NOT NULL
)

GO

CREATE UNIQUE CLUSTERED INDEX [WELL_DOWNTIME_IDX1] ON [WELL_DOWNTIME]
(
	[WELL_ID] ASC,
	[DTE] ASC,
	[REASON_CODE] ASC,
	[HOURS] ASC
)
GO


ALTER TABLE WELL_DOWNTIME ADD CONSTRAINT WELL_DOWNTIME_FK
 FOREIGN KEY (WELL_ID) REFERENCES WELL_MASTER(WELL_ID);
GO

ALTER TABLE WELL_DOWNTIME ADD CONSTRAINT WELL_REASON_CODE_FK2
 FOREIGN KEY (REASON_CODE) REFERENCES WELL_REASON_CODE(REASON_CODE);
GO


-- 
-- Asset Hierarchy Table
-- 

CREATE TABLE [ASSET_HIERARCHY](
	[ID] [int] NOT NULL,
	[DIVISION] [varchar](100) NOT NULL,
	[REGION] [varchar](100) NOT NULL,
	[ASSET_GROUP] [varchar](100) NOT NULL,
	[ASSET_TEAM] [varchar](100) NOT NULL
)
GO

CREATE UNIQUE CLUSTERED INDEX [ASSET_HIERARCHY_IDX1] ON [dbo].[ASSET_HIERARCHY] ([ID] ASC)
GO


-- 
-- Security Table for Asset Map entries to Org Unit IDs
-- 

CREATE TABLE [SEC_ASSET_MAP](
	[OU] [varchar](64) NULL,
	[HIERARCHY_NODE] [varchar](64) NULL,
	[HIERARCHY_VALUE] [varchar](64) NULL
)
GO

CREATE CLUSTERED INDEX [SEC_ASSET_MAP_IDX1] ON [dbo].[SEC_ASSET_MAP]
(
	[OU] ASC,
	[HIERARCHY_NODE] ASC,
	[HIERARCHY_VALUE] ASC
)
GO


-- 
-- Security Table Loaded with Employee Data
-- 

CREATE TABLE [SEC_ORG_USER_BASE](
	[EMPLID] [int] NOT NULL,
	[USERID] [varchar](12) NULL,
	[NAME] [varchar](50) NULL,
	[IS_EMPLOYEE] [varchar](1) NULL,
	[ORG_UNIT_ID] [int] NULL,
	[ORG_UNIT_NAME] [varchar](100) NULL,
	[MGRID] [int] NULL
)
GO

CREATE UNIQUE CLUSTERED INDEX [SEC_ORG_USER_BASE_IDX1] ON [dbo].[SEC_ORG_USER_BASE] ([EMPLID] ASC)
GO


-- 
-- Security Table to map User Exceptions to the Security
-- 

CREATE TABLE [SEC_USER_EXCEPTIONS](
	[USERID] [varchar](64) NULL,
	[HIERARCHY_NODE] [varchar](64) NULL,
	[HIERARCHY_VALUE] [varchar](64) NULL
)
GO

CREATE CLUSTERED INDEX [SEC_USER_EXCEPTIONS_IDX1] ON [dbo].[SEC_USER_EXCEPTIONS]
(
	[USERID] ASC,
	[HIERARCHY_NODE] ASC,
	[HIERARCHY_VALUE] ASC
)
GO


--
-- Date Table for Dimension
-- 

-- 
-- http://www.sqlbook.com/Data-Warehousing/Date-Dimension-SQL-script-18.aspx
-- 


CREATE TABLE [DATES] (
 [DateID] int NOT NULL IDENTITY(1, 1),
 [Date] datetime NOT NULL,
 [Year] int NOT NULL, 
 [Month] int NOT NULL,
 [Day] int NOT NULL,
 [QuarterNumber] int NOT NULL,
 CONSTRAINT PK_Dates PRIMARY KEY CLUSTERED (DateID)
)
GO
