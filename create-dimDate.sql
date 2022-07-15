/**
DDL to create dimDate table for State of Washington Fiscal years
**/


CREATE TABLE wa_fiscal.[dbo].dimDate (
	date_key SMALLINT NOT NULL,
	calendar_date SMALLDATETIME,
	day_of_week TINYINT,
	day_number_overall SMALLINT,
	day_name VARCHAR(9),
	day_abbreviation VARCHAR(3),
	weekday_flag CHAR(1),
	week_number_calendar_year TINYINT,
	week_number_overall SMALLINT,
	week_begin_date SMALLDATETIME,
	week_begin_date_key SMALLINT,
	calendar_year_month_number TINYINT,
	calendar_year_month_number_overall SMALLINT,
	month_name VARCHAR(9),
	month_abbreviation VARCHAR(3),
	calendar_quarter TINYINT, 
	calendar_year SMALLINT,
	calendar_year_quarter SMALLINT,
	month_end_flag CHAR(1),
	same_day_1_year_ago SMALLDATETIME,
	same_day_90_days_ago SMALLDATETIME,
	same_day_60_days_ago SMALLDATETIME,
	same_day_30_days_ago SMALLDATETIME,
	biennium SMALLINT,
	biennium_year TINYINT,
	fiscal_year SMALLINT,
	fiscal_quarter TINYINT,
	fiscal_year_quarter SMALLINT,
	fiscal_month_number TINYINT,
	fiscal_year_day_number SMALLINT,
	fiscal_year_week_number SMALLINT,
	biennium_day_number SMALLINT
)