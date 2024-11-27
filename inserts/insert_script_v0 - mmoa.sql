-- Define batch size
DECLARE @BatchSize INT = 1000;
DECLARE @CurrentBatch INT = 0;

-- Begin outer transaction
BEGIN TRANSACTION;

-- Declare a cursor to process each row individually
DECLARE ArtCursor CURSOR FOR 
SELECT 
  art.[Artwork_ID] AS [Source_PK_Artist_ID],
  art.[Title], 
  art.[Date] AS [Creation_Date], 
  art.[Medium], 
  art.[Credit] AS [Credit_Line], 
  art.[Department], 
  CONCAT_WS(', ', art.[Width_cm], art.[Height_cm], art.[Depth_cm], art.[Diameter_cm], art.[Circumference_cm], art.[Length_cm], art.[Weight_kg], art.[Duration_s]) AS [Dimensions], 
  art.[Object_Number], 
  art.[Classification], 
  art.[Name] AS [Legal_Name],
  art.[Artist_ID], 
  art.[Acquisition_Date],
  art.[Catalogue],
  art.[Weight_kg],
  artist.[Name] AS [Artist_Name],
  artist.[Nationality], 
  artist.[Gender],
  artist.[Birth_Year] AS [Birth_Date], 
  artist.[Death_Year] AS [Death_Date]
FROM [art_connection_db].[dbo].[MMOA_artworks] art
JOIN [art_connection_db].[dbo].[MMOA_artists] artist
ON art.[Artist_ID] = artist.[Artist_ID]
WHERE art.[Artwork_ID] IS NOT NULL;

-- Variables to hold row data with adjusted sizes
DECLARE @Artwork_ID VARCHAR(100), @Title VARCHAR(2000), @Creation_Date VARCHAR(100), 
    @Medium VARCHAR(8000), @Credit_Line VARCHAR(8000), @Department VARCHAR(100), @Dimensions VARCHAR(8000),
    @Object_Number VARCHAR(100), @Classification VARCHAR(1000), @Legal_Name VARCHAR(100), @Artist_ID VARCHAR(1000),
    @Acquisition_Date VARCHAR(100), @Catalogue VARCHAR(100), @Weight_kg VARCHAR(100),
    @Artist_Name VARCHAR(8000), @Nationality VARCHAR(8000), @Gender VARCHAR(100),
    @Birth_Date VARCHAR(50), @Death_Date VARCHAR(50);

-- Variable to count the number of records processed
DECLARE @RecordCount INT = 0;

-- Insert "Portfolio information not found" portfolio if not exists
DECLARE @PortfolioID INT;
IF NOT EXISTS (SELECT 1 FROM [art_connection_db].[dbo].[Portfolio] WHERE [Title] = 'Portfolio information not found')
BEGIN
    INSERT INTO [art_connection_db].[dbo].[Portfolio] ([Title], [Notes])
    VALUES ('Portfolio information not found', 'Default portfolio for artworks without specific portfolio information.');
    SET @PortfolioID = SCOPE_IDENTITY();
    PRINT 'Inserted PortfolioID ' + CONVERT(VARCHAR, @PortfolioID) + ' for "Portfolio information not found"';
END
ELSE
BEGIN
    SELECT @PortfolioID = [portfolioID] FROM [art_connection_db].[dbo].[Portfolio] WHERE [Title] = 'Portfolio information not found';
    PRINT 'Found existing PortfolioID ' + CONVERT(VARCHAR, @PortfolioID) + ' for "Portfolio information not found"';
END;

