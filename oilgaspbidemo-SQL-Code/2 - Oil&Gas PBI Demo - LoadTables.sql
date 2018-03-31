-- 
-- Oil & Gas SQL Server Security Demo 
-- by Jamey Johnston, @STATCowboy, http://www.jameyjohnston.com
-- 10/28/2015
-- 
-- No Warranty, use at your own risk, not affliated with where I work.
-- 


USE oilgaspbidemo
go

-- 
-- Load Asset Hierarchy Table
-- 

SET NOCOUNT ON;

INSERT INTO ASSET_HIERARCHY VALUES (1, 'US', 'NORTHERN US', 'PRB', 'PRB OPERATED');
INSERT INTO ASSET_HIERARCHY VALUES (2, 'US', 'NORTHERN US', 'PRB', 'PRB NON-OPERATED');
INSERT INTO ASSET_HIERARCHY VALUES (3, 'US', 'NORTHERN US', 'WATTENBERG', 'WATTENBERG OPERATED');
INSERT INTO ASSET_HIERARCHY VALUES (4, 'US', 'NORTHERN US', 'WATTENBERG', 'WATTENBERG NON-OPERATED');
INSERT INTO ASSET_HIERARCHY VALUES (5, 'US', 'SOUTHERN US', 'GULF OF MEXICO', 'TX GULF');
INSERT INTO ASSET_HIERARCHY VALUES (6, 'US', 'SOUTHERN US', 'GULF OF MEXICO', 'LA GULF');
INSERT INTO ASSET_HIERARCHY VALUES (7, 'US', 'SOUTHERN US', 'MAVERICK', 'MAVERICK OPERATED');
INSERT INTO ASSET_HIERARCHY VALUES (8, 'US', 'SOUTHERN US', 'MAVERICK', 'MAVERICK NON-OPERATED');
INSERT INTO ASSET_HIERARCHY VALUES (9, 'INTERNATIONAL', 'KENYA', 'KENYA', 'KENYA');
INSERT INTO ASSET_HIERARCHY VALUES (10, 'INTERNATIONAL', 'MOZAMBIQUE', 'MOZAMBIQUE', 'MOZAMBIQUE');
GO


-- 
-- Load WELL_MASTER Table
-- 

DECLARE 
  
  @i int = 0,
  @assetid int = 1,
  @assetlvl int = 10,
  @wellcount int = 100,
  @drillyearstart int = 1979,
  @drillyear int = 0,
  @TVDvalstart int = 5000,
  @TVDval int = 0;
  
WHILE @i < @wellcount
BEGIN
    SET @i = @i + 1;
	SET @assetid = CAST(RAND() * @assetlvl AS INT) + 1;
	SET @drillyear = @drillyearstart + CAST(RAND() * (cast(datepart(yyyy, getdate()) as int) - @drillyearstart) AS INT) + 1;
	SET @TVDval = @TVDvalstart + CAST(RAND() * 3000 AS INT);
	
	SET NOCOUNT ON;
	
    insert into [WELL_MASTER] values (@i, 
	                                  'WELL #' + cast(@i as varchar),
									  (select [DIVISION] from [ASSET_HIERARCHY] where id = @assetid),
									  (select [REGION] from [ASSET_HIERARCHY] where id = @assetid),
									  (select [ASSET_GROUP] from [ASSET_HIERARCHY] where id = @assetid),
									  (select [ASSET_TEAM] from [ASSET_HIERARCHY] where id = @assetid),
									  @drillyear,
									  @TVDval
	                                  );
END;
GO


-- 
-- Load WELL_DAILY_PROD TABLE
-- 

DECLARE

  @i int = 0,
  @wellcount int = 100,
  @cd datetime2(7)= getdate(),
  @nd datetime2(7) = getdate(),
  @oil int = 0,
  @gas int = 0,
  @ngl int = 0;

BEGIN
  WHILE @i < @wellcount 
  BEGIN
    SET @i = @i + 1;
    
	select @nd= CONVERT (datetime, '01/01/' + PROD_YEAR, 101) from WELL_MASTER where WELL_ID = @i;
	
	SET @oil = CAST(RAND() * 300 AS INT);
	SET @gas = CAST(RAND() * 300 AS INT);
	SET @ngl = CAST(RAND() * 10 AS INT);
	
    WHILE @nd < @cd 
	BEGIN
    	
		SET NOCOUNT ON;
		
		insert into [WELL_DAILY_PROD] values (@i,
                                              @nd,
                                              @oil + CAST(RAND() * 20 AS INT),
                                              @gas + CAST(RAND() * 20 AS INT),
                                              @ngl + CAST(RAND() * 3 AS INT)											  
		                                      );
		-- PRINT 'ND: ' + cast(@ND as varchar) + 'CD: ' + cast(@CD as varchar);
      SET @nd = DATEADD(DAY, 1, @nd);
    END;
  END;
END;
GO


-- CREATE UNIQUE CLUSTERED INDEX [WELL_DAILY_PROD_IDX1] ON [WELL_DAILY_PROD]([WELL_ID] ASC, [DTE] ASC)
-- GO

-- 
-- Load WELL_DOWNTIME TABLE and WELL_REASON_CODE
-- 

SET NOCOUNT ON;

insert into [WELL_REASON_CODE] values (1, 'Re-Complete');
insert into [WELL_REASON_CODE] values (2, 'Shut-in');
insert into [WELL_REASON_CODE] values (3, 'Equipmnet Failure');
GO


DECLARE

  @i int = 0,
  @wellcount int = 100,
  @cd datetime2(7)= getdate(),
  @nd datetime2(7) = getdate();

