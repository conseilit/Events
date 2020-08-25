
/*
m_freedata and pagelatch pour insert
traque la fin du dernier enregistrement dans la page
le latch sert à vérouiller l'netete pour qu e2 insert ne se fassent pas au même endroit
*/


/*============================================================================
  File    :  Latch   
  Summary :  
  Date    :  11/2015
  SQL Server Versions: 13 (SS2016CTP3)
------------------------------------------------------------------------------
  Written by Christophe LAPORTE, SQL Server MVP / MCM
	Blog    : http://conseilit.wordpress.com
	Twitter : @ConseilIT
  
  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you give due credit.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

	
USE JSS2015Demo
GO

DROP TABLE IF EXISTS [dbo].[PageLatchDemo]
GO

CREATE TABLE dbo.PageLatchDemo
(
	 PageLatchDemoID INT IDENTITY (1,1)
	,FillerData CHAR(89)  -- to have exactly 100 octets / record
	,CONSTRAINT PK_PageLatchDemo_PageLatchDemoID 
	 PRIMARY KEY CLUSTERED (PageLatchDemoID)
)
GO

INSERT INTO PageLatchDemo
DEFAULT VALUES;

DBCC IND(JSS2015Demo,PageLatchDemo,-1)

DBCC TRACEON(3604)
DBCC PAGE (JSS2015Demo,3,21752,3)
/*
Slot 0 Offset 0x60 Length 100
Record Type = PRIMARY_RECORD        Record Attributes =  NULL_BITMAP    Record Size = 100
Memory Dump @0x000000C49BDBA060
0000000000000000:   10006100 01000000 00000000 00000000 feffffff  ..a.............þÿÿÿ
0000000000000014:   ffffffff 80a17d76 c1000000 c04e8da9 c1000000  ÿÿÿÿ.¡}vÁ...ÀN.©Á...
0000000000000028:   eb95da74 f97f0000 00020000 00000000 3596da74  ë?Útù...........5?Út
000000000000003C:   f97f0000 00408da9 c1000000 a9e45b93 c4000000  ù....@.©Á...©ä[?Ä...
0000000000000050:   feffffff ffffffff 371bea6d f97f0000 d0020002  þÿÿÿÿÿÿÿ7.êmù...Ð...
Slot 0 Column 1 Offset 0x4 Length 4 Length (physical) 4
PageLatchDemoID = 1                 
Slot 0 Column 2 Offset 0x0 Length 0 Length (physical) 0
FillerData = [NULL]                 
Slot 0 Offset 0x0 Length 0 Length (physical) 0
KeyHashValue = (8194443284a0)       
*/

/*
Offset 0x60 => Dec 96
Length 100
=> Next record at offset 196

Page header :

m_pageId = (3:21752)                m_headerVersion = 1                 m_type = 1
m_typeFlagBits = 0x0                m_level = 0                         m_flagBits = 0xc000
m_objId (AllocUnitId.idObj) = 251   m_indexId (AllocUnitId.idInd) = 256 
Metadata: AllocUnitId = 72057594054377472                                
Metadata: PartitionId = 72057594048806912                                Metadata: IndexId = 1
Metadata: ObjectId = 1362103893     m_prevPage = (0:0)                  m_nextPage = (0:0)
pminlen = 97                        m_slotCnt = 1                       m_freeCnt = 7994
m_freeData = 196                    m_reservedCnt = 0                   m_lsn = (51:232:64)
m_xactReserved = 0                  m_xdesId = (0:0)                    m_ghostRecCnt = 0
m_tornBits = 0                      DB Frag ID = 1                      

*/

