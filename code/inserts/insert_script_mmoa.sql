-- Disable execution plan
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

-- Define batch size
DECLARE @BatchSize INT = 1000;
DECLARE @CurrentBatch INT = 0;

-- Begin outer transaction
BEGIN TRANSACTION;

-- Declare a cursor to process each row individually
DECLARE ArtCursor CURSOR FOR 
SELECT 
    art.[Artwork_ID] AS [source_pk_artID], -- Assign Artwork_ID to source_pk_artID
    art.[Title], 
    art.[Date] AS [Creation_Date], 
    art.[Medium], 
    art.[Credit] AS [Credit_Line], 
    art.[Department], 
    CONCAT(
        'Width: ', COALESCE(art.[Width_cm], 'N/A'), ' cm, ',
        'Height: ', COALESCE(art.[Height_cm], 'N/A'), ' cm, ',
        'Depth: ', COALESCE(art.[Depth_cm], 'N/A'), ' cm, ',
        'Diameter: ', COALESCE(art.[Diameter_cm], 'N/A'), ' cm, ',
        'Circumference: ', COALESCE(art.[Circumference_cm], 'N/A'), ' cm, ',
        'Length: ', COALESCE(art.[Length_cm], 'N/A'), ' cm, ',
        'Weight: ', COALESCE(art.[Weight_kg], 'N/A'), ' kg, ',
        'Duration: ', COALESCE(art.[Duration_s], 'N/A'), ' s'
    ) AS [Dimensions],
    art.[Object_Number], 
    art.[Classification], 
    art.[Name] AS [Legal_Name],
    art.[Artist_ID] AS [source_pk_ArtistID], -- Assign Artist_ID to source_pk_ArtistID
    art.[Acquisition_Date],
    art.[Catalogue],
    art.[Weight_kg],
    artist.[Name] AS [Artist_Name],
    artist.[Nationality], 
    artist.[Gender],
    artist.[Birth_Year] AS [Birth_Date], 
    artist.[Death_Year] AS [Death_Date]
FROM 
    [art_connection_db].[dbo].[MMOA_artworks] art
JOIN 
    [art_connection_db].[dbo].[MMOA_artists] artist
ON 
    art.[Artist_ID] = artist.[Artist_ID]
WHERE 
    art.[Artwork_ID] IS NOT NULL;

-- Variables to hold row data with adjusted sizes
DECLARE 
    @Artwork_ID VARCHAR(100), 
    @Title VARCHAR(2000), 
    @Creation_Date VARCHAR(100), 
    @Medium VARCHAR(8000), 
    @Credit_Line VARCHAR(8000), 
    @Department VARCHAR(100), 
    @Dimensions VARCHAR(8000),
    @Object_Number VARCHAR(100), 
    @Classification VARCHAR(1000), 
    @Legal_Name VARCHAR(100), 
    @source_pk_ArtistID VARCHAR(1000),
    @Acquisition_Date VARCHAR(100), 
    @Catalogue VARCHAR(100), 
    @Weight_kg VARCHAR(100),
    @Artist_Name VARCHAR(8000), 
    @Nationality VARCHAR(8000), 
    @Gender VARCHAR(100),
    @Birth_Date VARCHAR(50), 
    @Death_Date VARCHAR(50);

-- Variable to count the number of records processed
DECLARE @RecordCount INT = 0;

-- Insert "Portfolio information not found" portfolio if not exists
DECLARE @PortfolioID INT;
IF NOT EXISTS (SELECT 1 FROM [art_connection_db].[dbo].[Portfolio] WHERE [Title] = 'Portfolio information not found')
BEGIN
    INSERT INTO [art_connection_db].[dbo].[Portfolio] ([Title], [Notes])
    VALUES ('Portfolio information not found', 'Default portfolio for artworks without specific portfolio information.');
    SET @PortfolioID = SCOPE_IDENTITY();
    -- PRINT 'Inserted PortfolioID ' + CONVERT(VARCHAR, @PortfolioID) + ' for "Portfolio information not found"';
END
ELSE
BEGIN
    SELECT @PortfolioID = [portfolioID] FROM [art_connection_db].[dbo].[Portfolio] WHERE [Title] = 'Portfolio information not found';
    -- PRINT 'Found existing PortfolioID ' + CONVERT(VARCHAR, @PortfolioID) + ' for "Portfolio information not found"';
END;

-- Open the cursor
OPEN ArtCursor;

-- Fetch the first row
FETCH NEXT FROM ArtCursor INTO 
    @Artwork_ID, @Title, @Creation_Date, @Medium, @Credit_Line, @Department, @Dimensions, 
    @Object_Number, @Classification, @Legal_Name, @source_pk_ArtistID, @Acquisition_Date, @Catalogue, 
    @Weight_kg, @Artist_Name, @Nationality, @Gender, @Birth_Date, @Death_Date;

