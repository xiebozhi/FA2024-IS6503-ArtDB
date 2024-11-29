-- Switch to the target database
USE [art_connection_db];
-- Drop and create the database
IF DB_ID('art_connection_db') IS NOT NULL
BEGIN
  ALTER DATABASE [art_connection_db] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE [art_connection_db];
END
CREATE DATABASE [art_connection_db];

-- Drop indexes
DROP INDEX IF EXISTS idx_carn_cmoa_id ON [art_connection_db].[dbo].[carnigie_cmoa];
DROP INDEX IF EXISTS idx_carn_teenie_id ON [art_connection_db].[dbo].[carnigie_teenie];
DROP INDEX IF EXISTS idx_met_Object_ID ON [art_connection_db].[dbo].[MetObjects];
DROP INDEX IF EXISTS idx_met_Object_Number ON [art_connection_db].[dbo].[MetObjects];
DROP INDEX IF EXISTS idx_mod_Artwork_ID ON [art_connection_db].[dbo].[MMOA_artworks];
DROP INDEX IF EXISTS idx_mod_Artist_ID1 ON [art_connection_db].[dbo].[MMOA_artworks];
DROP INDEX IF EXISTS idx_mod_Artist_ID2 ON [art_connection_db].[dbo].[MMOA_artists];

-- Drop linker tables
DROP TABLE IF EXISTS [art_connection_db].[dbo].[Linker_Artist_To_Art];
DROP TABLE IF EXISTS [art_connection_db].[dbo].[linker_Art_In_Portfolio];
DROP TABLE IF EXISTS [art_connection_db].[dbo].[Linker_Art_In_Museum];

-- Drop main tables
DROP TABLE IF EXISTS [art_connection_db].[dbo].[Portfolio];
DROP TABLE IF EXISTS [art_connection_db].[dbo].[Museum];
DROP TABLE IF EXISTS [art_connection_db].[dbo].[Artwork];
DROP TABLE IF EXISTS [art_connection_db].[dbo].[Artist];

-- Create Artist Table
CREATE TABLE [art_connection_db].[dbo].[Artist] (
  [artistID] INT IDENTITY(1,1) PRIMARY KEY,
  [Display_Bio] VARCHAR(8000) NULL,
  [Display_Name] VARCHAR(8000) NULL,
  [Legal_Name] VARCHAR(100) NULL,
  [Nationality] VARCHAR(8000) NULL,
  [Role] VARCHAR(8000) NULL,
  [Birth_Date] VARCHAR(50) NULL,
  [Death_Date] VARCHAR(50) NULL,
  [source_identifyer_artist] VARCHAR(1000) NOT NULL,
  [source_pk_ArtistID] VARCHAR(1000) NOT NULL,
  [Gender] VARCHAR(100) NULL
);

-- Create Artwork Table
CREATE TABLE [art_connection_db].[dbo].[Artwork] (
  [artID] INT IDENTITY(1,1) PRIMARY KEY,
  [catalogue_number] VARCHAR(100) NULL,
  [City] VARCHAR(100) NULL,
  [Country] VARCHAR(100) NULL,
  [Creation_Date] VARCHAR(100) NULL,
  [Credit_Line] VARCHAR(8000) NULL,
  [Culture] VARCHAR(100) NULL,
  [Description] VARCHAR(8000) NULL,
  [Department] VARCHAR(100) NULL,
  [Dimensions] VARCHAR(8000) NULL,
  [Duration] VARCHAR(100) NULL,
  [Dynasty] VARCHAR(100) NULL,
  [Excavation] VARCHAR(255) NULL,
  [Geography] VARCHAR(100) NULL,
  [Image_URL] VARCHAR(8000) NULL,
  [Locale] VARCHAR(100) NULL,
  [Locus] VARCHAR(100) NULL,
  [Medium] VARCHAR(8000) NULL,
  [Work_Begin_Date] VARCHAR(100) NULL,
  [Work_Completion_Date] VARCHAR(100) NULL,
  [Date] VARCHAR(255) NULL,
  [source_identifyer_art] VARCHAR(1000) NOT NULL,
  [source_pk_artID] VARCHAR(1000) NOT NULL,
  [Title] VARCHAR(2000) NULL,
  [Period] VARCHAR(100) NULL,
  [Region] VARCHAR(100) NULL,
  [Reign] VARCHAR(100) NULL,
  [Repository] VARCHAR(100) NULL,
  [Rights_and_Reproduction] VARCHAR(255) NULL,
  [River] VARCHAR(100) NULL,
  [State] VARCHAR(100) NULL,
  [Subregion] VARCHAR(100) NULL,
  [Web_URL] VARCHAR(100) NULL,
  [Weight] VARCHAR(100) NULL
);

-- Create Museum Table
CREATE TABLE [art_connection_db].[dbo].[Museum] (
  [museumID] INT IDENTITY(1,1) PRIMARY KEY,
  [museum_text_key] VARCHAR(50) NULL,
  [Name] VARCHAR(255) NOT NULL,
  [City] VARCHAR(100) NULL,
  [State] VARCHAR(100) NULL,
  [Street] VARCHAR(100) NULL,
  [Zip] VARCHAR(100) NULL,
  [AKA_DBA] VARCHAR(255) NULL,
  [ALT_Name] VARCHAR(100) NULL,
  [Country] VARCHAR(100) NULL,
  [Discipline] VARCHAR(100) NULL,
  [Gallery_Space] VARCHAR(100) NULL,
  [Legal_Name] VARCHAR(255) NULL,
  [Mission] VARCHAR(8000) NULL,
  [Phone] VARCHAR(100) NULL,
  [WebURL] VARCHAR(500) NULL,
  [Year_established] VARCHAR(100) NULL,
  [Admission] VARCHAR(1000) NULL,
  [source_identifyer_museum] VARCHAR(1000) NOT NULL,
  [source_pk_museumID] VARCHAR(1000) NOT NULL
);

