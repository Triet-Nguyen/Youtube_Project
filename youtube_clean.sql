-- xử lý làm sạch cột youtuber
-- loại bỏ các ký tự đặc biệt trong cột Youtuber
-- hàm loại bỏ các ký từ đặc biệt
CREATE FUNCTION [dbo].[removeAllSpecialChars](@inputString VARCHAR(256))
RETURNS VARCHAR(256)
AS
BEGIN
    DECLARE @specialStrings VARCHAR(256)
    DECLARE @increment INT = 1
    WHILE @increment <= DATALENGTH(@inputString)
    BEGIN
        IF ((ASCII(SUBSTRING(@inputString, @increment, 1)) 
                NOT BETWEEN 65 AND 90)                 
            AND (ASCII(SUBSTRING(@inputString, @increment, 1)) 
                NOT BETWEEN 97 AND 122)
            AND (ASCII(SUBSTRING(@inputString, @increment, 1)) 
                NOT BETWEEN 48 AND 57)
            AND (ASCII(SUBSTRING(@inputString, @increment, 1)) <> 32)
            AND (ASCII(SUBSTRING(@inputString, @increment, 1)) <> 9))
            BEGIN
                SET @specialStrings = CHAR(ASCII(SUBSTRING(@inputString, @increment, 1)))
                SET @inputString = REPLACE(@inputString, @specialStrings, '')
                SET @increment=@increment-1
            END;
        SET @increment = @increment + 1
    END
    RETURN @inputString
END
go

-- tạo một bảng mới
select rank, youtuber, Subscribers, Video_Views, Uploads, Category,  Country	, Abbreviation, Lowest_Monthly_Earnings, Highest_Monthly_Earnings, Created_Year
into totaldata
from dbo.youtube
order by rank


-- thực hiện loại bỏ ký tự đặc biệt
UPDATE dbo.totaldata
SET Youtuber = [dbo].[removeAllSpecialChars](Youtuber)

SELECT *
FROM dbo.totaldata

-- thây đổi tên các cột bị loại bỏ ký tự đặc biệt thành country + category
SELECT *
FROM dbo.totaldata
WHERE  Youtuber = ''

UPDATE dbo.totaldata
SET youtuber = 
    CASE 
        WHEN youtuber = '' THEN country + ' ' + category
        ELSE youtuber
    END
WHERE youtuber = '';

-- xử lý cột Created_Year
--loại bỏ các hàng có giá trị Created Year là null

DELETE FROM dbo.totaldata
WHERE created_Year IS NULL;


select created_year 
from totaldata
group by created_year

-- xử lý giá trị 1970 vì youtube thành lập năm 2005

select *
from totaldata
where created_year = '1970'

UPDATE dbo.totaldata
SET created_year = 2005
WHERE created_year = 1970;


-- xử lý cột video_views

select video_views
from totaldata
group by video_views
order by 1

select *
from totaldata
where video_views = '0'

DELETE FROM dbo.totaldata
WHERE video_views = 0;

--- Kiểm tra giá trị Null 3 cột Category, Country, Abbreviation
select *
from totaldata
where uploads is null


select *
from totaldata
where country = 'nan'

select *
from totaldata
where category = 'nan'

select *
from totaldata
where abbreviation = 'nan'

UPDATE dbo.totaldata
SET category = REPLACE(category, 'nan', 'other'),
	country = REPLACE(country, 'nan', 'other'),
	abbreviation = REPLACE(abbreviation, 'nan', 'other')

select * 
from totaldata
where country = 'other'

UPDATE dbo.totaldata
SET youtuber = LTRIM(RTRIM(youtuber))

UPDATE dbo.totaldata
SET youtuber = REPLACE(youtuber, 'nan', '')

select *
from totaldata
where country = 'other'



