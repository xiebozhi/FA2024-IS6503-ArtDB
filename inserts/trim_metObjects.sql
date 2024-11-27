-- Delete rows beyond the first 100,000 based on Object_ID ordering
WITH CTE AS (
    SELECT 
        [Object_ID],
        ROW_NUMBER() OVER (ORDER BY [Object_ID]) AS RowNum
    FROM 
        [art_connection_db].[dbo].[MetObjects]
)
DELETE FROM CTE
WHERE RowNum > 100000;