-- Loop through the cursor
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Insert artwork record
    INSERT INTO [art_connection_db].[dbo].[Artwork] (
        [catalogue_number], [Title], [Creation_Date], [Medium], [Credit_Line], [Department], 
        [Dimensions], [Weight], [source_identifyer_art], [source_pk_artID]
    )
    VALUES (
        @Object_Number, @Title, @Creation_Date, @Medium, @Credit_Line, @Department, 
        @Dimensions, @Weight_kg, 'mmoa', @Artwork_ID
    );

    DECLARE @artID INT = SCOPE_IDENTITY();
    -- PRINT 'Inserted artID ' + CONVERT(VARCHAR, @artID) + ' with "' + LEFT(@Title, 50) + '"';

    -- Check if the artist exists by Display_Name, insert if not, and get artistID
    DECLARE @artistID INT;
    IF NOT EXISTS (SELECT 1 FROM [art_connection_db].[dbo].[Artist] WHERE [Display_Name] = @Artist_Name)
    BEGIN
        INSERT INTO [art_connection_db].[dbo].[Artist] (
            [Display_Name], [Nationality], [Birth_Date], [Death_Date], 
            [source_identifyer_artist], [source_pk_ArtistID], [Gender]
        )
        VALUES (
            @Artist_Name, @Nationality, @Birth_Date, @Death_Date, 'mmoa', @source_pk_ArtistID, @Gender
        );
        SET @artistID = SCOPE_IDENTITY();
        -- PRINT 'Inserted artistID ' + CONVERT(VARCHAR, @artistID) + ' with "' + LEFT(@Artist_Name, 50) + '"';
    END
    ELSE
    BEGIN
        SELECT @artistID = [artistID] FROM [art_connection_db].[dbo].[Artist] WHERE [Display_Name] = @Artist_Name;
        -- PRINT 'Found existing artistID ' + CONVERT(VARCHAR, @artistID) + ' with "' + LEFT(@Artist_Name, 50) + '"';
    END;
    
    -- Insert into Linker_Artist_To_Art table
    INSERT INTO [art_connection_db].[dbo].[Linker_Artist_To_Art] ([artID], [artistID])
    VALUES (@artID, @artistID);
    -- PRINT 'Linked artistID ' + CONVERT(VARCHAR, @artistID) + ' with artID ' + CONVERT(VARCHAR, @artID);

    -- Insert into Linker_Art_In_Museum table
    INSERT INTO [art_connection_db].[dbo].[Linker_Art_In_Museum] ([artID], [museumID])
    VALUES (@artID, 2); -- Hardcoded to MMOA_artworks
    -- PRINT 'Saved artwork: ' + CONVERT(VARCHAR, @artID) + ' into Linker_Art_In_Museum';

    -- Insert into linker_Art_In_Portfolio table
    INSERT INTO [art_connection_db].[dbo].[linker_Art_In_Portfolio] ([artID], [portfolioID])
    VALUES (@artID, @PortfolioID);
    -- PRINT 'Linked artID ' + CONVERT(VARCHAR, @artID) + ' to PortfolioID ' + CONVERT(VARCHAR, @PortfolioID);

    -- Singular print statement for summary
    PRINT 'Processed artID: ' + CONVERT(VARCHAR, @artID) + ', Title: "' + LEFT(@Title, 50) + '", artistID: ' + CONVERT(VARCHAR, @artistID) + ', Artist Name: "' + LEFT(@Artist_Name, 50) + '"';

    -- Increment the record count
    SET @RecordCount = @RecordCount + 1;
    SET @CurrentBatch = @CurrentBatch + 1;

    -- Commit transaction for the current batch
    IF @CurrentBatch >= @BatchSize
    BEGIN
        COMMIT TRANSACTION;
        -- PRINT 'Committed batch of ' + CONVERT(VARCHAR, @CurrentBatch) + ' records';
        SET @CurrentBatch = 0;
        BEGIN TRANSACTION;
    END

    -- Fetch the next row
    FETCH NEXT FROM ArtCursor INTO 
        @Artwork_ID, @Title, @Creation_Date, @Medium, @Credit_Line, @Department, @Dimensions, 
        @Object_Number, @Classification, @Legal_Name, @source_pk_ArtistID, @Acquisition_Date, @Catalogue, 
        @Weight_kg, @Artist_Name, @Nationality, @Gender, @Birth_Date, @Death_Date;
END;

-- Close and deallocate the cursor
CLOSE ArtCursor;
DEALLOCATE ArtCursor;

-- Commit any remaining records
IF @CurrentBatch > 0
BEGIN
    COMMIT TRANSACTION;
    -- PRINT 'Committed final batch of ' + CONVERT(VARCHAR, @CurrentBatch) + ' records';
END

PRINT 'Processing complete. Added ' + CONVERT(VARCHAR, @RecordCount) + ' records from source file: MMOA_artworks';

-- Disable execution plan
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;