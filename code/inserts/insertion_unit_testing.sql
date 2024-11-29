-- Enable execution plan
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- Example SELECT query to analyze
SELECT TOP(6) * FROM [art_connection_db].[dbo].[Artist];
SELECT TOP(6) * FROM [art_connection_db].[dbo].[Artwork];
SELECT TOP(6) * FROM [art_connection_db].[dbo].[Museum];
SELECT TOP(6) * FROM [art_connection_db].[dbo].[Portfolio];
SELECT TOP(6) * FROM [art_connection_db].[dbo].[Linker_Artist_To_Art];
SELECT TOP(6) * FROM [art_connection_db].[dbo].[Linker_Art_In_Museum];
SELECT TOP(6) * FROM [art_connection_db].[dbo].[linker_Art_In_Portfolio];

-- Disable execution plan
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
