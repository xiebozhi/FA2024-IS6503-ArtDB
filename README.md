# FA2024-IS6503-ArtDB

A database made for class to import from 3 major museums and normalize the data.

## Project Overview

This project involves the creation and management of a comprehensive art database that integrates data from multiple renowned museums. The database includes information about artworks, artists, museums, and portfolios. The project also includes various SQL scripts to create tables, insert data, and perform complex queries to analyze and manage the data.

## Data Sources

The data for this project is sourced from the following datasets:

1. **Carnegie Museum of Art (CMOA)**
   - **File Name**: carnigie_cmoa.csv
   - **Source Link**: [Kaggle - Carnegie Museum of Art](https://www.kaggle.com/datasets/mfrancis23/carnegie-museum-of-art?select=cmoa.csv)
   - **Source Notes**: This dataset contains data on approximately 28,269 objects across all departments of the museum, including fine arts, decorative arts, photography, contemporary art, and the Heinz Architectural Center.

2. **Teenie Harris Archive (CMOA Teenie)**
   - **File Name**: carnigie_teenie.csv
   - **Source Link**: [Kaggle - Carnegie Museum of Art](https://www.kaggle.com/datasets/mfrancis23/carnegie-museum-of-art?select=teenie.csv)
   - **Source Notes**: This dataset includes metadata for the Teenie Harris Archive, containing approximately 59,031 records.

3. **Metropolitan Museum of Art (Met)**
   - **File Name**: MetObjects.csv
   - **Source Link**: [Kaggle - The Metropolitan Museum of Art](https://www.kaggle.com/datasets/metmuseum/the-metropolitan-museum-of-art-open-access)
   - **Source Notes**: This dataset provides information on more than 420,000 artworks in the Met's collection, available for unrestricted commercial and noncommercial use under Creative Commons Zero.

4. **Museum of Modern Art (MoMA)**
   - **File Name**: MMOA_artists.csv
   - **Source Link**: [Kaggle - Museum Collection](https://www.kaggle.com/datasets/momanyc/museum-collection?select=artists.csv)
   - **Source Notes**: This dataset contains metadata for 15,091 artists who have work in MoMA's collection.

5. **Museum of Modern Art (MoMA)**
   - **File Name**: MMOA_artworks.csv
   - **Source Link**: [Kaggle - Museum Collection](https://www.kaggle.com/datasets/momanyc/museum-collection?select=artworks.csv)
   - **Source Notes**: This dataset includes information on 130,262 artworks in MoMA's collection.

## How to Use

1. **Create the Database and Tables**:
   - Run the `CREATE_SCRIPT.SQL` to create the necessary tables and indexes in the database.

2. **Import CSVs**:
   - Use MS SQL Server Management Studio's flat file import functionality to import the CSV files. Accept nulls on every column and declare everything as `varchar(max)`.

3. **Insert Data**:
   - Run the `INSERT_SCRIPT_MMOA.SQL`, `INSERT_SCRIPT_MET.SQL`, `INSERT_SCRIPT_CMOA.SQL`, and `INSERT_SCRIPT_CMOA_TEENIE.SQL` to insert data from the respective datasets into the database.

4. **Perform Queries**:
   - Use the provided use case scripts (`USE_CASE_1_ARTIST_ACROSS_MUSUEMS.SQL` to `USE_CASE_10_ANALYSIS.SQL`) to perform various queries and analyze the data.

5. **Verify Data**:
   - Run the `INSERTION_UNIT_TESTING.SQL` to verify the data insertion and ensure the integrity of the data.

## License

This project uses datasets that are available for unrestricted commercial and noncommercial use under Creative Commons Zero. Please refer to the respective dataset sources for more information on licensing.

## Acknowledgments

- **Carnegie Museum of Art** for providing the CMOA and Teenie Harris Archive datasets.
- **The Metropolitan Museum of Art** for providing the MetObjects dataset.
- **Museum of Modern Art (MoMA)** for providing the artists and artworks datasets.

This project aims to integrate and analyze data from these renowned museums to provide valuable insights and facilitate further research and exploration in the field of art.