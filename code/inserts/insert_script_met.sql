-- Enable execution plan
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- Define batch size
DECLARE @BatchSize INT = 1000;
DECLARE @CurrentBatch INT = 0;

-- Begin outer transaction
BEGIN TRANSACTION;

-- Declare a cursor to process each row individually
DECLARE ArtCursor CURSOR FOR 
SELECT 
  [Object_Number], 
  LEFT(COALESCE([Title], 'untitled_' + CONVERT(VARCHAR, [Object_ID])), 2000) AS [Title], 
  [Object_Date], 
  [Medium], 
  [Credit_Line], 
  [Department], 
  [Dimensions], 
  [Link_Resource] AS [Image_URL], 
  [Repository], 
  [Object_ID], 
  [Classification],
  [Artist_Display_Name] AS [Display_Name], 
  [Artist_Display_Bio] AS [Display_Bio],
  [Artist_Nationality] AS [Nationality], 
  [Artist_Role] AS [Role], 
  [Artist_Begin_Date] AS [Birth_Date], 
  [Artist_End_Date] AS [Death_Date],
  [Object_Begin_Date], 
  [Object_End_Date], 
  [Portfolio] AS [source_identifyer_art],
  [Rights_and_Reproduction]
FROM [art_connection_db].[dbo].[MetObjects]
WHERE [Object_ID] IS NOT NULL;

-- Variables to hold row data with adjusted sizes
DECLARE @catalogue_number VARCHAR(100), @Title VARCHAR(2000), @Creation_Date VARCHAR(100), 
    @Medium VARCHAR(8000), @Credit_Line VARCHAR(8000), @Department VARCHAR(100), @Dimensions VARCHAR(8000),
    @Image_URL VARCHAR(8000), @Repository VARCHAR(100), @source_pk_artID VARCHAR(1000), @Web_URL VARCHAR(100), 
    @Legal_Name VARCHAR(100), @Display_Name VARCHAR(8000), @Nationality VARCHAR(8000), @Role VARCHAR(8000), 
    @Birth_Date VARCHAR(50), @Death_Date VARCHAR(50), @Object_Begin_Date VARCHAR(100), @Object_End_Date VARCHAR(100),
    @Portfolio VARCHAR(1000), @Classification VARCHAR(1000), @Rights_and_Reproduction VARCHAR(255);

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
FETCH NEXT FROM ArtCursor INTO @catalogue_number, @Title, @Creation_Date, @Medium, @Credit_Line, @Department,
    @Dimensions, @Image_URL, @Repository, @source_pk_artID, @Classification, @Display_Name, @Legal_Name, @Nationality, @Role, @Birth_Date, @Death_Date, @Object_Begin_Date, @Object_End_Date, @Portfolio, @Rights_and_Reproduction;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Insert artwork record
    INSERT INTO [art_connection_db].[dbo].[Artwork] ([catalogue_number], [Title], [Creation_Date], [Medium], [Credit_Line], [Department],[Dimensions], [Image_URL], [Repository], [source_identifyer_art], [source_pk_artID], [Web_URL])
    VALUES (@catalogue_number, @Title, @Creation_Date, @Medium, @Credit_Line, @Department, 
            @Dimensions, @Image_URL, @Repository, 'MET_objects', @source_pk_artID, @Web_URL);

    DECLARE @artID INT = SCOPE_IDENTITY();
    PRINT 'Inserted artID ' + CONVERT(VARCHAR, @artID) + ' with "' + LEFT(@Title, 50) + '"';

    -- Check if the artist exists by Title, insert if not, and get artistID
    DECLARE @artistID INT;
    IF NOT EXISTS (SELECT 1 FROM [art_connection_db].[dbo].[Artist] WHERE [Display_Name] = @Display_Name)
    BEGIN
        INSERT INTO [art_connection_db].[dbo].[Artist] ([Display_Name], [Legal_Name], [Nationality], [Role], [Birth_Date], [Death_Date], [source_identifyer_artist], [source_pk_ArtistID])
        VALUES (@Display_Name, @Legal_Name, @Nationality, @Role, @Birth_Date, @Death_Date, 'MET_objects', @source_pk_artID);
        SET @artistID = SCOPE_IDENTITY();
        PRINT 'Inserted artistID ' + CONVERT(VARCHAR, @artistID) + ' with "' + LEFT(@Display_Name, 50) + '"';
    END
    ELSE
    BEGIN
        SELECT @artistID = [artistID] FROM [art_connection_db].[dbo].[Artist] WHERE [Display_Name] = @Display_Name;
        PRINT 'Found existing artistID ' + CONVERT(VARCHAR, @artistID) + ' with "' + LEFT(@Display_Name, 50) + '"';
    END;
    
    -- Insert into Linker_Artist_To_Art table
    INSERT INTO [art_connection_db].[dbo].[Linker_Artist_To_Art] ([artID], [artistID])
    VALUES (@artID, @artistID);
    PRINT 'Linked artistID ' + CONVERT(VARCHAR, @artistID) + ' with artID ' + CONVERT(VARCHAR, @artID);

    -- Insert into Linker_Art_In_Museum table
    INSERT INTO [art_connection_db].[dbo].[Linker_Art_In_Museum] ([artID], [museumID])
    VALUES (@artID, 2); -- Hardcoded to MET_objects
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

    FETCH NEXT FROM ArtCursor INTO @catalogue_number, @Title, @Creation_Date, @Medium, @Credit_Line, @Department, @Dimensions, @Image_URL, @Repository, @source_pk_artID, @Classification, @Display_Name, @Legal_Name, @Nationality, @Role, @Birth_Date, @Death_Date, @Object_Begin_Date, @Object_End_Date, @Portfolio, @Rights_and_Reproduction;
END;

CLOSE ArtCursor;
DEALLOCATE ArtCursor;

-- Commit any remaining records
IF @CurrentBatch > 0
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Committed final batch of ' + CONVERT(VARCHAR, @CurrentBatch) + ' records';
END

PRINT 'Processing complete. Added ' + CONVERT(VARCHAR, @RecordCount) + ' records from source file: MET_objects';

-- Disable execution plan
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
