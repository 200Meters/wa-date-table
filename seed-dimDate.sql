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
DECLARE @biennium_start_date as SMALLDATETIME = '2013-07-01'
DECLARE @biennium_end_date as SMALLDATETIME = '2023-06-30'
DECLARE @date_count as INT = DATEDIFF(day, @biennium_start_date, @biennium_end_date) + 1
DECLARE @current_date_count as INT = 0

-- Declare column value variables
DECLARE @calendar_date as SMALLDATETIME
DECLARE @date_key as INT
DECLARE @day_of_week as TINYINT
DECLARE @day_number_overall as SMALLINT
DECLARE @day_name as VARCHAR(9)
DECLARE @day_abbreviation as VARCHAR(3)
DECLARE @weekday_flag as CHAR(1)
DECLARE @week_number_calendar_year as TINYINT
DECLARE @week_begin_date as SMALLDATETIME
DECLARE @week_begin_date_key as INT
DECLARE @calendar_year_month_number as TINYINT
DECLARE @month_name as VARCHAR(9)
DECLARE @month_abbreviation as VARCHAR(3)
DECLARE @calendar_quarter as VARCHAR(2)
DECLARE @calendar_year_quarter as SMALLINT
DECLARE @calendar_year as SMALLINT
DECLARE @month_end_flag as CHAR(1)
DECLARE @same_day_1_year_ago SMALLDATETIME
DECLARE @same_day_90_days_ago SMALLDATETIME
DECLARE @same_day_60_days_ago SMALLDATETIME
DECLARE @same_day_30_days_ago SMALLDATETIME
DECLARE @biennium as VARCHAR(12)
DECLARE @biennium_year as TINYINT
DECLARE @fiscal_year as SMALLINT
DECLARE @fiscal_quarter as VARCHAR(3)
DECLARE @fiscal_year_quarter as VARCHAR(7)
DECLARE @fiscal_month_number as TINYINT
DECLARE @fiscal_year_day_number as INT
DECLARE @fiscal_year_week_number as INT
DECLARE @biennium_day_number as INT

-- Declare temp variables for use in calculations
DECLARE @date_key_str as VARCHAR(8)
DECLARE @week_begin_date_key_str as VARCHAR(8)
DECLARE @fiscal_year_1_start_date as SMALLDATETIME
DECLARE @fiscal_year_1_end_date as SMALLDATETIME
DECLARE @calendar_quarter_number as TINYINT

