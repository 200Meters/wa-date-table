/**
	Insert values into the dimDate table
**/


/**
	Declare date variables to initiate. 
	biennium_start_date must be the first date in the first biennium for which you want to create the table.
	biennium_end_date must be the last date of the last biennium for which you want to creat the table
**/

-- Use database
USE wa_fiscal
GO

--Declare seeding date variables
DECLARE @biennium_start_date as SMALLDATETIME = '2021-07-01'
DECLARE @biennium_end_date as SMALLDATETIME = '2023-06-30'
DECLARE @date_count as SMALLINT = DATEDIFF(day, @biennium_start_date, @biennium_end_date) + 1
DECLARE @current_date_count as SMALLINT = 0

-- Declare column value variables
DECLARE @calendar_date as SMALLDATETIME
DECLARE @date_key as SMALLDATETIME

-- Loop over the date count and insert a row for each date in the biennium
WHILE @current_date_count < @date_count
BEGIN
	--Set the current date to enter
	SET @calendar_date = DATEADD(day,@current_date_count,@biennium_start_date)
	
	INSERT INTO dimDate (
		calendar_date,
		date_key
		)
	VALUES (
		@calendar_date,
		1
		)
	
	-- Increment date count by 1 to feed the loop
	SET @current_date_count = @current_date_count + 1
END

SELECT * FROM dimDate ORDER BY calendar_date ASC

--DELETE FROM dimDate
