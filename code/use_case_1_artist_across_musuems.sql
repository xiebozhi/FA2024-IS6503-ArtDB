IF OBJECT_ID('dbo.ArtistArtworksView', 'V') IS NOT NULL
    DROP VIEW dbo.ArtistArtworksView;
GO

-- Create the view
CREATE VIEW dbo.ArtistArtworksView AS
SELECT 
    m.[Name] AS [Museum Name],
    ar.[Display_Name] AS [Artist Name],
    ar.[Legal_Name] AS [Legal Name],
    ar.[Nationality] AS [Artist Nationality],
    ar.[Role] AS [Artist Role],
    ar.[Birth_Date] AS [Artist Birth Date],
    ar.[Death_Date] AS [Artist Death Date],
    a.[Title] AS [Artwork Title],
    a.[Credit_Line] AS [Credit Line],
    a.[Creation_Date] AS [Creation Date],
    a.[Medium] AS [Medium],
    a.[Dimensions] AS [Dimensions],
    a.[Description] AS [Description],
    a.[Department] AS [Department],
    a.[Image_URL] AS [Image URL],
    a.[Web_URL] AS [Web URL],
    m.[City] AS [Museum City],
    m.[Country] AS [Museum Country],
    m.[WebURL] AS [Museum Website],
    m.[Street] AS [Museum Street],
    m.[State] AS [Museum State],
    m.[Zip] AS [Museum Zip],
    m.[Phone] AS [Museum Phone],
    m.[Year_established] AS [Museum Year Established],
    m.[Admission] AS [Museum Admission]
FROM 
    [art_connection_db].[dbo].[Artist] ar
JOIN 
    [art_connection_db].[dbo].[Linker_Artist_To_Art] laa ON ar.[artistID] = laa.[artistID]
JOIN 
    [art_connection_db].[dbo].[Artwork] a ON laa.[artID] = a.[artID]
JOIN 
    [art_connection_db].[dbo].[Linker_Art_In_Museum] lam ON a.[artID] = lam.[artID]
JOIN 
    [art_connection_db].[dbo].[Museum] m ON lam.[museumID] = m.[museumID]
WHERE 
    ar.[Display_Name] IS NOT NULL;
GO

-- Select from the view to verify and sort the results
SELECT * 
FROM dbo.ArtistArtworksView
ORDER BY [Artist Name], [Artwork Title];

-- Dynamic SQL to create pivot table
DECLARE @cols AS NVARCHAR(MAX),
        @query AS NVARCHAR(MAX);

-- Get distinct museum names
SELECT @cols = STUFF((SELECT DISTINCT ',' + QUOTENAME([Name]) 
                      FROM [art_connection_db].[dbo].[Museum]
                      FOR XML PATH(''), TYPE
                      ).value('.', 'NVARCHAR(MAX)') 
                     ,1,1,'');

-- Create dynamic query
SET @query = '
WITH ArtistMuseumSummary AS (
    SELECT 
        ar.[Display_Name] AS [Artist Name],
        m.[Name] AS [Museum Name],
        COUNT(a.[Title]) AS [Art_Pieces_Count]
    FROM 
        [art_connection_db].[dbo].[Artist] ar
    JOIN 
        [art_connection_db].[dbo].[Linker_Artist_To_Art] laa ON ar.[artistID] = laa.[artistID]
    JOIN 
        [art_connection_db].[dbo].[Artwork] a ON laa.[artID] = a.[artID]
    JOIN 
        [art_connection_db].[dbo].[Linker_Art_In_Museum] lam ON a.[artID] = lam.[artID]
    JOIN 
        [art_connection_db].[dbo].[Museum] m ON lam.[museumID] = m.[museumID]
    WHERE 
        ar.[Display_Name] IS NOT NULL
    GROUP BY 
        ar.[Display_Name], m.[Name]
)
SELECT [Artist Name], ' + @cols + ', 
       ISNULL((SELECT SUM([Art_Pieces_Count]) FROM ArtistMuseumSummary WHERE [Artist Name] = pvt.[Artist Name]), 0) AS [Total_Art_Pieces]
FROM 
    ArtistMuseumSummary
PIVOT 
(
    SUM([Art_Pieces_Count])
    FOR [Museum Name] IN (' + @cols + ')
) AS pvt
ORDER BY 
    [Artist Name];';

-- Execute dynamic query
EXEC sp_executesql @query;