-- Loop over the date count and insert a row for each date in the biennium
WHILE @current_date_count < @date_count
BEGIN
	--Set the current date and date key to enter
	SET @calendar_date = DATEADD(day,@current_date_count,@biennium_start_date)
	SET @date_key_str = STR(DATEPART(year,@calendar_date),4,0) + STR(DATEPART(month,@calendar_date),2,0) + STR(DATEPART(day,@calendar_date),2,0)
	SET @date_key_str = REPLACE(@date_key_str,' ','0') 
	SET @date_key = CAST(@date_key_str as INT) 

	-- Add day of week
	SET @day_of_week = DATEPART(weekday,@calendar_date)

	-- Add overall day number
	SET @day_number_overall = @current_date_count

	-- Add day name
	SET @day_name = DATENAME(weekday,@calendar_date)

	-- Add day abbreviation
	SET @day_abbreviation = LEFT(@day_name,3)

	-- Add weekday flag
	IF @day_name IN ('Saturday', 'Sunday')
       SET @weekday_flag = 'N'
	ELSE 
       SET @weekday_flag = 'Y'

	-- Add week number in the calendar year
	SET @week_number_calendar_year = DATEPART(week,@calendar_date)

	-- Add the date of the first day in the week
	SET DATEFIRST 7 -- Set Sunday as the first day of the week (US Default)
	SET @week_begin_date = DATEADD(weekday,(-1 * DATEPART(weekday,@calendar_date)),@calendar_date) 
	
	-- Add week begin date key 
	SET @week_begin_date_key_str = STR(DATEPART(year,@week_begin_date),4,0) + STR(DATEPART(month,@week_begin_date),2,0) + STR(DATEPART(day,@week_begin_date),2,0)
	SET @week_begin_date_key_str = REPLACE(@week_begin_date_key_str,' ','0') 
	SET @week_begin_date_key = CAST(@week_begin_date_key_str as INT) 

	-- Add month number of calendar year
	SET @calendar_year_month_number = DATEPART(month,@calendar_date)

	-- Add month name
	SET @month_name = DATENAME(month,@calendar_date)

	-- Add month abbreviation
	SET @month_abbreviation = LEFT(@month_name,3)

	-- Add calendar quarter
	SET @calendar_quarter_number = DATEPART(quarter,@calendar_date)
	SET @calendar_quarter = 'Q' + CAST(DATEPART(quarter,@calendar_date) as VARCHAR(1))

	-- Add calendar year
	SET @calendar_year = DATEPART(year, @calendar_date)

	-- Add calendar year and quarter (i.e. YYYYQ)
	SET @calendar_year_quarter = CAST(STR(@calendar_year,4,0) + STR(@calendar_quarter_number,1,0) as SMALLINT)

	-- Add month end flag
	IF @calendar_date = EOMONTH(@calendar_date)
		SET @month_end_flag = 'Y'
	ELSE
		SET @month_end_flag = 'N'

	-- Add same day one year, 90, 60, 30 days ago
	SET @same_day_1_year_ago = DATEADD(year,-1,@calendar_date)
	SET @same_day_90_days_ago = DATEADD(day,-90,@calendar_date)
	SET @same_day_60_days_ago = DATEADD(day,-60,@calendar_date)
	SET @same_day_30_days_ago = DATEADD(day,-30,@calendar_date)
	
	-- Add biennium 
	IF @calendar_year %2 > 0 -- year is odd
		IF DATEPART(dayofyear,@calendar_date) < DATEPART(dayofyear,CAST(CONCAT(STR(@calendar_year,4,0),'-07-01') as SMALLDATETIME))
			SET @biennium = 'BI ' + CAST(STR(@calendar_year-2,4,0) + '-' + STR(@calendar_year,4,0) as VARCHAR(9))
		ELSE
			SET @biennium = 'BI ' + CAST(STR(@calendar_year,4,0) + '-' + STR(@calendar_year + 2,4,0) as VARCHAR(9))
	ELSE -- year is even
		SET @biennium = 'BI ' + CAST(STR(@calendar_year - 1,4,0) + '-' + STR(@calendar_year + 1,4,0) as VARCHAR(9))

	-- Add biennium year (either year 1 or year 2 of the biennium)
	IF @calendar_year %2 > 0 -- year is odd
		IF DATEPART(dayofyear,@calendar_date) < DATEPART(dayofyear,CAST(CONCAT(STR(@calendar_year,4,0),'-07-01') as SMALLDATETIME))
			SET @biennium_year = 2
		ELSE
			SET @biennium_year = 1
	ELSE
		IF DATEPART(dayofyear,@calendar_date) < DATEPART(dayofyear,CAST(CONCAT(STR(@calendar_year,4,0),'-07-01') as SMALLDATETIME))
			SET @biennium_year = 1
		ELSE
			SET @biennium_year = 2

	-- Add fiscal year
	IF @calendar_year %2 > 0 --year is odd
		IF DATEPART(dayofyear,@calendar_date) < DATEPART(dayofyear,CAST(CONCAT(STR(@calendar_year,4,0),'-07-01') as SMALLDATETIME))
			SET @fiscal_year = @calendar_year
		ELSE
			SET @fiscal_year = @calendar_year + 1
	ELSE
		IF DATEPART(dayofyear,@calendar_date) < DATEPART(dayofyear,CAST(CONCAT(STR(@calendar_year,4,0),'-07-01') as SMALLDATETIME))
			SET @fiscal_year = @calendar_year
		ELSE
			SET @fiscal_year = @calendar_year + 1

	-- Add fiscal quarter
	IF @calendar_quarter_number IN (1,2)
		SET @fiscal_quarter = 'FQ' + CAST(@calendar_quarter_number + 2 as VARCHAR(2))
	ELSE
		SET @fiscal_quarter = 'FQ' + CAST(@calendar_quarter_number - 2 as VARCHAR(2))

	-- Add fiscal year and quarter (YYYYQ)
	SET @fiscal_year_quarter = CAST(STR(@fiscal_year,4,0) + @fiscal_quarter as VARCHAR(7))

	-- Add fiscal month number
	IF @biennium_year = 1
		IF @calendar_year_month_number < 7
			SET @fiscal_month_number = @calendar_year_month_number + 6
		ELSE
			SET @fiscal_month_number = @calendar_year_month_number - 6
	ELSE
		IF @calendar_year_month_number < 7
			SET @fiscal_month_number = @calendar_year_month_number + 18
		ELSE
			SET @fiscal_month_number = @calendar_year_month_number + 6

	-- Add fiscal year day number
	IF @calendar_year_month_number < 7
		SET @fiscal_year_day_number = DATEPART(dayofyear,DATEADD(month,6,@calendar_date))
	ELSE
		SET @fiscal_year_day_number = DATEPART(dayofyear,DATEADD(month,-6,@calendar_date))

	-- Add fiscal year week number
	IF @calendar_year_month_number < 7
		SET @fiscal_year_week_number = DATEPART(week,DATEADD(month,6,@calendar_date))
	ELSE
		SET @fiscal_year_week_number = DATEPART(week,DATEADD(month,-6,@calendar_date))

	-- Add biennium day number
	IF @biennium_year = 1
		SET @biennium_day_number = @fiscal_year_day_number
	ELSE
		BEGIN
			IF @calendar_year_month_number < 7
				BEGIN
					SET @fiscal_year_1_start_date = CAST(STR(@calendar_year - 1,4,0) as SMALLDATETIME)
					SET @fiscal_year_1_end_date = CAST(STR(@calendar_year,4,0) as SMALLDATETIME)
				END
			ELSE
				BEGIN
					SET @fiscal_year_1_start_date = CAST(STR(@calendar_year,4,0) as SMALLDATETIME)
					SET @fiscal_year_1_end_date = CAST(STR(@calendar_year + 1,4,0) as SMALLDATETIME)
				END
			SET @biennium_day_number = @fiscal_year_day_number + DATEDIFF(day,@fiscal_year_1_start_date,@fiscal_year_1_end_date) - 1
		END
			
	INSERT INTO dimDate (
		calendar_date,
		date_key,
		day_of_week,
		day_number_overall,
		day_name,
		day_abbreviation,
		weekday_flag,
		week_number_calendar_year,
		week_begin_date,
		week_begin_date_key,
		calendar_year_month_number,
		month_name,
		month_abbreviation,
		calendar_quarter,
		calendar_year,
		calendar_year_quarter,
		month_end_flag,
		same_day_1_year_ago,
		same_day_90_days_ago,
		same_day_60_days_ago,
		same_day_30_days_ago,
		biennium,
		biennium_year,
		fiscal_year,
		fiscal_quarter,
		fiscal_year_quarter,
		fiscal_month_number,
		fiscal_year_day_number,
		fiscal_year_week_number,
		biennium_day_number
		)
	VALUES (
		@calendar_date,
		@date_key,
		@day_of_week,
		@day_number_overall,
		@day_name,
		@day_abbreviation,
		@weekday_flag,
		@week_number_calendar_year,
		@week_begin_date,
		@week_begin_date_key,
		@calendar_year_month_number,
		@month_name,
		@month_abbreviation,
		@calendar_quarter,
		@calendar_year,
		@calendar_year_quarter,
		@month_end_flag,
		@same_day_1_year_ago,
		@same_day_90_days_ago,
		@same_day_60_days_ago,
		@same_day_30_days_ago,
		@biennium,
		@biennium_year,
		@fiscal_year,
		@fiscal_quarter,
		@fiscal_year_quarter,
		@fiscal_month_number,
		@fiscal_year_day_number,
		@fiscal_year_week_number,
		@biennium_day_number
		)
	
	-- Increment date count by 1 to feed the loop
	SET @current_date_count = @current_date_count + 1
END

