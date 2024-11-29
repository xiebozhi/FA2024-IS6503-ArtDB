-- USE CASE 5: Artists with a Minimum Number of Artworks in Each Museum
-- Requirements:
-- 1) Involves multiple entities: Artist, Artwork, Museum
-- 2) Uses mathematical functions: COUNT
-- 3) Uses GROUP BY feature
-- 4) Uses the HAVING clause

-- Define the minimum number of artworks
DECLARE @MinArtworks INT = 5;

-- Drop the view if it already exists
IF OBJECT_ID('dbo.ArtistsWithMinArtworksView', 'V') IS NOT NULL
    DROP VIEW dbo.ArtistsWithMinArtworksView;
GO

-- Create the view
CREATE VIEW dbo.ArtistsWithMinArtworksView AS
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
GROUP BY 
    ar.[Display_Name], m.[Name]
HAVING 
    COUNT(a.[Title]) >= @MinArtworks;
GO

-- Select statement to verify the results
SELECT * 
FROM dbo.ArtistsWithMinArtworksView
ORDER BY [Museum Name], [Artist Name];