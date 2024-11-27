-- Select artworks organized by medium
SELECT 
    art.[Medium],
    artist.[Display_Name] AS [Artist_Name],
    art.[Title], 
    art.[Creation_Date], 
    art.[Credit_Line], 
    art.[Department], 
    art.[Dimensions], 
    art.[Image_URL], 
    art.[Repository], 
    art.[Web_URL],
    museum.[Name] AS [Museum_Name],
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
WHERE art.[Medium] IS NOT NULL AND art.[Medium] <> ''
ORDER BY 
    art.[Medium], artist.[Display_Name], museum.[Name], art.[Title];
