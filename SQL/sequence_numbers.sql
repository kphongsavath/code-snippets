-- Current Sequence
SELECT TOP 1 current_value SequenceNumber
FROM sys.sequences s
WHERE s.[NAME] = 'seq_pageItem_'+ @environment;

--Next Sequence
declare @sql NVARCHAR(200);
SET @sql = N'SELECT NEXT VALUE FOR dbo.seq_pageItem_'+ @environment + ' AS SequenceNumber';

EXEC sp_executesql @sql;
