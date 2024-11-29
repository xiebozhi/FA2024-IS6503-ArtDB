-- USE CASE 6: Museums with Average Number of Artworks per Artist Above a Certain Threshold
-- Requirements:
-- 1) Involves multiple entities: Artist, Artwork, Museum
-- 2) Uses mathematical functions: AVG
-- 3) Uses GROUP BY feature
-- 4) Uses the HAVING clause

-- Drop the view if it already exists
IF OBJECT_ID('dbo.MuseumsWithAvgArtworksPerArtistView', 'V') IS NOT NULL
    DROP VIEW dbo.MuseumsWithAvgArtworksPerArtistView;
GO

-- Create the view
CREATE VIEW dbo.MuseumsWithAvgArtworksPerArtistView AS
WITH ArtworksPerArtist AS (
    SELECT 
        lam.[museumID],
        laa.[artistID],
        COUNT(a.[artID]) AS [Artworks_Count]
    FROM 
        [art_connection_db].[dbo].[Linker_Artist_To_Art] laa
    JOIN 
        [art_connection_db].[dbo].[Artwork] a ON laa.[artID] = a.[artID]
    JOIN 
        [art_connection_db].[dbo].[Linker_Art_In_Museum] lam ON a.[artID] = lam.[artID]
    GROUP BY 
        lam.[museumID], laa.[artistID]
)
SELECT 
    m.[Name] AS [Museum Name],
    AVG(CAST(apa.[Artworks_Count] AS DECIMAL(18, 2))) AS [Avg_Artworks_Per_Artist]
FROM 
    [art_connection_db].[dbo].[Museum] m
LEFT JOIN 
    ArtworksPerArtist apa ON m.[museumID] = apa.[museumID]
GROUP BY 
    m.[Name]
HAVING 
    AVG(CAST(apa.[Artworks_Count] AS DECIMAL(18, 2))) > 5.00; -- Hardcoded minimum average number of artworks per artist
GO

-- Select statement to verify the results
SELECT * 
FROM dbo.MuseumsWithAvgArtworksPerArtistView
ORDER BY [Avg_Artworks_Per_Artist] DESC;