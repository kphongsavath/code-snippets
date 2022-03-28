 ;WITH _src
     AS (SELECT @SitecoreId SitecoreId,
                @ProviderId ProviderId,
                @ResearcherId ResearcherId)
    MERGE INTO api.ResearcherSitecoreLink trgt
    USING _src AS Src
    ON (Src.SitecoreId = trgt.SitecoreId)
    WHEN MATCHED THEN
        UPDATE SET trgt.ProviderId = Src.ProviderId,
                   trgt.ResearcherId = Src.ResearcherId,
                   trgt.ModifiedDate = GETDATE()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            SitecoreId,
            ProviderId,
            ResearcherId,
            AddDate,
            ModifiedDate,
            FormattedName
        )
        VALUES
        (   Src.SitecoreId,   -- SitecoreId - uniqueidentifier
            Src.ProviderId,   -- ProviderId - nvarchar(50)
            Src.ResearcherId, -- ResearcherId - bigint
            GETDATE(),        -- AddDate - datetime
            GETDATE(),        -- ModifiedDate - datetime
            N''               -- FormattedName - nvarchar(100)
            )
    OUTPUT $action AS [MergeActionResult];