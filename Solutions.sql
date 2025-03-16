--  Solutions of the Given Problems are as follows:

-- 1. Count the number of Movies vs TV Shows
Select type, Count(*) Count
  from netflix 
  group by type ;


-- 2. Find the most common rating for movies and TV shows 
 with RatingCount As (
   select type , rating , Count(rating) CountOfRate
       from netflix 
       group by type , rating) ,
Rank_rating As (
   select type , rating , CountOfRate ,
   Rank() over (partition by type order by CountOfRate DESC) as ranking
   from RatingCount)
select type , rating as CommonRates , CountOfRate from Rank_rating Where ranking=1;


-- 3. List All Movies Released in a Specific Year (e.g., 2020)
with Movies As ( 
  select * from netflix where type="Movie" )  
select title ,release_year from Movies where release_year =2020; 



-- 4. Find the Top 5 Countries with the Most Content on Netflix 

select Country , Count(*) as total
From (
select 
   trim(value) as country
   from netflix ,
   json_table(concat('["',REPLACE(COALESCE(country,''),',','","'),'"]' ),"$[*]" columns(value VARCHAR(255) PATH"$")) as t
   ) as t1 
Where country <> ''
GROUP by Country 
order by  total desc
Limit 5 ;   



-- 5. Identify the Longest Movie 
select title 
 from netflix 
 Where type = "Movie" 
 order by (Cast(substring_Index(duration ," ",1) as unsigned) ) Desc
Limit 1;



-- 6.  Find Content Added in the Last 5 Years
 select * 
  From netflix 
  where date_added >= current_date - interval 5 year ;
  


 -- 7.  Find All Movies/TV Shows by Director 'Rajiv Menon'
SELECT *
FROM netflix
WHERE FIND_IN_SET('Rajiv Menon', director) > 0; 



-- 8. List All TV Shows with More Than 5 Seasons
select * 
  from netflix 
  Where type ='TV Show' and  cast(substring_Index(duration ," ",1) as Unsigned)>5 ;
  



-- 9. Count the Number of Content Items in Each Genre
select genre , Count(*) as Count 
  from (
   select 
     Trim(value) as genre
     from netflix,
     json_table(concat('["', Replace(Coalesce(listed_in,''),',','","'),'"]') ,"$[*]" columns(value varchar(255) Path "$")) as t
     ) as t1
 Group by genre ;    
 



-- 10. Find each year and the average numbers of content release in India on netflix.  
select 
   Country ,
   release_year ,
   Count(*) as total ,
   Round(
      count(*) / (select Count(*) from netflix where Country ='India' ) ,2) as Average
  from netflix 
  Where country='India'
  Group by Country , release_year 
  order by release_year ;
  


 -- 11.  List All Movies that are Documentaries
 select title , listed_in
  from netflix 
  Where listed_in Like '%documentaries%';
  


-- 12. Find All Content Without a Director
  select *
   from netflix 
   Where director = '';


-- 13.  Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years 
   select * 
     from netflix 
     Where casts Like "%Salman Khan%" and release_year >= year(current_date) - 10 ;



 -- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in japan 
 select lower(actor) , Count(*) as Movie_Count 
from (
   select 
    Trim(value) actor
    from netflix ,
    json_table(concat('["',Replace(Coalesce(casts,''),',','","'),'"]'),'$[*]' columns (value varchar(255) Path '$') ) as t 
    Where Country = 'japan'    
    ) as t1   
Where actor <> ''    
group by  lower(actor)
order by Movie_Count desc 
Limit 10 ;    


-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords 
select  category  ,count(*) count
from (
  select 
   case  
    When description Like "%Kill%"  or description Like  "%violence%" Then  'BAD'
    Else 'Good' 
   End  as category
   From netflix ) 
as category_content 
group by category ;
