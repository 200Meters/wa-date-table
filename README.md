# wa-date-table
Public agencies typically use a fiscal calendar different from the calendar year. In the state of Washington the fiscal calendar is organized into a two-fiscal-year biennium ending in odd years (e.g., Biennium 2123 which includes FY22 and FY23). Each fiscal year runs from July 1st through June 30th. For example, biennium 2123 contains fiscal years 2022 and 2023. Fiscal year 2022 starts on July 1, 2021 and runs through June 30, 2022. Each fiscal year has 12 fiscal months representing the calendar months of the year, but on a fiscal schedule (e.g., July of biennium year 1 is FM01 and June of biennium year 2 is FM 24). 

When dealing with financial data in WA for budgeting, accounting, and treasury purposes, it's important to be able to express the data in accordance with the fiscal calendar. This repository contains both SQL and Power M Query scripts to implement a fiscal date table for Washington State financial reporting and analytic purposes. Note that this is a simple date table for use in reporting cash-based financials. It does not replicate Washington's encumbrance accounting date structures (e.g., AFRS FM 25, phase-based cutoffs, etc.), nor does it include operational dates (e.g., it does not account for holidays or other non-work days for the state). 

For the SQL script, access the file directly. I have also included the text of the Power Query custom dimDate function below or you can access it in the .pbix file. Note that WA uses a 6/30 fiscal year end date, but the script can be used for any fiscal year end by adjusting the start and end dates. Also, you can easily add or remove features if the ones below aren't exactly what you need.