BEGIN
  WHILE @i < @wellcount 
  BEGIN
    SET @i = @i + 1;
    select @nd= CONVERT(datetime, CAST(CAST(RAND() * 12 AS INT) + 1 as varchar) + '/' + CAST(CAST(RAND() * 28 AS INT) + 1 as varchar) + '/' + PROD_YEAR, 101) from WELL_MASTER where WELL_ID = @i;
    WHILE @nd < @cd 
	BEGIN
    	
		SET NOCOUNT ON;
		
		insert into [WELL_DOWNTIME] values (@i,
                                              @nd,
                                              CAST(RAND() * 3 AS INT) + 1,
                                              CAST(RAND() * 24 AS INT) + 1											  
		                                      );
      SET @nd = CONVERT(datetime, CAST(CAST(RAND() * 12 AS INT) + 1 as varchar) + '/' + CAST(CAST(RAND() * 28 AS INT) + 1 as varchar) + '/' + CAST(YEAR(DATEADD(YEAR, 1, @nd)) AS VARCHAR(4)), 101);
    END;
  END;
END;
GO


-- 
-- Load SEC_ORG_USER_BASE with Employees
-- 

SET NOCOUNT ON;

insert into SEC_ORG_USER_BASE values (1001, 'dcampos', 'Dave Campos', 'Y', 100001, 'President/CEO', null); 
insert into SEC_ORG_USER_BASE values (1002, 'jblake', 'Jose Blake', 'Y', 100002, 'SVP/CFO', 1001); 
insert into SEC_ORG_USER_BASE values (1003, 'mcox', 'Mario Cox', 'Y', 100003, 'SVP/COO', 1001); 
insert into SEC_ORG_USER_BASE values (1004, 'jhapatish', 'Joachim Hapatish', 'Y', 100004, 'SVP/CIO', 1001); 
insert into SEC_ORG_USER_BASE values (1005, 'rsanchez', 'Raul Sanchez', 'Y', 100005, 'SVP/CAO', 1001); 
insert into SEC_ORG_USER_BASE values (1006, 'tmulberry', 'Tommy Mulberry', 'Y', 100006, 'VP - G&G', 1003); 
insert into SEC_ORG_USER_BASE values (1007, 'jwatts', 'Jean Watts', 'Y', 100007, 'VP - MARKETING', 1002); 
insert into SEC_ORG_USER_BASE values (1008, 'ivang', 'Ivonne Vang', 'Y', 100008, 'VP - E&P', 1003); 
insert into SEC_ORG_USER_BASE values (1009, 'ecross', 'Eric Cross', 'Y', 100009, 'VP - HR & FACILITIES', 1004); 
insert into SEC_ORG_USER_BASE values (1010, 'enash', 'Earl Nash', 'Y', 100010, 'DIRECTOR - GEOPHYSICS - NORTHERN US', 1006); 
insert into SEC_ORG_USER_BASE values (1011, 'ggaines', 'Gloria Gaines', 'Y', 100011, 'DIRECTOR - GEOPHYSICS - SOUTHERN US', 1006); 
insert into SEC_ORG_USER_BASE values (1012, 'hjames', 'Henry James', 'Y', 100012, 'DIRECTOR - GEOPHYSICS - INTL', 1006); 
insert into SEC_ORG_USER_BASE values (1013, 'spage', 'Susan Page', 'Y', 100013, 'DIRECTOR - GEOLOGY - NORTHERN US', 1006); 
insert into SEC_ORG_USER_BASE values (1014, 'fchadler', 'Francis Chadler', 'Y', 100014, 'DIRECTOR - GEOLOGY - SOUTHERN US', 1006); 
insert into SEC_ORG_USER_BASE values (1015, 'dhughes', 'Dalton Hughes', 'Y', 100015, 'DIRECTOR - GEOLOGY - INTL', 1006); 
insert into SEC_ORG_USER_BASE values (1016, 'jhahn', 'Jun Hahn', 'Y', 100016, 'DIRECTOR - OIL & GAS MARKETING - US', 1007); 
insert into SEC_ORG_USER_BASE values (1017, 'zcobb', 'Zachary Cobb', 'Y', 100017, 'DIRECTOR - OIL & GAS MARKETING - INTERNATIONAL', 1007); 
insert into SEC_ORG_USER_BASE values (1018, 'rgaines', 'Robert Gaines', 'Y', 100018, 'DIRECTOR - EXPLORATION - NORTHERN US', 1008); 
insert into SEC_ORG_USER_BASE values (1019, 'lvega', 'Larsen Vega', 'Y', 100019, 'DIRECTOR - EXPLORATION - SOUTHERN US', 1008); 
insert into SEC_ORG_USER_BASE values (1020, 'kmburu', 'Kamau Mburu', 'Y', 100020, 'DIRECTOR - EXPLORATION - INTL', 1008); 
insert into SEC_ORG_USER_BASE values (1021, 'rshah', 'Raziq Shah', 'Y', 100021, 'DIRECTOR - PRODUCTION - NORTHERN US', 1008); 
insert into SEC_ORG_USER_BASE values (1022, 'cleach', 'Caden Leach', 'Y', 100022, 'DIRECTOR - PRODUCTION - SOUTHERN US', 1008); 
insert into SEC_ORG_USER_BASE values (1023, 'adecker', 'Amelia Decker', 'Y', 100023, 'DIRECTOR - PRODUCTION - INTL', 1008); 
insert into SEC_ORG_USER_BASE values (1024, 'rwagner', 'Roger Wagner', 'Y', 100024, 'DIRECTOR - IT', 1004); 
insert into SEC_ORG_USER_BASE values (1025, 'ksmith', 'Kimberly Smith', 'Y', 100025, 'DIRECTOR - HR', 1009); 
insert into SEC_ORG_USER_BASE values (1026, 'mpeck', 'Mark Peck', 'Y', 100026, 'DIRECTOR - SECURITY', 1009); 
insert into SEC_ORG_USER_BASE values (1027, 'sshaffer', 'Simon Shaffer', 'Y', 100027, 'DIRECTOR - FACILITIES', 1009); 
insert into SEC_ORG_USER_BASE values (1028, 'mgomez', 'Myra Gomez', 'Y', 100028, 'MANAGER - GEOPHYSICS - PRB', 1010); 
insert into SEC_ORG_USER_BASE values (1029, 'ncervantes', 'Nelson Cervantes', 'Y', 100029, 'MANAGER - GEOPHYSICS - US - WATTENBERG', 1010); 
insert into SEC_ORG_USER_BASE values (1030, 'bowens', 'Billy Owens', 'Y', 100030, 'MANAGER - GEOPHYSICS - US - GULF OF MEXICO', 1011); 
insert into SEC_ORG_USER_BASE values (1031, 'rearl', 'Richey Earl', 'Y', 100031, 'MANAGER - GEOPHYSICS - US - MAVERICK', 1011); 
insert into SEC_ORG_USER_BASE values (1032, 'sjohns', 'Stefanie Johns', 'Y', 100032, 'MANAGER - GEOPHYSICS - KENYA', 1012); 
insert into SEC_ORG_USER_BASE values (1033, 'qrice', 'Quinn Rice', 'Y', 100033, 'MANAGER - GEOPHYSICS - MOZAMBIQUE', 1012); 
insert into SEC_ORG_USER_BASE values (1034, 'rjohnson', 'Robyn Johnson', 'Y', 100034, 'MANAGER - GEOLOGY - PRB', 1013); 
insert into SEC_ORG_USER_BASE values (1035, 'rshort', 'Reed Short', 'Y', 100035, 'MANAGER - GEOLOGY - WATTENBERG', 1013); 
insert into SEC_ORG_USER_BASE values (1036, 'ftroutmann', 'Fisher Troutmann', 'Y', 100036, 'MANAGER - GEOLOGY - GULF OF MEXICO', 1014); 
insert into SEC_ORG_USER_BASE values (1037, 'lhampton', 'Lance Hampton', 'Y', 100037, 'MANAGER - GEOLOGY - MAVERICK', 1014); 
insert into SEC_ORG_USER_BASE values (1038, 'schadler', 'Shelby Chadler', 'Y', 100038, 'MANAGER - GEOLOGY - KENYA', 1015); 
insert into SEC_ORG_USER_BASE values (1039, 'ryoung', 'Raney Young', 'Y', 100039, 'MANAGER - GEOLOGY - MOZAMBIQUE', 1015); 
insert into SEC_ORG_USER_BASE values (1040, 'ccalhoun', 'Clement Calhoun', 'Y', 100040, 'MANAGER - EXPLORATION - PRB', 1018); 
insert into SEC_ORG_USER_BASE values (1041, 'gpotts', 'Grayson Potts', 'Y', 100041, 'MANAGER - EXPLORATION - WATTENBERG', 1018); 
insert into SEC_ORG_USER_BASE values (1042, 'wkerry', 'Wyatt Kerry', 'Y', 100042, 'MANAGER - EXPLORATION - GULF OF MEXICO', 1019); 
insert into SEC_ORG_USER_BASE values (1043, 'lwhitehead', 'Levi Whitehead', 'Y', 100043, 'MANAGER - EXPLORATION - MAVERICK', 1019); 
insert into SEC_ORG_USER_BASE values (1044, 'rdean', 'Rich Dean', 'Y', 100044, 'MANAGER - EXPLORATION - KENYA', 1020); 
insert into SEC_ORG_USER_BASE values (1045, 'earnold', 'Ellie Arnold', 'Y', 100045, 'MANAGER - EXPLORATION - MOZAMBIQUE', 1020); 
insert into SEC_ORG_USER_BASE values (1046, 'ndavid', 'Nicole David', 'Y', 100046, 'MANAGER - PRODUCTION - PRB', 1021); 
insert into SEC_ORG_USER_BASE values (1047, 'kaustin', 'Kendall Austin', 'Y', 100047, 'MANAGER - PRODUCTION - WATTENBERG', 1021); 
insert into SEC_ORG_USER_BASE values (1048, 'jday', 'Jordyn Day', 'Y', 100048, 'MANAGER - PRODUCTION - GULF OF MEXICO', 1022); 
insert into SEC_ORG_USER_BASE values (1049, 'jfoley', 'Jackson Foley', 'Y', 100049, 'MANAGER - PRODUCTION - MAVERICK', 1022); 
insert into SEC_ORG_USER_BASE values (1050, 'cmartinez', 'Carlos Martinez', 'Y', 100050, 'MANAGER - PRODUCTION - KENYA', 1023); 
insert into SEC_ORG_USER_BASE values (1051, 'nhale', 'Nicholas Hale', 'Y', 100051, 'MANAGER - PRODUCTION - MOZAMBIQUE', 1023); 
insert into SEC_ORG_USER_BASE values (1052, 'tbuckley', 'Tracey Buckley', 'Y', 100052, 'MANAGER - IT - INFRASTRUCTURE', 1024); 
insert into SEC_ORG_USER_BASE values (1053, 'tfarley', 'Todd Farley', 'Y', 100053, 'MANAGER - IT - BUSINESS SYSTEMS', 1024); 
insert into SEC_ORG_USER_BASE values (1054, 'sbird', 'Sean Bird', 'Y', 100054, 'MANAGER - IT - E&P / G&G SYSTEMS', 1024); 
insert into SEC_ORG_USER_BASE values (1055, 'ccole', 'Claire Cole', 'Y', 100055, 'MANAGER - IT - CUSTOMER SUPPORT', 1024); 
insert into SEC_ORG_USER_BASE values (1056, 'kbradford', 'Kevin Bradford', 'Y', 100056, 'MANAGER - HR - BENEFITS', 1025); 
insert into SEC_ORG_USER_BASE values (1057, 'kbrady', 'Kenneth Brady', 'Y', 100057, 'MANAGER - HR - HIRING', 1025); 
insert into SEC_ORG_USER_BASE values (1058, 'ljames', 'Laura James', 'Y', 100058, 'SENIOR STAFF - GEOPHYSICS - PRB', 1028); 
insert into SEC_ORG_USER_BASE values (1059, 'ekane', 'Evan Kane', 'Y', 100059, 'SENIOR STAFF - GEOPHYSICS - PRB', 1028); 
insert into SEC_ORG_USER_BASE values (1060, 'cmason', 'Carter Mason', 'Y', 100060, 'SENIOR STAFF - GEOPHYSICS - WATTENBERG', 1029); 
insert into SEC_ORG_USER_BASE values (1061, 'lmays', 'Leah Mays', 'Y', 100061, 'SENIOR STAFF - GEOPHYSICS - WATTENBERG', 1029); 
insert into SEC_ORG_USER_BASE values (1062, 'amccall', 'Aaliyah McCall', 'Y', 100062, 'SENIOR STAFF - GEOPHYSICS - TX GULF', 1030); 
insert into SEC_ORG_USER_BASE values (1063, 'mneal', 'Makayla Neal', 'Y', 100063, 'SENIOR STAFF - GEOPHYSICS - LA GULF', 1030); 
insert into SEC_ORG_USER_BASE values (1064, 'mhobbs', 'Maya Hobbs', 'Y', 100064, 'SENIOR STAFF - GEOPHYSICS - MAVERICK', 1031); 
insert into SEC_ORG_USER_BASE values (1065, 'cherrera', 'Cameron Herrera', 'Y', 100065, 'SENIOR STAFF - GEOPHYSICS - MAVERICK', 1031); 
insert into SEC_ORG_USER_BASE values (1066, 'chardin', 'Catherine Hardin', 'Y', 100066, 'SENIOR STAFF - GEOPHYSICS - KENYA', 1032); 
insert into SEC_ORG_USER_BASE values (1067, 'mhouston', 'Miles Houston', 'Y', 100067, 'SENIOR STAFF - GEOPHYSICS - MOZAMBIQUE', 1033); 
insert into SEC_ORG_USER_BASE values (1068, 'rgothard', 'Regan Gothard', 'Y', 100068, 'SENIOR STAFF - GEOLOGY - PRB', 1034); 
insert into SEC_ORG_USER_BASE values (1069, 'dmolina', 'Dominic Molina', 'Y', 100069, 'SENIOR STAFF - GEOLOGY - PRB', 1034); 
insert into SEC_ORG_USER_BASE values (1070, 'cmerritt', 'Colin Merritt', 'Y', 100070, 'SENIOR STAFF - GEOLOGY - WATTENBERG', 1035); 
insert into SEC_ORG_USER_BASE values (1071, 'jnoble', 'Jeremiah Noble', 'Y', 100071, 'SENIOR STAFF - GEOLOGY - WATTENBERG', 1035); 
insert into SEC_ORG_USER_BASE values (1072, 'lortega', 'Lily Ortega', 'Y', 100072, 'SENIOR STAFF - GEOLOGY - TX GULF', 1036); 
insert into SEC_ORG_USER_BASE values (1073, 'arhodes', 'Audrey Rhodes', 'Y', 100073, 'SENIOR STAFF - GEOLOGY - LA GULF', 1036); 
insert into SEC_ORG_USER_BASE values (1074, 'jramos', 'Jasmine Ramos', 'Y', 100074, 'SENIOR STAFF - GEOLOGY - MAVERICK', 1037); 
insert into SEC_ORG_USER_BASE values (1075, 'npugh', 'Nevaeh Pugh', 'Y', 100075, 'SENIOR STAFF - GEOLOGY - MAVERICK', 1037); 
insert into SEC_ORG_USER_BASE values (1076, 'tmccall', 'Trey McCall', 'Y', 100076, 'SENIOR STAFF - GEOLOGY - KENYA', 1038); 
insert into SEC_ORG_USER_BASE values (1077, 'arojas', 'Aria Rojas', 'Y', 100077, 'SENIOR STAFF - GEOLOGY - MOZAMBIQUE', 1039); 
insert into SEC_ORG_USER_BASE values (1078, 'slin', 'Soo Lin', 'Y', 100078, 'SENIOR STAFF - O&G MARKETING - US', 1016); 
insert into SEC_ORG_USER_BASE values (1079, 'sgonzales', 'Selma Gonzales', 'Y', 100079, 'SENIOR STAFF - O&G MARKETING - INTL', 1017); 
insert into SEC_ORG_USER_BASE values (1080, 'jleblanc', 'Jean Leblanc', 'Y', 100080, 'SENIOR STAFF - EXPLORATION - PRB', 1040); 
insert into SEC_ORG_USER_BASE values (1081, 'aperez', 'Aria Perez', 'Y', 100081, 'SENIOR STAFF - EXPLORATION - PRB', 1040); 
insert into SEC_ORG_USER_BASE values (1082, 'gpineda', 'Gianna Pineda', 'Y', 100082, 'SENIOR STAFF - EXPLORATION - WATTENBERG', 1041); 
insert into SEC_ORG_USER_BASE values (1083, 'trasmussen', 'Thomas Rasmussen', 'Y', 100083, 'SENIOR STAFF - EXPLORATION - WATTENBERG', 1041); 
insert into SEC_ORG_USER_BASE values (1084, 'hsantos', 'Hadley Santos', 'Y', 100084, 'SENIOR STAFF - EXPLORATION - TX GULF', 1042); 
insert into SEC_ORG_USER_BASE values (1085, 'pmarks', 'Piper Marks', 'Y', 100085, 'SENIOR STAFF - EXPLORATION - LA GULF', 1042); 
insert into SEC_ORG_USER_BASE values (1086, 'smahoney', 'Stella Mahoney', 'Y', 100086, 'SENIOR STAFF - EXPLORATION - MAVERICK', 1043); 
insert into SEC_ORG_USER_BASE values (1087, 'klucero', 'Keira Lucero', 'Y', 100087, 'SENIOR STAFF - EXPLORATION - MAVERICK', 1043); 
insert into SEC_ORG_USER_BASE values (1088, 'jhogan', 'Joel Hogan', 'Y', 100088, 'SENIOR STAFF - EXPLORATION - KENYA', 1044); 
insert into SEC_ORG_USER_BASE values (1089, 'rkemp', 'Ryder Kemp', 'Y', 100089, 'SENIOR STAFF - EXPLORATION - MOZAMBIQUE', 1045); 
insert into SEC_ORG_USER_BASE values (1090, 'cwhitehead', 'Cherie Whitehead', 'Y', 100090, 'SENIOR STAFF - PRODUCTION - PRB', 1046); 
insert into SEC_ORG_USER_BASE values (1091, 'ckhan ', 'Callie Khan ', 'Y', 100091, 'SENIOR STAFF - PRODUCTION - PRB', 1046); 
insert into SEC_ORG_USER_BASE values (1092, 'jholt', 'Josiah Holt', 'Y', 100092, 'SENIOR STAFF - PRODUCTION - WATTENBERG', 1047); 
insert into SEC_ORG_USER_BASE values (1093, 'nhuff', 'Nolan Huff', 'Y', 100093, 'SENIOR STAFF - PRODUCTION - WATTENBERG', 1047); 
insert into SEC_ORG_USER_BASE values (1094, 'imoody', 'Ian Moody', 'Y', 100094, 'SENIOR STAFF - PRODUCTION - TX GULF', 1048); 
insert into SEC_ORG_USER_BASE values (1095, 'cmcpherson', 'Colton McPherson', 'Y', 100095, 'SENIOR STAFF - PRODUCTION - LA GULF', 1048); 
insert into SEC_ORG_USER_BASE values (1096, 'mking', 'Mace King', 'Y', 100096, 'SENIOR STAFF - PRODUCTION - MAVERICK', 1049); 
insert into SEC_ORG_USER_BASE values (1097, 'ojoyce', 'Oliver Joyce', 'Y', 100097, 'SENIOR STAFF - PRODUCTION - MAVERICK', 1049); 
insert into SEC_ORG_USER_BASE values (1098, 'wdavidson', 'Wendy Davidson', 'Y', 100098, 'SENIOR STAFF - PRODUCTION - KENYA', 1050); 
insert into SEC_ORG_USER_BASE values (1099, 'across', 'Ava Cross', 'Y', 100099, 'SENIOR STAFF - PRODUCTION - MOZAMBIQUE', 1051); 
insert into SEC_ORG_USER_BASE values (1100, 'sbeard', 'Sean Beard', 'Y', 100100, 'SENIOR STAFF - IT - INFRASTRUCTURE', 1052); 
insert into SEC_ORG_USER_BASE values (1101, 'msampson', 'Michael Sampson', 'Y', 100101, 'SENIOR STAFF - IT - BUSINESS SYSTEMS', 1053); 
insert into SEC_ORG_USER_BASE values (1102, 'pduarte', 'Phil Duarte', 'Y', 100102, 'SENIOR STAFF - IT - E&P / G&G SYSTEMS', 1054); 
insert into SEC_ORG_USER_BASE values (1103, 'lcabrera', 'Luke Cabrera', 'Y', 100103, 'SENIOR STAFF - IT - CUSTOMER SUPPORT', 1055); 
insert into SEC_ORG_USER_BASE values (1104, 'amorgan', 'Alex Morgan', 'Y', 100104, 'SENIOR STAFF - HR - BENEFITS', 1056); 
insert into SEC_ORG_USER_BASE values (1105, 'mhamilton', 'Mia Hamilton', 'Y', 100105, 'SENIOR STAFF - HR - HIRING', 1057); 
insert into SEC_ORG_USER_BASE values (1106, 'ldonaldson', 'Landon Donaldson', 'Y', 100106, 'SENIOR STAFF - SECURITY', 1026); 
insert into SEC_ORG_USER_BASE values (1107, 'tquinn', 'Tim Quinn', 'Y', 100107, 'SENIOR STAFF - FACILITIES', 1027); 
insert into SEC_ORG_USER_BASE values (1108, 'abuchanan', 'Al Buchanan', 'Y', 100108, 'STAFF - GEOPHYSICS - PRB', 1028); 
insert into SEC_ORG_USER_BASE values (1109, 'mcline', 'Madelyn Cline', 'Y', 100109, 'STAFF - GEOPHYSICS - PRB', 1028); 
insert into SEC_ORG_USER_BASE values (1110, 'hfox', 'Hailey Fox', 'Y', 100110, 'STAFF - GEOPHYSICS - WATTENBERG', 1029); 
insert into SEC_ORG_USER_BASE values (1111, 'ldominguez', 'Layla Dominguez', 'Y', 100111, 'STAFF - GEOPHYSICS - WATTENBERG', 1029); 
insert into SEC_ORG_USER_BASE values (1112, 'achaney', 'Arianna Chaney', 'Y', 100112, 'STAFF - GEOPHYSICS - TX GULF', 1030); 
insert into SEC_ORG_USER_BASE values (1113, 'sbonilla', 'Savannah Bonilla', 'Y', 100113, 'STAFF - GEOPHYSICS - LA GULF', 1030); 
insert into SEC_ORG_USER_BASE values (1114, 'hblankenship', 'Harper Blankenship', 'Y', 100114, 'STAFF - GEOPHYSICS - MAVERICK', 1031); 
insert into SEC_ORG_USER_BASE values (1115, 'sjefferson', 'Scarlett Jefferson', 'Y', 100115, 'STAFF - GEOPHYSICS - MAVERICK', 1031); 
insert into SEC_ORG_USER_BASE values (1116, 'jcarpenter', 'James Carpenter', 'Y', 100116, 'STAFF - GEOPHYSICS - KENYA', 1032); 
insert into SEC_ORG_USER_BASE values (1117, 'arivas', 'Annabelle Rivas', 'Y', 100117, 'STAFF - GEOPHYSICS - MOZAMBIQUE', 1033); 
insert into SEC_ORG_USER_BASE values (1118, 'dchoi', 'Don Choi', 'N', 100118, 'STAFF - GEOLOGY - PRB', 1034); 
insert into SEC_ORG_USER_BASE values (1119, 'cprince', 'Christian Prince', 'N', 100119, 'STAFF - GEOLOGY - PRB', 1034); 
insert into SEC_ORG_USER_BASE values (1120, 'npeck', 'Noah Peck', 'N', 100120, 'STAFF - GEOLOGY - WATTENBERG', 1035); 
insert into SEC_ORG_USER_BASE values (1121, 'owagner', 'Owen Wagner', 'N', 100121, 'STAFF - GEOLOGY - WATTENBERG', 1035); 
insert into SEC_ORG_USER_BASE values (1122, 'lweiss', 'Landon Weiss', 'N', 100122, 'STAFF - GEOLOGY - TX GULF', 1036); 
insert into SEC_ORG_USER_BASE values (1123, 'mweaver', 'Max Weaver', 'N', 100123, 'STAFF - GEOLOGY - LA GULF', 1036); 
insert into SEC_ORG_USER_BASE values (1124, 'tvelez', 'Tristan Velez', 'N', 100124, 'STAFF - GEOLOGY - MAVERICK', 1037); 
insert into SEC_ORG_USER_BASE values (1125, 'ctrujillo', 'Chase Trujillo', 'N', 100125, 'STAFF - GEOLOGY - MAVERICK', 1037); 
insert into SEC_ORG_USER_BASE values (1126, 'gfritz', 'Grant Fritz', 'Y', 100126, 'STAFF - GEOLOGY - KENYA', 1038); 
insert into SEC_ORG_USER_BASE values (1127, 'bschwartz', 'Blake Schwartz', 'Y', 100127, 'STAFF - GEOLOGY - MOZAMBIQUE', 1039); 
insert into SEC_ORG_USER_BASE values (1128, 'klove', 'Karen Love', 'Y', 100128, 'STAFF - O&G MARKETING - US', 1016); 
insert into SEC_ORG_USER_BASE values (1129, 'kterry', 'Kerry Terry', 'Y', 100129, 'STAFF - O&G MARKETING - INTL', 1017); 
insert into SEC_ORG_USER_BASE values (1130, 'ayang', 'Andy Yang', 'Y', 100130, 'STAFF - EXPLORATION - PRB', 1040); 
insert into SEC_ORG_USER_BASE values (1131, 'asexton', 'Asher Sexton', 'Y', 100131, 'STAFF - EXPLORATION - PRB', 1040); 
insert into SEC_ORG_USER_BASE values (1132, 'hsellers', 'Hudson Sellers', 'Y', 100132, 'STAFF - EXPLORATION - WATTENBERG', 1041); 
insert into SEC_ORG_USER_BASE values (1133, 'bpoole', 'Bella Poole', 'Y', 100133, 'STAFF - EXPLORATION - WATTENBERG', 1041); 
insert into SEC_ORG_USER_BASE values (1134, 'nphillips', 'Natalie Phillips', 'Y', 100134, 'STAFF - EXPLORATION - TX GULF', 1042); 
insert into SEC_ORG_USER_BASE values (1135, 'smoran', 'Sumnmer Moran', 'Y', 100135, 'STAFF - EXPLORATION - LA GULF', 1042); 
insert into SEC_ORG_USER_BASE values (1136, 'lluna', 'Lila Luna', 'Y', 100136, 'STAFF - EXPLORATION - MAVERICK', 1043); 
insert into SEC_ORG_USER_BASE values (1137, 'vhood', 'Violet Hood', 'Y', 100137, 'STAFF - EXPLORATION - MAVERICK', 1043); 
insert into SEC_ORG_USER_BASE values (1138, 'mferguson', 'Mindy Ferguson', 'Y', 100138, 'STAFF - EXPLORATION - KENYA', 1044); 
insert into SEC_ORG_USER_BASE values (1139, 'kglass', 'Kylie Glass', 'Y', 100139, 'STAFF - EXPLORATION - MOZAMBIQUE', 1045); 
insert into SEC_ORG_USER_BASE values (1140, 'jstark', 'Jen Stark', 'Y', 100140, 'STAFF - PRODUCTION - PRB', 1046); 
insert into SEC_ORG_USER_BASE values (1141, 'pgilbert', 'Paige Gilbert', 'Y', 100141, 'STAFF - PRODUCTION - PRB', 1046); 
insert into SEC_ORG_USER_BASE values (1142, 'cfinley', 'Cam Finley', 'Y', 100142, 'STAFF - PRODUCTION - WATTENBERG', 1047); 
insert into SEC_ORG_USER_BASE values (1143, 'dbray', 'Drew Bray', 'Y', 100143, 'STAFF - PRODUCTION - WATTENBERG', 1047); 
insert into SEC_ORG_USER_BASE values (1144, 'jlove', 'Jerrell Love', 'Y', 100144, 'STAFF - PRODUCTION - TX GULF', 1048); 
insert into SEC_ORG_USER_BASE values (1145, 'omacias', 'Olga Macias', 'Y', 100145, 'STAFF - PRODUCTION - LA GULF', 1048); 
insert into SEC_ORG_USER_BASE values (1146, 'nlivingston', 'Nick Livingston', 'Y', 100146, 'STAFF - PRODUCTION - MAVERICK', 1049); 
insert into SEC_ORG_USER_BASE values (1147, 'tmayo', 'Thomas Mayo', 'Y', 100147, 'STAFF - PRODUCTION - MAVERICK', 1049); 
insert into SEC_ORG_USER_BASE values (1148, 'cmejia', 'Carmen Mejia', 'Y', 100148, 'STAFF - PRODUCTION - KENYA', 1050); 
insert into SEC_ORG_USER_BASE values (1149, 'lmercado', 'Lauren  Mercado', 'Y', 100149, 'STAFF - PRODUCTION - MOZAMBIQUE', 1051); 
insert into SEC_ORG_USER_BASE values (1150, 'psteen', 'Phyllis Steen', 'Y', 100150, 'STAFF - IT - INFRASTRUCTURE', 1052); 
insert into SEC_ORG_USER_BASE values (1151, 'mmoreno', 'Mickey Moreno', 'N', 100151, 'STAFF - IT - BUSINESS SYSTEMS', 1053); 
insert into SEC_ORG_USER_BASE values (1152, 'tclaire', 'Tamera Claire', 'Y', 100152, 'STAFF - IT - E&P / G&G SYSTEMS', 1054); 
insert into SEC_ORG_USER_BASE values (1153, 'fvaldez', 'Fillipa Valdez', 'Y', 100153, 'STAFF - IT - CUSTOMER SUPPORT', 1055); 
insert into SEC_ORG_USER_BASE values (1154, 'hhays', 'Hope Hays', 'Y', 100154, 'STAFF - HR - BENEFITS', 1056); 
insert into SEC_ORG_USER_BASE values (1155, 'mlomax', 'Melissa Lomax', 'Y', 100155, 'STAFF - HR - HIRING', 1057); 
insert into SEC_ORG_USER_BASE values (1156, 'jcampbell', 'Jared Campbell', 'Y', 100156, 'STAFF - SECURITY', 1026); 
insert into SEC_ORG_USER_BASE values (1157, 'cfrey', 'Cher Frey', 'N', 100157, 'STAFF - FACILITIES', 1027); 


