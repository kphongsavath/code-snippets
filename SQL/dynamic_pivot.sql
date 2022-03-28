  DECLARE @DynamicPivotQuery AS NVARCHAR(MAX);
    DECLARE @ColumnName AS NVARCHAR(MAX);
    IF OBJECT_ID('tempdb..##DoctorAttributes') IS NOT NULL
        DROP TABLE ##DoctorAttributes;


    SELECT @ColumnName = ISNULL(@ColumnName + ',', '') + QUOTENAME(AttributeName)
    FROM
    (
        SELECT DISTINCT
               AttributeName
        FROM dbo.DoctorAttributes
        WHERE NOT EXISTS
        (
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = N'Doctor_WexApi'
                  AND COLUMN_NAME = AttributeName
        )
    ) AS doctorAttributes;

    --Prepare the PIVOT query using the dynamic 
    SET @DynamicPivotQuery
        = N'
  SELECT  ParentDoctor,' + @ColumnName
          + N'
   Into ##DoctorAttributes
    FROM (	  
	SELECT ParentDoctor,AttributeName, AttributeValue FROM [dbo].[vw_DoctorAttributes]
	) x
    PIVOT(
	Max(AttributeValue) 
          FOR AttributeName IN (' + @ColumnName + N')
		  ) AS PVTTable ';
    --Execute the Dynamic Pivot Query
    EXEC sp_executesql @DynamicPivotQuery;

    SELECT p.*,
           da.*
    FROM [dbo].[vw_Providers] p
        LEFT OUTER JOIN ##DoctorAttributes da
            ON da.ParentDoctor = p.ProviderId;

