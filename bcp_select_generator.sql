/*************************************************************************************************************************************

	Title:		Create BCP Scripts with SELECT Statements
	Author:		Donny Seward Jr
	Email:		ddsewardj@gmail.com
	Desc:
	The script generates BCP scripts to export data from all tables in the designated database.

*************************************************************************************************************************************/

declare @tbl nvarchar(255);


declare @db_name nvarchar(255);
declare @svr_name nvarchar(255);
declare @filepath nvarchar(255);
declare @args nvarchar(255);
declare @string nvarchar(max);

set @db_name = 'AdventureWorksDW2019'
set @svr_name = 'DONNY-DESKTOP'
set @filepath = 'C:\flat_files\'
set @args = '-T -c -C 65001'

set @tbl = 'DatabaseLog';
set @db_name = 'AdventureWorksDW2019';

-- Find the last column to determine where comma should end.
with cte (TABLE_NAME, MAX_POS) as
(
select TABLE_NAME, max(ORDINAL_POSITION) as MAX_POS
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = @tbl
  and (CHARACTER_MAXIMUM_LENGTH IS NULL OR CHARACTER_MAXIMUM_LENGTH <> -1)
group by TABLE_NAME
)

select
  @string = coalesce(@string + '' + q1.script, q1.script)
from
(
	-- SELECT
	select 1.0 as "section", 1 as col_order, 'bcp "SELECT ' as script

union

	-- LIST OF COLUMNS
	select 
	  2.0 as "section",
	  col.ORDINAL_POSITION as col_order,
	   
	  case when col.DATA_TYPE = 'datetime' then 'CONVERT(DATETIME2(0), [' + col.COLUMN_NAME + ']) as [' + col.COLUMN_NAME + ']'
		   else '[' + col.COLUMN_NAME + ']' end
	+ case 
		when col.ORDINAL_POSITION = cte.MAX_POS then '' 
		else ', ' 
		end as script 
	from INFORMATION_SCHEMA.COLUMNS as col
	left join cte
	 on col.TABLE_NAME = cte.TABLE_NAME
	where COL.TABLE_NAME = @tbl
	  and (CHARACTER_MAXIMUM_LENGTH IS NULL OR CHARACTER_MAXIMUM_LENGTH <> -1)

union

	-- FROM
	select 3.0 as "section", 1 as col_order, ' FROM ' as script

union

	-- DATABASE + SCHEMA + TABLE NAME
	select 4.0 as "section", 1 as col_order, 
	  col.TABLE_CATALOG + '.' + col.TABLE_SCHEMA + '.' + col.TABLE_NAME as script
	from INFORMATION_SCHEMA.COLUMNS as col
	where col.TABLE_NAME = @tbl

union

	-- FROM
	select 5.0 as "section", 1 as col_order, '" queryout ' 
	+ @filepath + @tbl + '.csv ' + '-S ' + @svr_name + ' ' + @args + ';'
	as script

	) as q1
	order by q1.section, q1.col_order

select @string as bcp_script;