-- Create Portfolio Table
CREATE TABLE [art_connection_db].[dbo].[Portfolio] (
  [portfolioID] INT IDENTITY(1,1) PRIMARY KEY,
  [Title] VARCHAR(8000) NULL,
  [Notes] VARCHAR(1000) NULL
);

-- Create Linker_Artist_To_Art Table
CREATE TABLE [art_connection_db].[dbo].[Linker_Artist_To_Art] (
  [l_artistToArtID] INT IDENTITY(1,1) PRIMARY KEY,
  [artID] INT NOT NULL,
  [artistID] INT NOT NULL,
  FOREIGN KEY (artID) REFERENCES [art_connection_db].[dbo].[Artwork](artID),
  FOREIGN KEY (artistID) REFERENCES [art_connection_db].[dbo].[Artist](artistID)
);

-- Create linker_Art_In_Portfolio Table
CREATE TABLE [art_connection_db].[dbo].[linker_Art_In_Portfolio] (
  [l_portfolioID] INT IDENTITY(1,1) PRIMARY KEY,
  [portfolioID] INT NOT NULL,
  [artID] INT NOT NULL,
  FOREIGN KEY (portfolioID) REFERENCES [art_connection_db].[dbo].[Portfolio](portfolioID),
  FOREIGN KEY (artID) REFERENCES [art_connection_db].[dbo].[Artwork](artID)
);

-- Create Linker_Art_In_Museum Table
CREATE TABLE [art_connection_db].[dbo].[Linker_Art_In_Museum] (
  [l_aimID] INT IDENTITY(1,1) PRIMARY KEY,
  [artID] INT NOT NULL,
  [museumID] INT NOT NULL,
  [Department] VARCHAR(500) NULL,
  [Location] VARCHAR(500) NULL,
  FOREIGN KEY (artID) REFERENCES [art_connection_db].[dbo].[Artwork](artID),
  FOREIGN KEY (museumID) REFERENCES [art_connection_db].[dbo].[Museum](museumID)
);

-- Alter index column data types based on the rounded-up lengths (64)
ALTER TABLE [art_connection_db].[dbo].[carnigie_cmoa] ALTER COLUMN [id] VARCHAR(64);
ALTER TABLE [art_connection_db].[dbo].[carnigie_teenie] ALTER COLUMN [id] VARCHAR(64);
ALTER TABLE [art_connection_db].[dbo].[MetObjects] ALTER COLUMN [Object_ID] VARCHAR(64);
ALTER TABLE [art_connection_db].[dbo].[MetObjects] ALTER COLUMN [Object_Number] VARCHAR(64);
ALTER TABLE [art_connection_db].[dbo].[MMOA_artworks] ALTER COLUMN [Artwork_ID] VARCHAR(64);
ALTER TABLE [art_connection_db].[dbo].[MMOA_artists] ALTER COLUMN [Artist_ID] VARCHAR(64);

-- Create indexes
CREATE INDEX idx_carn_cmoa_id ON [art_connection_db].[dbo].[carnigie_cmoa] ([id]);
CREATE INDEX idx_carn_teenie_id ON [art_connection_db].[dbo].[carnigie_teenie] ([id]);
CREATE INDEX idx_met_Object_ID ON [art_connection_db].[dbo].[MetObjects] ([Object_ID]);
CREATE INDEX idx_met_Object_Number ON [art_connection_db].[dbo].[MetObjects] ([Object_Number]);
CREATE INDEX idx_mod_Artwork_ID ON [art_connection_db].[dbo].[MMOA_artworks] ([Artwork_ID]);
CREATE INDEX idx_mod_Artist_ID1 ON [art_connection_db].[dbo].[MMOA_artworks] ([Artist_ID]);
CREATE INDEX idx_mod_Artist_ID2 ON [art_connection_db].[dbo].[MMOA_artists] ([Artist_ID]);

-- Insert data into Museum table
INSERT INTO [art_connection_db].[dbo].[Museum] 
(museum_text_key, Name, City, State, Street, Zip, AKA_DBA, ALT_Name, Country, Discipline, Gallery_Space, Legal_Name, Mission, Phone, WebURL, Year_established, Admission, source_identifyer_museum, source_pk_museumID) 
VALUES 
('CMOA', 'Carnegie Museum of Art', 'Pittsburgh', 'PA', '4400 Forbes Avenue', '15213', 'CMOA', 'Carnegie Museum', 'USA', 'Contemporary Art', '5000', 'Carnegie Institute', 'To inspire and educate', '+1 412-622-3131', 'https://carnegieart.org', '1895', 'Adults: $20, Seniors (65+): $15, Students: $12, Children (3-18): $10, Under 3: Free', 'copilot', '1'),
('MMOA', 'Museum of Modern Art', 'New York', 'NY', '11 West 53rd Street', '10019', 'MoMA', 'Museum of Modern Art', 'USA', 'Modern and Contemporary Art', '6000', 'Museum of Modern Art', 'To connect people to the art of our time', '+1 212-708-9400', 'https://www.moma.org', '1929', 'Adults: $25, Seniors (65+): $18, Students: $14, Children under 12: Free', 'copilot', '2'),
('Met', 'Metropolitan Museum of Art', 'New York', 'NY', '1000 Fifth Avenue', '10028', 'The Met', 'Metropolitan Museum', 'USA', 'Encyclopedic', '8000', 'Metropolitan Museum of Art', 'To connect people to creativity and knowledge', '+1 212-535-7710', 'https://www.metmuseum.org', '1870', 'Adults: $30, Seniors (65+): $22, Students: $17, Children under 12: Free', 'copilot', '3');
