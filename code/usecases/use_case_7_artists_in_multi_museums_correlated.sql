
-- USE CASE 7: Artists with Artworks in Multiple Museums
-- Requirements:
-- 1) Involves multiple entities: Artist, Artwork, Museum
-- 2) Uses a correlated query

-- Drop the view if it already exists
IF OBJECT_ID('dbo.ArtistsWithMultipleMuseumsView', 'V') IS NOT NULL
    DROP VIEW dbo.ArtistsWithMultipleMuseumsView;
GO

-- Create the view
CREATE VIEW dbo.ArtistsWithMultipleMuseumsView AS
SELECT 
    ar.[Display_Name] AS [Artist Name],
    COUNT(DISTINCT m.[museumID]) AS [Museum_Count]
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
    ar.[Display_Name]
HAVING 
    COUNT(DISTINCT m.[museumID]) > 1;
GO

-- Select from the view to verify and sort the results
SELECT * 
FROM dbo.ArtistsWithMultipleMuseumsView
ORDER BY [Artist Name];