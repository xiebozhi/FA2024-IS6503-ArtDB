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
    [Object_Number] AS [source_pk_artID], -- Assign Object_Number to source_pk_artID
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
    [Portfolio],
    [Rights_and_Reproduction],
    [Object_Number] AS [source_pk_ArtistID] -- Assign Object_Number to source_pk_ArtistID
FROM 
    [art_connection_db].[dbo].[MetObjects]
WHERE 
    [Object_ID] IS NOT NULL;

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
    @source_pk_ArtistID VARCHAR(1000), 
    @Portfolio VARCHAR(1000), 
    @Classification VARCHAR(1000), 
    @Rights_and_Reproduction VARCHAR(255),
    @Object_Begin_Date VARCHAR(100), 
    @Object_End_Date VARCHAR(100);

-- Variable to count the number of records processed
DECLARE @RecordCount INT = 0;

-- Insert "Portfolio information not found" portfolio if not exists
DECLARE @DefaultPortfolioID INT;
IF NOT EXISTS (SELECT 1 FROM [art_connection_db].[dbo].[Portfolio] WHERE [Title] = 'Portfolio information not found')
BEGIN
    INSERT INTO [art_connection_db].[dbo].[Portfolio] ([Title], [Notes])
    VALUES ('Portfolio information not found', 'Default portfolio for artworks without specific portfolio information.');
    SET @DefaultPortfolioID = SCOPE_IDENTITY();
    -- PRINT 'Inserted PortfolioID ' + CONVERT(VARCHAR, @DefaultPortfolioID) + ' for "Portfolio information not found"';
END
ELSE
BEGIN
    SELECT @DefaultPortfolioID = [portfolioID] FROM [art_connection_db].[dbo].[Portfolio] WHERE [Title] = 'Portfolio information not found';
    -- PRINT 'Found existing PortfolioID ' + CONVERT(VARCHAR, @DefaultPortfolioID) + ' for "Portfolio information not found"';
END;

-- Open the cursor
OPEN ArtCursor;

-- Fetch the first row
FETCH NEXT FROM ArtCursor INTO 
    @catalogue_number, @Title, @Creation_Date, @Medium, @Credit_Line, @Department, 
    @Dimensions, @Image_URL, @Repository, @source_pk_artID, @Classification, 
    @Display_Name, @Legal_Name, @Nationality, @Role, @Birth_Date, @Death_Date, 
    @Object_Begin_Date, @Object_End_Date, @Portfolio, @Rights_and_Reproduction, @source_pk_ArtistID;

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
        @Dimensions, @Image_URL, @Repository, 'met', @source_pk_artID, @Web_URL
    );

    DECLARE @artID INT = SCOPE_IDENTITY();

    -- Check if the artist exists by Display_Name, insert if not, and get artistID
    DECLARE @artistID INT;
    IF NOT EXISTS (SELECT 1 FROM [art_connection_db].[dbo].[Artist] WHERE [Display_Name] = @Display_Name)
    BEGIN
        INSERT INTO [art_connection_db].[dbo].[Artist] (
            [Display_Name], [Legal_Name], [Nationality], [Role], [Birth_Date], [Death_Date], 
            [source_identifyer_artist], [source_pk_ArtistID]
        )
        VALUES (
            @Display_Name, @Legal_Name, @Nationality, @Role, @Birth_Date, @Death_Date, 'met', @source_pk_ArtistID
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
    VALUES (@artID, 2); -- Assuming 2 is the ID for MET

    -- Check if the portfolio exists, insert if not, and get portfolioID
    DECLARE @PortfolioID INT;
    IF @Portfolio IS NULL OR NOT EXISTS (SELECT 1 FROM [art_connection_db].[dbo].[Portfolio] WHERE [Title] = @Portfolio)
    BEGIN
        SET @PortfolioID = @DefaultPortfolioID;
    END
    ELSE
    BEGIN
        SELECT @PortfolioID = [portfolioID] FROM [art_connection_db].[dbo].[Portfolio] WHERE [Title] = @Portfolio;
    END;

    -- Insert into linker_Art_In_Portfolio table
    INSERT INTO [art_connection_db].[dbo].[linker_Art_In_Portfolio] ([artID], [portfolioID])
    VALUES (@artID, @PortfolioID);

    -- Singular print statement for summary
    PRINT 'Processed artID: ' + CONVERT(VARCHAR, @artID) + ', Title: "' + LEFT(@Title, 50) + '", artistID: ' + CONVERT(VARCHAR, @artistID) + ', Artist Name: "' + LEFT(@Display_Name, 50) + '", Portfolio: "' + LEFT(@Portfolio, 50) + '"';

    -- Increment the record count
    SET @RecordCount = @RecordCount + 1;
    SET @CurrentBatch = @CurrentBatch + 1;

    -- Commit transaction for the current batch
    IF @CurrentBatch >= @BatchSize
    BEGIN
        COMMIT TRANSACTION;
        SET @CurrentBatch = 0;
        BEGIN TRANSACTION;
    END

    -- Fetch the next row
    FETCH NEXT FROM ArtCursor INTO 
        @catalogue_number, @Title, @Creation_Date, @Medium, @Credit_Line, @Department, 
        @Dimensions, @Image_URL, @Repository, @source_pk_artID, @Classification, 
        @Display_Name, @Legal_Name, @Nationality, @Role, @Birth_Date, @Death_Date, 
        @Object_Begin_Date, @Object_End_Date, @Portfolio, @Rights_and_Reproduction, @source_pk_ArtistID;
END;

-- Close and deallocate the cursor
CLOSE ArtCursor;
DEALLOCATE ArtCursor;

-- Commit any remaining records
IF @CurrentBatch > 0
BEGIN
    COMMIT TRANSACTION;
END

PRINT 'Processing complete. Added ' + CONVERT(VARCHAR, @RecordCount) + ' records from source file: MET_objects';

-- Disable execution plan
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;