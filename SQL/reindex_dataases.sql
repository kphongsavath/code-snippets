
IF OBJECT_ID('tempdb..#re_index_temp') IS NOT NULL
    DROP TABLE #re_index_temp;

DECLARE @master_compatibility_level INT,
        @sql_compatibility NVARCHAR(MAX);
DECLARE @databases TABLE
(
    database_name VARCHAR(100)
);


SELECT @master_compatibility_level = compatibility_level
FROM sys.databases
WHERE name = 'master';

INSERT INTO @databases
(
    database_name
)
SELECT name
FROM sys.databases
WHERE name LIKE 'sitecore%';

DECLARE Compatibilty_Cursor CURSOR FAST_FORWARD LOCAL FOR
SELECT database_name
FROM @databases;

DECLARE @db_name NVARCHAR(50);
DECLARE @re_index_sql NVARCHAR(500);
CREATE TABLE #re_index_temp
(
    sql_exc NVARCHAR(500)
);
OPEN Compatibilty_Cursor;
FETCH NEXT FROM Compatibilty_Cursor
INTO @db_name;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql_compatibility
        = N'ALTER DATABASE ' + @db_name + N' SET COMPATIBILITY_LEVEL ='
          + CAST(@master_compatibility_level AS NVARCHAR(10));
    ---EXECUTE sp_executesql  @sql_compatibility;

    SET @re_index_sql
        = N'Select ''ALTER INDEX ALL ON [' + @db_name
          + N'].['' + TABLE_SCHEMA + ''].['' + TABLE_NAME + ''] REBUILD ''  FROM ' + @db_name
          + N'.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = ''base table''';
    INSERT INTO #re_index_temp
    (
        sql_exc
    )
    EXECUTE sp_executesql @re_index_sql;
    DECLARE @sql_exc NVARCHAR(200);
    DECLARE Reindex_Cursor CURSOR FAST_FORWARD LOCAL FOR
    SELECT sql_exc
    FROM #re_index_temp;
    OPEN Reindex_Cursor;
    FETCH NEXT FROM Reindex_Cursor
    INTO @sql_exc;
    WHILE @@FETCH_STATUS = 0
    BEGIN

        EXECUTE sp_executesql @sql_exc;

        FETCH NEXT FROM Reindex_Cursor
        INTO @sql_exc;
    END;
    CLOSE Reindex_Cursor;
    DEALLOCATE Reindex_Cursor;

    TRUNCATE TABLE #re_index_temp;

    FETCH NEXT FROM Compatibilty_Cursor
    INTO @db_name;
END;
CLOSE Compatibilty_Cursor;
DEALLOCATE Compatibilty_Cursor;

IF OBJECT_ID('tempdb..#re_index_temp') IS NOT NULL
    DROP TABLE #re_index_temp;
EXEC sp_updatestats;
DBCC FREEPROCCACHE WITH NO_INFOMSGS;