-- 
-- Load SEC_ASSET_MAP Table with Security Level Entries based on Asset Hierarchy 
-- 

SET NOCOUNT ON;

insert into [SEC_ASSET_MAP] values (100001, 'ALL', 'ALL');
insert into [SEC_ASSET_MAP] values (100009, 'NONE', 'NONE');
insert into [SEC_ASSET_MAP] values (100010, 'REGION', 'NORTHERN US');
insert into [SEC_ASSET_MAP] values (100011, 'REGION', 'SOUTHERN US');
insert into [SEC_ASSET_MAP] values (100012, 'DIVISION', 'INTERNATIONAL');
insert into [SEC_ASSET_MAP] values (100013, 'REGION', 'NORTHERN US');
insert into [SEC_ASSET_MAP] values (100014, 'REGION', 'SOUTHERN US');
insert into [SEC_ASSET_MAP] values (100015, 'DIVISION', 'INTERNATIONAL');
insert into [SEC_ASSET_MAP] values (100016, 'DIVISION', 'US');
insert into [SEC_ASSET_MAP] values (100017, 'DIVISION', 'INTERNATIONAL');
insert into [SEC_ASSET_MAP] values (100018, 'REGION', 'NORTHERN US');
insert into [SEC_ASSET_MAP] values (100019, 'REGION', 'SOUTHERN US');
insert into [SEC_ASSET_MAP] values (100020, 'DIVISION', 'INTERNATIONAL');
insert into [SEC_ASSET_MAP] values (100021, 'REGION', 'NORTHERN US');
insert into [SEC_ASSET_MAP] values (100022, 'REGION', 'SOUTHERN US');
insert into [SEC_ASSET_MAP] values (100023, 'DIVISION', 'INTERNATIONAL');
insert into [SEC_ASSET_MAP] values (100024, 'NONE', 'NONE');
insert into [SEC_ASSET_MAP] values (100028, 'ASSET_GROUP', 'PRB');
insert into [SEC_ASSET_MAP] values (100029, 'ASSET_GROUP', 'WATTENBERG');
insert into [SEC_ASSET_MAP] values (100030, 'ASSET_GROUP', 'GULF OF MEXICO');
insert into [SEC_ASSET_MAP] values (100031, 'ASSET_GROUP', 'MAVERICK');
insert into [SEC_ASSET_MAP] values (100032, 'ASSET_GROUP', 'KENYA');
insert into [SEC_ASSET_MAP] values (100033, 'ASSET_GROUP', 'MOZAMBIQUE');
insert into [SEC_ASSET_MAP] values (100034, 'ASSET_GROUP', 'PRB');
insert into [SEC_ASSET_MAP] values (100035, 'ASSET_GROUP', 'WATTENBERG');
insert into [SEC_ASSET_MAP] values (100036, 'ASSET_GROUP', 'GULF OF MEXICO');
insert into [SEC_ASSET_MAP] values (100037, 'ASSET_GROUP', 'MAVERICK');
insert into [SEC_ASSET_MAP] values (100038, 'ASSET_GROUP', 'KENYA');
insert into [SEC_ASSET_MAP] values (100039, 'ASSET_GROUP', 'MOZAMBIQUE');
insert into [SEC_ASSET_MAP] values (100040, 'ASSET_GROUP', 'PRB');
insert into [SEC_ASSET_MAP] values (100041, 'ASSET_GROUP', 'WATTENBERG');
insert into [SEC_ASSET_MAP] values (100042, 'ASSET_GROUP', 'GULF OF MEXICO');
insert into [SEC_ASSET_MAP] values (100043, 'ASSET_GROUP', 'MAVERICK');
insert into [SEC_ASSET_MAP] values (100044, 'ASSET_GROUP', 'KENYA');
insert into [SEC_ASSET_MAP] values (100045, 'ASSET_GROUP', 'MOZAMBIQUE');
insert into [SEC_ASSET_MAP] values (100046, 'ASSET_GROUP', 'PRB');
insert into [SEC_ASSET_MAP] values (100047, 'ASSET_GROUP', 'WATTENBERG');
insert into [SEC_ASSET_MAP] values (100048, 'ASSET_GROUP', 'GULF OF MEXICO');
insert into [SEC_ASSET_MAP] values (100049, 'ASSET_GROUP', 'MAVERICK');
insert into [SEC_ASSET_MAP] values (100050, 'ASSET_GROUP', 'KENYA');
insert into [SEC_ASSET_MAP] values (100051, 'ASSET_GROUP', 'MOZAMBIQUE');
insert into [SEC_ASSET_MAP] values (100062, 'ASSET_TEAM', 'TX GULF');
insert into [SEC_ASSET_MAP] values (100063, 'ASSET_TEAM', 'LA GULF');
insert into [SEC_ASSET_MAP] values (100084, 'ASSET_TEAM', 'TX GULF');
insert into [SEC_ASSET_MAP] values (100085, 'ASSET_TEAM', 'LA GULF');
insert into [SEC_ASSET_MAP] values (100094, 'ASSET_TEAM', 'TX GULF');
insert into [SEC_ASSET_MAP] values (100095, 'ASSET_TEAM', 'LA GULF');
insert into [SEC_ASSET_MAP] values (100112, 'ASSET_TEAM', 'TX GULF');
insert into [SEC_ASSET_MAP] values (100113, 'ASSET_TEAM', 'LA GULF');
insert into [SEC_ASSET_MAP] values (100122, 'ASSET_TEAM', 'TX GULF');
insert into [SEC_ASSET_MAP] values (100123, 'ASSET_TEAM', 'LA GULF');
insert into [SEC_ASSET_MAP] values (100134, 'ASSET_TEAM', 'TX GULF');
insert into [SEC_ASSET_MAP] values (100135, 'ASSET_TEAM', 'LA GULF');
insert into [SEC_ASSET_MAP] values (100144, 'ASSET_TEAM', 'TX GULF');
insert into [SEC_ASSET_MAP] values (100145, 'ASSET_TEAM', 'LA GULF');
insert into [SEC_ASSET_MAP] values (100135, 'ASSET_TEAM', 'TX GULF');
insert into [SEC_ASSET_MAP] values (100145, 'ASSET_TEAM', 'TX GULF');


