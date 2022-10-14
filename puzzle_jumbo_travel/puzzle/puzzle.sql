#select  score 
#from scores  s1 where ((select count(*) from  scores s2 where s2.score<s1.score)=9);

select * from scores order by score asc;

#update scores set email='despode2@gmail.com';

update scores set score = score_hours*3600 + score_minutes*60 + score_seconds +score_tenths*0.1; 





