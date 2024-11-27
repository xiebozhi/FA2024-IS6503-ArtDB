-- Insert data for Carnegie Museum of Art
INSERT INTO [Museum] (
  [musuem_text_key], [Name], [City], [State], [Street], [Zip], [Zip5], [AKA_DBA], [ALT_Name], [Country], [Discipline], [Gallery_Space], [Legal_Name], [Mission], [Phone], [WebURL], [Year_established], [Admission], [source_identifyer_museum], [source_pk_musuemID]
) VALUES (
  'CMOA', 'Carnegie Museum of Art', 'Pittsburgh', 'PA', '4400 Forbes Avenue', '15213', '15213', 'CMOA', 'Carnegie Museum', 'USA', 'Contemporary Art', '5000', 'Carnegie Institute', 'To inspire and educate', '+1 412-622-3131', 'https://carnegieart.org', '1895', 'Adults: $20, Seniors (65+): $15, Students: $12, Children (3-18): $10, Under 3: Free', 'copilot', '1'
);

-- Insert data for Carnegie Museum of Art, Teenie Harris Archive
INSERT INTO [Museum] (
  [musuem_text_key], [Name], [City], [State], [Street], [Zip], [Zip5], [AKA_DBA], [ALT_Name], [Country], [Discipline], [Gallery_Space], [Legal_Name], [Mission], [Phone], [WebURL], [Year_established], [Admission], [source_identifyer_museum], [source_pk_musuemID]
) VALUES (
  'CMOA_teenie', 'Carnegie Museum of Art, Teenie Harris Archive', 'Pittsburgh', 'PA', '4400 Forbes Avenue', '15213', '15213', 'CMOA', 'Teenie Harris Archive', 'USA', 'Photography', '2000', 'Carnegie Institute', 'To preserve and share the works of Teenie Harris', '+1 412-622-3131', 'https://teenie.cmoa.org', '1895', 'Adults: $20, Seniors (65+): $15, Students: $12, Children (3-18): $10, Under 3: Free', 'copilot', '4'
);

-- Insert data for Museum of Modern Art (MoMA)
INSERT INTO [Museum] (
  [musuem_text_key], [Name], [City], [State], [Street], [Zip], [Zip5], [AKA_DBA], [ALT_Name], [Country], [Discipline], [Gallery_Space], [Legal_Name], [Mission], [Phone], [WebURL], [Year_established], [Admission], [source_identifyer_museum], [source_pk_musuemID]
) VALUES (
  'MMOA', 'Museum of Modern Art', 'New York', 'NY', '11 West 53rd Street', '10019', '10019', 'MoMA', 'Museum of Modern Art', 'USA', 'Modern and Contemporary Art', '6000', 'Museum of Modern Art', 'To connect people to the art of our time', '+1 212-708-9400', 'https://www.moma.org', '1929', 'Adults: $25, Seniors (65+): $18, Students: $14, Children under 12: Free', 'copilot', '2'
);

-- Insert data for Metropolitan Museum of Art (The Met)
INSERT INTO [Museum] (
  [musuem_text_key], [Name], [City], [State], [Street], [Zip], [Zip5], [AKA_DBA], [ALT_Name], [Country], [Discipline], [Gallery_Space], [Legal_Name], [Mission], [Phone], [WebURL], [Year_established], [Admission], [source_identifyer_museum], [source_pk_musuemID]
) VALUES (
  'Met', 'Metropolitan Museum of Art', 'New York', 'NY', '1000 Fifth Avenue', '10028', '10028', 'The Met', 'Metropolitan Museum', 'USA', 'Encyclopedic', '8000', 'Metropolitan Museum of Art', 'To connect people to creativity and knowledge', '+1 212-535-7710', 'https://www.metmuseum.org', '1870', 'Adults: $30, Seniors (65+): $22, Students: $17, Children under 12: Free', 'copilot', '3'
);
