SELECT 
    a.[Title] AS [Artwork Title],
    a.[Medium],
    a.[creation_date],
    m.[Name] AS [Museum Name],
    m.[City] AS [Museum City],
    m.[Country] AS [Museum Country],
    m.[WEBURL] AS [Museum Website]
FROM 
    [Artist] ar
JOIN 
    [Linker_Artist_To_Art] laa ON ar.[artistID] = laa.[artistID]
JOIN 
    [Artwork] a ON laa.[artID] = a.[artID]
JOIN 
    [Linker_Art_In_Museum] lam ON a.[artID] = lam.[artID]
JOIN 
    [Museum] m ON lam.[musuemID] = m.[musuemID]
WHERE 
    ar.[Artist Display Name] = 'Artist Name'; -- Replace 'Artist Name' with the desired artist's name
