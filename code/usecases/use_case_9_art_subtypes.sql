-- USE CASE 9: Categorize Artworks into Subtypes Based on Medium
-- Requirements:
-- 1) Involves both the supertype (Artwork) and one of the subtypes (Painting, Sculpture, Photography, Illustration, Video)

-- Drop the view if it already exists
IF OBJECT_ID('dbo.ArtworksWithSubtypesView', 'V') IS NOT NULL
    DROP VIEW dbo.ArtworksWithSubtypesView;
GO

-- Create the view
CREATE VIEW dbo.ArtworksWithSubtypesView AS
SELECT 
    a.[artID],
    a.[Title],
    a.[Creation_Date],
    a.[Medium],
    CASE 
        WHEN a.[Medium] LIKE '%oil%' OR a.[Medium] LIKE '%acrylic%' OR a.[Medium] LIKE '%watercolor%' OR a.[Medium] LIKE '%gouache%' THEN 'Painting'
        WHEN a.[Medium] LIKE '%marble%' OR a.[Medium] LIKE '%bronze%' OR a.[Medium] LIKE '%wood%' OR a.[Medium] LIKE '%stone%' THEN 'Sculpture'
        WHEN a.[Medium] LIKE '%photograph%' OR a.[Medium] LIKE '%digital print%' OR a.[Medium] LIKE '%gelatin silver%' THEN 'Photography'
        WHEN a.[Medium] LIKE '%ink%' OR a.[Medium] LIKE '%pencil%' OR a.[Medium] LIKE '%charcoal%' THEN 'Illustration'
        WHEN a.[Medium] LIKE '%video%' OR a.[Medium] LIKE '%film%' OR a.[Medium] LIKE '%digital video%' THEN 'Video'
        ELSE 'Other'
    END AS [Subtype]
FROM 
    [art_connection_db].[dbo].[Artwork] a;
GO

-- Select from the view to verify and sort the results
SELECT * 
FROM dbo.ArtworksWithSubtypesView
ORDER BY [Subtype], [Title];

-- Query to count the number of artworks by subtype
SELECT 
    [Subtype],
    COUNT(*) AS [Artworks_Count]
FROM 
    dbo.ArtworksWithSubtypesView
GROUP BY 
    [Subtype]
ORDER BY 
    [Artworks_Count] DESC;

-- Select the top 100 examples of the "Other" category
SELECT TOP 100 *
FROM dbo.ArtworksWithSubtypesView
WHERE [Subtype] = 'Other'
ORDER BY [Title];