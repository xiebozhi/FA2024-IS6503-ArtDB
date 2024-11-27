-- Insert into Artwork table from MMOA_artworks
INSERT INTO [Artwork] ([catalogue_number], [Title], [creation_date], [Medium], [Dimensions], [date_acquired], [Credit Line], [Department], [classification], [Weight (kg)], [Duration (s)], [source_fk_Object_ID])
SELECT DISTINCT 
  [Object_Number] AS [catalogue_number],
  [Title],
  [Date] AS [creation_date],
  [Medium],
  CONCAT_WS(', ', [Diameter_cm], [Circumference_cm], [Height_cm], [Length_cm], [Width_cm], [Depth_cm]) AS [Dimensions],
  [Acquisition_Date] AS [date_acquired],
  [Credit] AS [Credit Line],
  [Department],
  [Classification] AS [classification],
  [Weight_kg] AS [Weight (kg)],
  [Duration_s] AS [Duration (s)],
  [Artwork_ID] AS [source_fk_Object_ID]
FROM [art_connection_db].[dbo].[MMOA_artworks];

-- Insert into Artist table from MMOA_artists
INSERT INTO [Artist] ([Artist Display Name], [Artist Nationality], [Gender], [Birth Date], [Death Date], [source_fk_ArtistID])
SELECT DISTINCT 
  [Name] AS [Artist Display Name],
  [Nationality] AS [Artist Nationality],
  [Gender],
  [Birth_Year] AS [Birth Date],
  [Death_Year] AS [Death Date],
  [Artist_ID] AS [source_fk_ArtistID]
FROM [art_connection_db].[dbo].[MMOA_artists];

-- Insert into Artwork table from MetObjects
INSERT INTO [Artwork] ([catalogue_number], [Title], [creation_date], [Medium], [Dimensions], [Credit Line], [Department], [classification], [Geography Type], [City], [State], [County], [Country], [Region], [Subregion], [Locale], [Locus], [Excavation], [River], [Rights and Reproduction], [image_url], [repository], [source_fk_Object_ID])
SELECT DISTINCT 
  [Object_Number] AS [catalogue_number],
  [Title],
  [Object_Date] AS [creation_date],
  [Medium],
  [Dimensions],
  [Credit_Line] AS [Credit Line],
  [Department],
  [Classification] AS [classification],
  [Geography_Type],
  [City],
  [State],
  [County],
  [Country],
  [Region],
  [Subregion],
  [Locale],
  [Locus],
  [Excavation],
  [River],
  [Rights_and_Reproduction] AS [Rights and Reproduction],
  [Link_Resource] AS [image_url],
  [Repository],
  [Object_ID] AS [source_fk_Object_ID]
FROM [art_connection_db].[dbo].[MetObjects];

-- Insert into Artwork table from carnigie_teenie
INSERT INTO [Artwork] ([catalogue_number], [Title], [creation_date], [creation_date_earliest], [creation_date_latest], [Medium], [Credit Line], [Department], [classification], [Dimensions], [image_url], [repository], [source_fk_Object_ID], [web_url])
SELECT DISTINCT 
  [accession_number] AS [catalogue_number],
  [title] AS [Title],
  [creation_date],
  [creation_date_earliest],
  [creation_date_latest],
  [medium] AS [Medium],
  [credit_line] AS [Credit Line],
  [department] AS [Department],
  [classification],
  CONCAT_WS(', ', [item_width], [item_height], [item_depth], [item_diameter]) AS [Dimensions],
  [image_url],
  [physical_location] AS [repository],
  [id] AS [source_fk_Object_ID],
  [web_url]
FROM [art_connection_db].[dbo].[carnigie_teenie];

-- Insert into Artist table from carnigie_teenie
INSERT INTO [Artist] ([Artist Display Name], [Artist Nationality], [role], [Birth Date], [Death Date], [source_fk_ArtistID])
SELECT DISTINCT 
  [full_name] AS [Artist Display Name],
  [nationality] AS [Artist Nationality],
  [role],
  [birth_date] AS [Birth Date],
  [death_date] AS [Death Date],
  [artist_id] AS [source_fk_ArtistID]
FROM [art_connection_db].[dbo].[carnigie_teenie];

-- Insert into Artwork table from carnigie_cmoa
INSERT INTO [Artwork] ([catalogue_number], [Title], [creation_date], [creation_date_earliest], [creation_date_latest], [Medium], [Credit Line], [Department], [classification], [Dimensions], [image_url], [repository], [source_fk_Object_ID], [web_url])
SELECT DISTINCT 
  [accession_number] AS [catalogue_number],
  [title] AS [Title],
  [creation_date],
  [creation_date_earliest],
  [creation_date_latest],
  [medium] AS [Medium],
  [credit_line] AS [Credit Line],
  [department] AS [Department],
  [classification],
  CONCAT_WS(', ', [item_width], [item_height], [item_depth], [item_diameter]) AS [Dimensions],
  [image_url],
  [physical_location] AS [repository],
  [id] AS [source_fk_Object_ID],
  [web_url]
FROM [art_connection_db].[dbo].[carnigie_cmoa];

-- Insert into Artist table from carnigie_cmoa
INSERT INTO [Artist] ([Artist Display Name], [Artist Nationality], [role], [Birth Date], [Death Date], [source_fk_ArtistID])
SELECT DISTINCT 
  [full_name] AS [Artist Display Name],
  [nationality] AS [Artist Nationality],
  [role],
  [birth_date] AS [Birth Date],
  [death_date] AS [Death Date],
  [artist_id] AS [source_fk_ArtistID]
FROM [art_connection_db].[dbo].[carnigie_cmoa];

-- Linker_Artist_To_Art table
INSERT INTO [Linker_Artist_To_Art] ([artID], [artistID])
SELECT DISTINCT 
  A.[artID], 
  T.[artistID]
FROM [Artwork] A
JOIN [Artist] T ON A.[source_fk_Object_ID] = T.[source_fk_ArtistID];

-- Linker_Art_In_Portfolio table (assuming Portfolio to Artwork)
INSERT INTO [linker_Art_In_Portfolio] ([portfolioID], [artID])
SELECT DISTINCT 
  P.[portfolioID],
  A.[artID]
FROM [Portfolio] P
JOIN [Artwork] A ON P.[artID] = A.[artID];

-- Insert into Linker_Art_In_Museum table (assuming there is a direct mapping)
INSERT INTO [Linker_Art_In_Museum] ([artID], [musuemID], [Department], [Location])
SELECT DISTINCT 
  A.[artID], 
  LM.[musuemID],
  A.[Department],
  A.[repository] AS [Location]
FROM [Artwork] A
JOIN [Linker_Art_In_Museum] LM ON A.[artID] = LM.[artID]
JOIN [Museum] M ON LM.[musuemID] = M.[musuemID];





