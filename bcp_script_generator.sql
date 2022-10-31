declare @db_name nvarchar(255)
declare @svr_name nvarchar(255)
declare @filepath nvarchar(255)
declare @args nvarchar(255)

set @db_name = 'AdventureWorksDW2019'
set @svr_name = 'DONNY-DESKTOP'
set @filepath = 'C:\flat_files\'
set @args = '-T -c -C 65001'

select 'bcp ' + @db_name + '.' + sch.name + '.' + tbl.name + ' out ' 
  + @filepath + tbl.name + '.csv ' + '-S ' + @svr_name + ' ' + @args + ';' as bcp
from sys.tables as tbl
left join sys.schemas as sch
 on sch.schema_id = tbl.schema_id
order by tbl.name
;
