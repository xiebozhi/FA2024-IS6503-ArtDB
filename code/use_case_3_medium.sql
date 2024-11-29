-- Drop the view if it already exists
IF OBJECT_ID('dbo.ArtistArtworksByMediumView', 'V') IS NOT NULL
    DROP VIEW dbo.ArtistArtworksByMediumView;
GO
-- Drop the stored procedure if it already exists
IF OBJECT_ID('dbo.FilterArtistArtworksByMedium', 'P') IS NOT NULL
    DROP PROCEDURE dbo.FilterArtistArtworksByMedium;
GO

-- Create the view
CREATE VIEW dbo.ArtistArtworksByMediumView AS
SELECT 
    art.[Medium],
    artist.[Display_Name] AS [Artist Name],
    artist.[Legal_Name] AS [Legal Name],
    artist.[Nationality] AS [Artist Nationality],
    artist.[Role] AS [Artist Role],
    artist.[Birth_Date] AS [Artist Birth Date],
    artist.[Death_Date] AS [Artist Death Date],
    art.[Title] AS [Artwork Title], 
    art.[Creation_Date] AS [Creation Date], 
    art.[Credit_Line] AS [Credit Line], 
    art.[Department], 
    art.[Dimensions], 
    art.[Image_URL], 
    art.[Repository], 
    art.[Web_URL],
    museum.[Name] AS [Museum Name],
    museum.[City], 
    museum.[State], 
    museum.[Country]
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
WHERE 
    art.[Medium] IS NOT NULL AND art.[Medium] <> '';
GO

-- Create a stored procedure to filter the view by a keyword
CREATE PROCEDURE dbo.FilterArtistArtworksByMedium
    @Keyword NVARCHAR(100)
AS
BEGIN
    SELECT * 
    FROM dbo.ArtistArtworksByMediumView
    WHERE [Medium] LIKE '%' + @Keyword + '%'
    ORDER BY [Medium], [Artist Name], [Museum Name], [Artwork Title];
END
GO

-- Example usage of the stored procedure
EXEC dbo.FilterArtistArtworksByMedium @Keyword = '';
-- Example usage of the stored procedure
EXEC dbo.FilterArtistArtworksByMedium @Keyword = 'silk';
-- Example usage of the stored procedure
EXEC dbo.FilterArtistArtworksByMedium @Keyword = 'cotton';