```
//Create Date Dimension
(BienniumStartDate as date, BienniumEndDate as date)=>

let
    //Get the date range from the input params - note that biennium start and end can span multiple biennia, but must match the state biannial calenda
    //and must start on 7/1 and end on 6/30
    BienniumStartDate = #date(Date.Year(BienniumStartDate), Date.Month(BienniumStartDate), Date.Day(BienniumStartDate)),
    BienniumEndDate = #date(Date.Year(BienniumEndDate), Date.Month(BienniumEndDate), Date.Day(BienniumEndDate)),

    //Get the number of dates that will be required for the table
    GetDateCount = Duration.Days(BienniumEndDate - BienniumStartDate) + 1,

    //Take the count of dates and turn it into a list of dates
    GetDateList = List.Dates(BienniumStartDate, GetDateCount, #duration(1,0,0,0)),

    //Convert the list into a table and convert dates to date type
    DateListToTable = Table.FromList(GetDateList, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),
    DateListToTableType = Table.TransformColumnTypes(DateListToTable,{{"Date", type date}}),
    

    //Create date attributes from the date column
    //Datekey
    DateKey = Table.AddColumn(DateListToTableType, "DateKey", each Date.ToText([Date],[Format="YYYYMMDD"])),
    DateKeyType = Table.TransformColumnTypes(DateKey,{{"DateKey", Int64.Type}}),

    //Day of week
    DayOfWeek = Table.AddColumn(DateKeyType, "Day of Week", each Date.DayOfWeek([Date]), Int8.Type),

    //Overall Day Number
    OverallDayNumber = Table.AddColumn(DayOfWeek, "Overall Day Number", each 
    Duration.Days(#date(Date.Year([Date]), Date.Month([Date]), Date.Day([Date]))- BienniumStartDate), Int32.Type),
    
    //Day name
    DayName = Table.AddColumn(OverallDayNumber, "Day Name", each Date.DayOfWeekName([Date])),

    //Day abbreviation
    DayAbbreviation = Table.AddColumn(DayName, "Day Abbreviation", each Text.Range(Date.DayOfWeekName([Date]),0,3)),

    //Number of week in the year
    WeekNumInCalendarYear = Table.AddColumn(DayAbbreviation, "Week Number in Calendar Year", each Date.WeekOfYear([Date]), Int8.Type),

    //Week begin date
    WeekStartDate = Table.AddColumn(WeekNumInCalendarYear, "Week Start Date", each Date.StartOfWeek([Date])),

    //Calendar year month
    CalendarYearMonth = Table.AddColumn(WeekStartDate, "Calendar Year Month", each Date.Month([Date])),
    
    //Calendar year month name
    CalendarYearMonthName = Table.AddColumn(CalendarYearMonth, "Calendar Year Month Name", each Date.MonthName([Date])),

    //Month Abbreviation
    MonthAbbreviation = Table.AddColumn(CalendarYearMonthName, "Month Abbreviation", each Text.Range(Date.MonthName([Date]),0,3)),

    //Add Calendar Year Column
    CalendarYearNumber = Table.AddColumn(MonthAbbreviation, "Calendar Year", each Date.Year([Date]), Int16.Type),

    //Add Calendar Quarter Column
    CalendarQuarterNumber = Table.AddColumn(CalendarYearNumber , "Calendar Quarter", each "Q" & Number.ToText(Date.QuarterOfYear([Date]))),

    //Add month end flag
    CalendarMonthEndFlag = Table.AddColumn(CalendarQuarterNumber, "Calendar Month End Flag", each if [Date] = Date.EndOfMonth([Date]) then "Y" else "N"),

    //Add Quarter end flag
    QuarterEndFlag = Table.AddColumn(CalendarMonthEndFlag, "Calendar Quarter End Flag", each if [Date] = Date.EndOfQuarter([Date]) then "Y" else "N"),

    //Add Calender year and quarter
    CalendarYearAndQuarter = Table.AddColumn(QuarterEndFlag, "Calendar Year and Quarter", each Date.ToText([Date],[Format="yyyy"]) & "Q" & Number.ToText(Date.QuarterOfYear([Date]))),

    //Add Calendar year month
    CalendarYearAndMonth = Table.AddColumn(CalendarYearAndQuarter, "Calendar Year and Month", each Date.ToText([Date],[Format="yyyy-MM"])),

    //Add same day 1 year ago
    SameDay1YearAgo = Table.AddColumn(CalendarYearAndMonth,"Same Day 1 Year Ago", each Date.AddDays([Date],-365), type date),

    //Add same daye 90 days ago
    SameDay90DaysAgo = Table.AddColumn(SameDay1YearAgo,"Same Day 90 Days Ago", each Date.AddDays([Date],-90), type date),

    //Add same day 60 days ago
    SameDay60DaysAgo = Table.AddColumn(SameDay90DaysAgo,"Same Day 60 Days Ago", each Date.AddDays([Date],-60), type date),

    //Add Same day 30 days ago
    SameDay30DaysAgo = Table.AddColumn(SameDay60DaysAgo,"Same Day 30 days Ago", each Date.AddDays([Date],-30), type date),

    //Add Biennium
    Biennium = Table.AddColumn(SameDay30DaysAgo,"Biennium", each 
    if Number.IsOdd(Date.Year([Date])) then 
        if Date.DayOfYear([Date]) < Date.DayOfYear(#date(Date.Year([Date]),7,1)) then  
            "BI " & Number.ToText(Date.Year([Date]) - 2) & "-" & Number.ToText(Date.Year([Date])) else 
            "BI " & Number.ToText(Date.Year([Date])) & "-" & Number.ToText(Date.Year([Date]) + 2) 
    else  
        "BI " & Number.ToText(Date.Year([Date]) - 1) & "-" & Number.ToText(Date.Year([Date]) + 1)),

    //Add biennium year (1 or 2)
    BienniumYear = Table.AddColumn(Biennium, "Biennium Year", each 
    if Number.IsOdd(Date.Year([Date])) then 
        if Date.DayOfYear([Date]) < Date.DayOfYear(#date(Date.Year([Date]),7,1)) then 2 else 1
    else 
        if Date.DayOfYear([Date]) < Date.DayOfYear(#date(Date.Year([Date]),7,1)) then 1 else 2
    , Int8.Type),

    //Add Fiscal Year
    FiscalYear = Table.AddColumn(BienniumYear, "Fiscal Year", each 
    if Number.IsOdd(Date.Year([Date])) then 
        if Date.DayOfYear([Date]) < Date.DayOfYear(#date(Date.Year([Date]),7,1)) then Date.Year([Date]) else Date.Year([Date]) + 1
    else 
        if Date.DayOfYear([Date]) < Date.DayOfYear(#date(Date.Year([Date]),7,1)) then Date.Year([Date]) else Date.Year([Date]) + 1
    , Int16.Type),

    //Add fiscal quarter
    FiscalQuarter = Table.AddColumn(FiscalYear, "Fiscal Quarter", each 
    if List.Contains({1,2}, Date.QuarterOfYear([Date])) then "FQ" & Number.ToText(Date.QuarterOfYear([Date]) + 2) else "FQ" & Number.ToText(Date.QuarterOfYear([Date]) - 2) 
    ),

    //Add fiscal month
    FiscalMonth = Table.AddColumn(FiscalQuarter, "Fiscal Month", each 
    if Number.IsOdd(Date.Year([Date])) then
        if Date.Month([Date]) < 7 then Date.Month([Date]) + 18 else Date.Month([Date]) - 6
    else
        if Date.Month([Date]) < 7 then Date.Month([Date]) + 6 else Date.Month([Date]) + 6
    , Int8.Type),

    //Add day number in fiscal year
    DayNumberInFiscalYear = Table.AddColumn(FiscalMonth, "Day Number in Fiscal Year", each 
    if Date.Month([Date]) < 7 then Date.DayOfYear(Date.AddMonths([Date],6)) else Date.DayOfYear(Date.AddMonths([Date],-6))
    , Int16.Type),

    //Add week number if fiscal year
    WeekNumberInFiscalYear = Table.AddColumn(DayNumberInFiscalYear, "WeekNumberInFiscalYear", each 
    if Date.Month([Date]) < 7 then Date.WeekOfYear(Date.AddMonths([Date],6)) else Date.WeekOfYear(Date.AddMonths([Date],-6))
    , Int8.Type)

in
    WeekNumberInFiscalYear
```
