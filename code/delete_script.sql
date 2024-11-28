-- Begin transaction
BEGIN TRANSACTION;

-- Drop the source tables
DROP TABLE IF EXISTS [art_connection_db].[dbo].[MetObjects];
DROP TABLE IF EXISTS [art_connection_db].[dbo].[MMOA_artworks];
DROP TABLE IF EXISTS [art_connection_db].[dbo].[MMOA_artists];
DROP TABLE IF EXISTS [art_connection_db].[dbo].[carnigie_cmoa];
DROP TABLE IF EXISTS [art_connection_db].[dbo].[carnigie_teenie];

-- Commit transaction
COMMIT TRANSACTION;

-- Print completion message
PRINT 'All source tables have been deleted successfully.';