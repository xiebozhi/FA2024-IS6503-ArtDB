-- Drop the view if it already exists
IF OBJECT_ID('dbo.ArtistArtworksByEraView', 'V') IS NOT NULL
    DROP VIEW dbo.ArtistArtworksByEraView;
GO

-- Create the view without the Museum reference
CREATE VIEW dbo.ArtistArtworksByEraView AS
SELECT 
    art.[Creation_Date],
    artist.[Display_Name] AS [Artist Name],
    artist.[Legal_Name] AS [Legal Name],
    artist.[Nationality] AS [Artist Nationality],
    artist.[Role] AS [Artist Role],
    artist.[Birth_Date] AS [Artist Birth Date],
    artist.[Death_Date] AS [Artist Death Date],
    art.[Title] AS [Artwork Title], 
    art.[Medium], 
    art.[Credit_Line] AS [Credit Line], 
    art.[Department], 
    art.[Dimensions], 
    art.[Image_URL], 
    art.[Web_URL],
    art.[City] AS [Artwork City],
    art.[Country] AS [Artwork Country],
    art.[Creation_Date] AS [Artwork Creation Date],
    art.[Culture],
    art.[Description],
    art.[Period],
    art.[Region],
    art.[Reign],
    art.[Rights_and_Reproduction],
    art.[State] AS [Artwork State],
    art.[Subregion],
    art.[Weight]
FROM 
    [art_connection_db].[dbo].[Artwork] art
JOIN 
    [art_connection_db].[dbo].[Linker_Artist_To_Art] linker ON art.[artID] = linker.[artID]
JOIN 
    [art_connection_db].[dbo].[Artist] artist ON linker.[artistID] = artist.[artistID]
WHERE 
    art.[Creation_Date] IS NOT NULL;
GO

-- Select from the view to verify and sort the results
SELECT * 
FROM dbo.ArtistArtworksByEraView
ORDER BY [Creation_Date], [Artist Name], [Artwork Title];