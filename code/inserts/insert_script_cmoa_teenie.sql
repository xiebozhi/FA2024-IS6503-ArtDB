-- Enable execution plan
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
    [accession_number], 
    LEFT(COALESCE([title], 'untitled_' + CONVERT(VARCHAR, [id])), 2000) AS [Title], 
    [creation_date], 
    [medium], 
    [credit_line], 
    [department], 
    CONCAT(
        'w: ', COALESCE([item_width], 'N/A'), ', ',
        'h: ', COALESCE([item_height], 'N/A'), ', ',
        'd: ', COALESCE([item_depth], 'N/A'), ', ',
        'diam: ', COALESCE([item_diameter], 'N/A')
    ) AS [Dimensions],
    [image_url], 
    [physical_location], 
    [id] AS [source_pk_artID], 
    [web_url],
    [full_name] AS [Legal_Name],
    [cited_name] AS [Display_Name],
    [nationality], 
    [role], 
    [birth_date], 
    [death_date],
    [id] AS [source_pk_ArtistID]
FROM 
    [art_connection_db].[dbo].[carnigie_teenie]
WHERE 
    [id] IS NOT NULL;

-- Variables to hold row data with adjusted sizes
DECLARE 
    @catalogue_number VARCHAR(100), 
    @Title VARCHAR(2000), 
    @Creation_Date VARCHAR(100), 
    @Medium VARCHAR(8000), 
    @Credit_Line VARCHAR(8000), 
    @Department VARCHAR(100), 
    @Dimensions VARCHAR(8000),
    @Image_URL VARCHAR(8000), 
    @Repository VARCHAR(100), 
    @source_pk_artID VARCHAR(1000), 
    @Web_URL VARCHAR(100), 
    @Legal_Name VARCHAR(100), 
    @Display_Name VARCHAR(8000), 
    @Nationality VARCHAR(8000), 
    @Role VARCHAR(8000), 
    @Birth_Date VARCHAR(50), 
    @Death_Date VARCHAR(50), 
    @source_pk_ArtistID VARCHAR(1000);

-- Variable to count the number of records processed
DECLARE @RecordCount INT = 0;

-- Insert Harris Teenie Collection portfolio if not exists
DECLARE @PortfolioID INT;
IF NOT EXISTS (SELECT 1 FROM [art_connection_db].[dbo].[Portfolio] WHERE [Title] = 'Harris Teenie Collection')
BEGIN
    INSERT INTO [art_connection_db].[dbo].[Portfolio] ([Title], [Notes])
    VALUES ('Harris Teenie Collection', 'A collection of artworks from the Harris Teenie collection.');
    SET @PortfolioID = SCOPE_IDENTITY();
    -- PRINT 'Inserted PortfolioID ' + CONVERT(VARCHAR, @PortfolioID) + ' for Harris Teenie Collection';
END
ELSE
BEGIN
    SELECT @PortfolioID = [portfolioID] FROM [art_connection_db].[dbo].[Portfolio] WHERE [Title] = 'Harris Teenie Collection';
    -- PRINT 'Found existing PortfolioID ' + CONVERT(VARCHAR, @PortfolioID) + ' for Harris Teenie Collection';
END;

-- Open the cursor
OPEN ArtCursor;

-- Fetch the first row
FETCH NEXT FROM ArtCursor INTO 
    @catalogue_number, @Title, @Creation_Date, @Medium, @Credit_Line, @Department,
    @Dimensions, @Image_URL, @Repository, @source_pk_artID, @Web_URL,
    @Legal_Name, @Display_Name, @Nationality, @Role, @Birth_Date, @Death_Date, @source_pk_ArtistID;

-- Loop through the cursor
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Insert artwork record
    INSERT INTO [art_connection_db].[dbo].[Artwork] (
        [catalogue_number], [Title], [Creation_Date], [Medium], [Credit_Line], [Department],
        [Dimensions], [Image_URL], [Repository], [source_identifyer_art], [source_pk_artID], [Web_URL]
    )
    VALUES (
        @catalogue_number, @Title, @Creation_Date, @Medium, @Credit_Line, @Department, 
        @Dimensions, @Image_URL, @Repository, 'cmoa_teenie', @source_pk_artID, @Web_URL
    );

    DECLARE @artID INT = SCOPE_IDENTITY();
    -- PRINT 'Inserted artID ' + CONVERT(VARCHAR, @artID) + ' with "' + LEFT(@Title, 50) + '"';

    -- Check if the artist exists by Display_Name, insert if not, and get artistID
    DECLARE @artistID INT;
    IF NOT EXISTS (SELECT 1 FROM [art_connection_db].[dbo].[Artist] WHERE [Display_Name] = @Display_Name)
    BEGIN
        INSERT INTO [art_connection_db].[dbo].[Artist] (
            [Display_Name], [Legal_Name], [Nationality], [Role], [Birth_Date], [Death_Date], 
            [source_identifyer_artist], [source_pk_ArtistID]
        )
        VALUES (
            @Display_Name, @Legal_Name, @Nationality, @Role, @Birth_Date, @Death_Date, 'cmoa_teenie', @source_pk_ArtistID
        );
        SET @artistID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SELECT @artistID = [artistID] FROM [art_connection_db].[dbo].[Artist] WHERE [Display_Name] = @Display_Name;
    END;

    -- Insert into Linker_Artist_To_Art table
    INSERT INTO [art_connection_db].[dbo].[Linker_Artist_To_Art] ([artID], [artistID])
    VALUES (@artID, @artistID);

    -- Insert into Linker_Art_In_Museum table
    INSERT INTO [art_connection_db].[dbo].[Linker_Art_In_Museum] ([artID], [museumID])
    VALUES (@artID, 3); -- Assuming 3 is the ID for CMOA Teenie

    -- Insert into linker_Art_In_Portfolio table
    INSERT INTO [art_connection_db].[dbo].[linker_Art_In_Portfolio] ([artID], [portfolioID])
    VALUES (@artID, @PortfolioID);

    -- Singular print statement for summary
    PRINT 'Processed artID: ' + CONVERT(VARCHAR, @artID) + ', Title: "' + LEFT(@Title, 50) + '", artistID: ' + CONVERT(VARCHAR, @artistID) + ', Artist Name: "' + LEFT(@Display_Name, 50) + '"';

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
        @catalogue_number, @Title, @Creation_Date, @Medium, @Credit_Line, @Department,
        @Dimensions, @Image_URL, @Repository, @source_pk_artID, @Web_URL,
        @Legal_Name, @Display_Name, @Nationality, @Role, @Birth_Date, @Death_Date, @source_pk_ArtistID;
END;

-- Close and deallocate the cursor
CLOSE ArtCursor;
DEALLOCATE ArtCursor;

-- Commit the transaction
COMMIT TRANSACTION;

-- Disable execution plan
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;