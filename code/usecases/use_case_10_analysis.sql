
-- USE CASE 10: Statistical Analysis of the Database
-- Requirements:
-- 1) Perform statistical analysis on key tables and views
-- 2) Summarize different aspects such as mediums, number of pieces, number of artists and their associated pieces, and the number of pieces each museum has

-- Total number of rows in key tables
SELECT 'Artist' AS [Table], COUNT(*) AS [Total Rows] FROM [art_connection_db].[dbo].[Artist]
UNION ALL
SELECT 'Artwork' AS [Table], COUNT(*) AS [Total Rows] FROM [art_connection_db].[dbo].[Artwork]
UNION ALL
SELECT 'Museum' AS [Table], COUNT(*) AS [Total Rows] FROM [art_connection_db].[dbo].[Museum]
UNION ALL
SELECT 'Portfolio' AS [Table], COUNT(*) AS [Total Rows] FROM [art_connection_db].[dbo].[Portfolio]
UNION ALL
SELECT 'Linker_Artist_To_Art' AS [Table], COUNT(*) AS [Total Rows] FROM [art_connection_db].[dbo].[Linker_Artist_To_Art]
UNION ALL
SELECT 'Linker_Art_In_Museum' AS [Table], COUNT(*) AS [Total Rows] FROM [art_connection_db].[dbo].[Linker_Art_In_Museum]
UNION ALL
SELECT 'linker_Art_In_Portfolio' AS [Table], COUNT(*) AS [Total Rows] FROM [art_connection_db].[dbo].[linker_Art_In_Portfolio];

-- Summary of different mediums and number of pieces
SELECT 
    [Medium],
    COUNT(*) AS [Number of Pieces]
FROM 
    [art_connection_db].[dbo].[Artwork]
GROUP BY 
    [Medium]
ORDER BY 
    [Number of Pieces] DESC;

-- Summary of number of artists and their associated pieces
SELECT 
    ar.[Display_Name] AS [Artist Name],
    COUNT(a.[artID]) AS [Number of Pieces]
FROM 
    [art_connection_db].[dbo].[Artist] ar
JOIN 
    [art_connection_db].[dbo].[Linker_Artist_To_Art] laa ON ar.[artistID] = laa.[artistID]
JOIN 
    [art_connection_db].[dbo].[Artwork] a ON laa.[artID] = a.[artID]
GROUP BY 
    ar.[Display_Name]
ORDER BY 
    [Number of Pieces] DESC;

-- Summary of number of pieces each museum has
SELECT 
    m.[Name] AS [Museum Name],
    COUNT(a.[artID]) AS [Number of Pieces]
FROM 
    [art_connection_db].[dbo].[Artwork] a
JOIN 
    [art_connection_db].[dbo].[Linker_Art_In_Museum] lam ON a.[artID] = lam.[artID]
JOIN 
    [art_connection_db].[dbo].[Museum] m ON lam.[museumID] = m.[museumID]
GROUP BY 
    m.[Name]
ORDER BY 
    [Number of Pieces] DESC;

-- Summary of number of pieces in each portfolio
SELECT 
    p.[Title] AS [Portfolio Title],
    COUNT(lap.[artID]) AS [Number of Pieces]
FROM 
    [art_connection_db].[dbo].[Portfolio] p
JOIN 
    [art_connection_db].[dbo].[linker_Art_In_Portfolio] lap ON p.[portfolioID] = lap.[portfolioID]
GROUP BY 
    p.[Title]
ORDER BY 
    [Number of Pieces] DESC;