-- 
-- Load SEC_USER_EXCEPTIONS Table with User Exceptions to Asset based security 
-- 

SET NOCOUNT ON;

DELETE [SEC_USER_EXCEPTIONS];
GO
insert into [SEC_USER_EXCEPTIONS] values ('sbird', 'ALL', 'ALL');
insert into [SEC_USER_EXCEPTIONS] values ('ldonaldson', 'ALL', 'ALL');
insert into [SEC_USER_EXCEPTIONS] values ('jcampbell', 'ALL', 'ALL');
-- 
-- Insert Authorized Well Creation Users
-- 
insert into [SEC_USER_EXCEPTIONS] values ('ivang', 'WELLAUTH', 'WELLAUTH');
insert into [SEC_USER_EXCEPTIONS] values ('rgaines', 'WELLAUTH', 'WELLAUTH');
insert into [SEC_USER_EXCEPTIONS] values ('lvega', 'WELLAUTH', 'WELLAUTH');
insert into [SEC_USER_EXCEPTIONS] values ('kmburu', 'WELLAUTH', 'WELLAUTH');


-- 
-- Load Date Dimension Table
--

-- declare variables to hold the start and end date
DECLARE @StartDate datetime
DECLARE @EndDate datetime

--- assign values to the start date and end date we 
-- want our reports to cover (this should also take
-- into account any future reporting needs)
SET @StartDate = '01/01/1960';
SET @EndDate = getdate(); 

-- using a while loop increment from the start date 
-- to the end date
DECLARE @LoopDate datetime
SET @LoopDate = @StartDate

WHILE @LoopDate <= @EndDate
BEGIN
 -- add a record into the date dimension table for this date
 
 SET NOCOUNT ON;
 
 INSERT INTO Dates VALUES (
  @LoopDate,
  Year(@LoopDate),
  Month(@LoopDate), 
  Day(@LoopDate), 
  CASE WHEN Month(@LoopDate) IN (1, 2, 3) THEN 1
   WHEN Month(@LoopDate) IN (4, 5, 6) THEN 2
   WHEN Month(@LoopDate) IN (7, 8, 9) THEN 3
   WHEN Month(@LoopDate) IN (10, 11, 12) THEN 4
  END 
   
 )  
 
 -- increment the LoopDate by 1 day before
 -- we start the loop again
 SET @LoopDate = DateAdd(d, 1, @LoopDate)
END;
GO


