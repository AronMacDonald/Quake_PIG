A = load '/user/admin/quakes/input/month.txt' as (log:chararray);


B1 = foreach A generate log, INDEXOF(log, '"', 0) as index;

B2 = foreach B1 generate SUBSTRING(log, 0, index) AS partA,  
                       SUBSTRING(log, index+1, 255) as partB;
                       
-- Split line before before and after Text "" in input file
B3 = FOREACH B2 {
  a_split = STRSPLIT(partA,',');
  b_split = STRSPLIT(partB,'"');
  type = SUBSTRING(b_split.$1, 1, 11);  
--  GENERATE flatten(a_split), b_split.$0 , type;

-- Split line in accordance with columns
--time	latitude	longitude	depth	mag	magType	nst	gap	dmin	rms	net	id	updated	place	type
  GENERATE CONCAT(CONCAT(SUBSTRING(a_split.$0,0,10),' '), SUBSTRING(a_split.$0,11,23)) as time,
           a_split.$1  as latitude,
           a_split.$2  as longitude,
           a_split.$3  as depth,
           a_split.$4  as mag,
           a_split.$5  as magType,
           a_split.$6  as nst,
           a_split.$7  as gap,
           a_split.$8  as dmin,
           a_split.$9  as rms,
           a_split.$10 as net,
           a_split.$11 as id,
           CONCAT(CONCAT(SUBSTRING(a_split.$12,0,10),' '), SUBSTRING(a_split.$12,11,23)) as updated,
           b_split.$0  as place, 
           type        as type;
} 



B4 = FILTER B3 BY (time != 'time');
describe B4;
B5 = FILTER B4 BY (mag >= 3.0); 


STORE B5 INTO '/user/admin/quakes/newLoad' USING PigStorage('\t');
