-- USE CASE 8: Artists with Artworks in the Same Medium
-- Requirements:
-- 1) Involves a unary relationship (self-join)
-- 2) Uses the Medium column in the Artwork table

-- Drop the view if it already exists
IF OBJECT_ID('dbo.ArtistsWithSameMediumView', 'V') IS NOT NULL
    DROP VIEW dbo.ArtistsWithSameMediumView;
GO

-- Create the view
CREATE VIEW dbo.ArtistsWithSameMediumView AS
WITH TransformedMediums AS (
    SELECT 
        ar.[Display_Name] AS [Artist Name],
        a.[Medium],
        CASE 
            WHEN a.[Medium] LIKE '%oil%' OR a.[Medium] LIKE '%acrylic%' OR a.[Medium] LIKE '%watercolor%' OR a.[Medium] LIKE '%gouache%' THEN 'Painting'
            WHEN a.[Medium] LIKE '%marble%' OR a.[Medium] LIKE '%bronze%' OR a.[Medium] LIKE '%wood%' OR a.[Medium] LIKE '%stone%' THEN 'Sculpture'
            WHEN a.[Medium] LIKE '%photograph%' OR a.[Medium] LIKE '%digital print%' OR a.[Medium] LIKE '%gelatin silver%' THEN 'Photography'
            WHEN a.[Medium] LIKE '%ink%' OR a.[Medium] LIKE '%pencil%' OR a.[Medium] LIKE '%charcoal%' THEN 'Illustration'
            WHEN a.[Medium] LIKE '%video%' OR a.[Medium] LIKE '%film%' OR a.[Medium] LIKE '%digital video%' THEN 'Video'
            ELSE 'Other'
        END AS [Transformed_Medium]
    FROM 
        [art_connection_db].[dbo].[Artist] ar
    JOIN 
        [art_connection_db].[dbo].[Linker_Artist_To_Art] laa ON ar.[artistID] = laa.[artistID]
    JOIN 
        [art_connection_db].[dbo].[Artwork] a ON laa.[artID] = a.[artID]
    WHERE 
        a.[Medium] IS NOT NULL
)
SELECT 
    t1.[Artist Name] AS [Artist Name 1],
    t2.[Artist Name] AS [Artist Name 2],
    t1.[Transformed_Medium] AS [Medium]
FROM 
    TransformedMediums t1
JOIN 
    TransformedMediums t2 ON t1.[Transformed_Medium] = t2.[Transformed_Medium] AND t1.[Artist Name] <> t2.[Artist Name];
GO

-- Select from the view to verify and sort the results
SELECT TOP 100 *
FROM dbo.ArtistsWithSameMediumView
ORDER BY [Artist Name 1], [Artist Name 2];