OPEN ArtCursor;
FETCH NEXT FROM ArtCursor INTO @Artwork_ID, @Title, @Creation_Date, @Medium, @Credit_Line, @Department, @Dimensions, @Object_Number, @Classification, @Legal_Name, @Artist_ID, @Acquisition_Date, @Catalogue, @Weight_kg, @Artist_Name, @Nationality, @Gender, @Birth_Date, @Death_Date;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Insert artwork record
    INSERT INTO [art_connection_db].[dbo].[Artwork] ([catalogue_number], [Title], [Creation_Date], [Medium], [Credit_Line], [Department], [Dimensions], [source_identifyer_art], [source_pk_artID])
    VALUES (@Object_Number, @Title, @Creation_Date, @Medium, @Credit_Line, @Department, @Dimensions, 'MMOA_artworks', @Artwork_ID);

    DECLARE @artID INT = SCOPE_IDENTITY();
    PRINT 'Inserted artID ' + CONVERT(VARCHAR, @artID) + ' with "' + LEFT(@Title, 50) + '"';

    -- Check if the artist exists by Title, insert if not, and get artistID
    DECLARE @artistID INT;
    IF NOT EXISTS (SELECT 1 FROM [art_connection_db].[dbo].[Artist] WHERE [Display_Name] = @Artist_Name)
    BEGIN
        INSERT INTO [art_connection_db].[dbo].[Artist] ([Display_Name], [Legal_Name], [Nationality], [Role], [Birth_Date], [Death_Date], [source_identifyer_artist], [source_pk_ArtistID], [Gender])
        VALUES (@Artist_Name, @Legal_Name, @Nationality, 'Artist', @Birth_Date, @Death_Date, 'MMOA_artworks', @Artist_ID, @Gender);
        SET @artistID = SCOPE_IDENTITY();
        PRINT 'Inserted artistID ' + CONVERT(VARCHAR, @artistID) + ' with "' + LEFT(@Artist_Name, 50) + '"';
    END
    ELSE
    BEGIN
        SELECT @artistID = [artistID] FROM [art_connection_db].[dbo].[Artist] WHERE [Display_Name] = @Artist_Name;
        PRINT 'Found existing artistID ' + CONVERT(VARCHAR, @artistID) + ' with "' + LEFT(@Artist_Name, 50) + '"';
    END;
    
    -- Insert into Linker_Artist_To_Art table
    INSERT INTO [art_connection_db].[dbo].[Linker_Artist_To_Art] ([artID], [artistID])
    VALUES (@artID, @artistID);
    PRINT 'Linked artistID ' + CONVERT(VARCHAR, @artistID) + ' with artID ' + CONVERT(VARCHAR, @artID);

    -- Insert into Linker_Art_In_Museum table
    INSERT INTO [art_connection_db].[dbo].[Linker_Art_In_Museum] ([artID], [museumID])
    VALUES (@artID, 4); -- Hardcoded to MMOA_artworks
    PRINT 'Saved artwork: ' + CONVERT(VARCHAR, @artID) + ' into Linker_Art_In_Museum';

    -- Insert into linker_Art_In_Portfolio table
    INSERT INTO [art_connection_db].[dbo].[linker_Art_In_Portfolio] ([artID], [portfolioID])
    VALUES (@artID, @PortfolioID);
    PRINT 'Linked artID ' + CONVERT(VARCHAR, @artID) + ' to PortfolioID ' + CONVERT(VARCHAR, @PortfolioID);

    -- Increment the record count
    SET @RecordCount = @RecordCount + 1;
    SET @CurrentBatch = @CurrentBatch + 1;

    -- Commit transaction for the current batch
    IF @CurrentBatch >= @BatchSize
    BEGIN
        COMMIT TRANSACTION;
        PRINT 'Committed batch of ' + CONVERT(VARCHAR, @CurrentBatch) + ' records';
        SET @CurrentBatch = 0;
        BEGIN TRANSACTION;
    END

    FETCH NEXT FROM ArtCursor INTO @Artwork_ID, @Title, @Creation_Date, @Medium, @Credit_Line, @Department, @Dimensions, @Object_Number, @Classification, @Legal_Name, @Artist_ID, @Acquisition_Date, @Catalogue, @Weight_kg, @Artist_Name, @Nationality, @Gender, @Birth_Date, @Death_Date;
END;

CLOSE ArtCursor;
DEALLOCATE ArtCursor;

-- Commit any remaining records
IF @CurrentBatch > 0
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Committed final batch of ' + CONVERT(VARCHAR, @CurrentBatch) + ' records';
END

PRINT 'Processing complete. Added ' + CONVERT(VARCHAR, @RecordCount) + ' records from source file: MMOA_artworks';
