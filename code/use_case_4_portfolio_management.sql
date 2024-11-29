-- Drop the view if it already exists
IF OBJECT_ID('dbo.ArtistArtworksForPortfolioView', 'V') IS NOT NULL
    DROP VIEW dbo.ArtistArtworksForPortfolioView;
GO

-- Create the view
CREATE VIEW dbo.ArtistArtworksForPortfolioView AS
SELECT 
    art.[artID],
    art.[Title] AS [Artwork Title],
    artist.[Display_Name] AS [Artist Name],
    artist.[artistID],
    museum.[Name] AS [Museum Name],
    museum.[museumID],
    linker_portfolio.[portfolioID],
    portfolio.[Title] AS [Portfolio Title],
    portfolio.[Notes] AS [Portfolio Notes]
FROM 
    [art_connection_db].[dbo].[Artwork] art
JOIN 
    [art_connection_db].[dbo].[Linker_Artist_To_Art] linker ON art.[artID] = linker.[artID]
JOIN 
    [art_connection_db].[dbo].[Artist] artist ON linker.[artistID] = artist.[artistID]
JOIN 
    [art_connection_db].[dbo].[Linker_Art_In_Museum] linker_museum ON art.[artID] = linker_museum.[artID]
JOIN 
    [art_connection_db].[dbo].[Museum] museum ON linker_museum.[museumID] = museum.[museumID]
LEFT JOIN 
    [art_connection_db].[dbo].[linker_Art_In_Portfolio] linker_portfolio ON art.[artID] = linker_portfolio.[artID]
LEFT JOIN 
    [art_connection_db].[dbo].[Portfolio] portfolio ON linker_portfolio.[portfolioID] = portfolio.[portfolioID]
WHERE 
    linker_portfolio.[portfolioID] = 2;
GO

-- Select from the view to verify and sort the results
SELECT * 
FROM dbo.ArtistArtworksForPortfolioView
ORDER BY [Artist Name], [Artwork Title]; 
