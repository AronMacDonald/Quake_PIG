CURRENT = LOAD '/user/admin/quakes/newLoad' USING PigStorage('\t') 
             AS (time,latitude,longitude,depth,mag,magType,nst,gap,dmin,rms,net,id,updated,place,type);

PRIOR = LOAD '/user/admin/quakes/priorLoad' USING PigStorage('\t') 
             AS (time,latitude,longitude,depth,mag,magType,nst,gap,dmin,rms,net,id,updated,place,type);
describe PRIOR;

--PROJECTION of prior seen events
PRIOR_EVENT = FOREACH PRIOR GENERATE id;         
describe PRIOR_EVENT;

CURRENT_RIGHT = JOIN PRIOR_EVENT by id RIGHT OUTER, CURRENT BY id;
describe PRIOR_EVENT;

DELTA = FILTER CURRENT_RIGHT BY PRIOR_EVENT::id is null;
describe DELTA;

OUTPUTFILE = FOREACH DELTA
            GENERATE CURRENT::time,CURRENT::latitude,CURRENT::longitude,
                     CURRENT::depth,CURRENT::mag,CURRENT::magType,
                     CURRENT::nst,CURRENT::gap,CURRENT::dmin,
                     CURRENT::rms,CURRENT::net,CURRENT::id,
                     CURRENT::updated,CURRENT::place,CURRENT::type;

describe OUTPUTFILE;
--dump OUTPUTFILE;

STORE OUTPUTFILE INTO '/user/admin/quakes/newDelta' USING PigStorage('\t');
