DECLARE @numerod_old varchar(15)
DECLARE @NUMEROD_NEW VARCHAR(15)
DECLARE @NUMEROC VARCHAR(15)
DECLARE @CODPROV VARCHAR(15)

SET  @numerod_new='000250'
SET  @numerod_old='000231'
SET  @numeroc='00000250'
SET  @CODPROV='J401718086'

update sacomp    set numerod=@numerod_new, NroCtrol=@NUMEROC from sacomp    where numerod=@numerod_old  
update saitemcom set numerod=@numerod_new from saitemcom where numerod=@numerod_old  
update saacxp    set numerod=@numerod_new, NROCTROL=@NUMEROC from saacxp    where numerod=@numerod_old
update saacxp    set nROCTROL=@NUMEROC, NumeroD=@NUMEROD_NEW    from saacxp    where numeroN=@numerod_old 
-- update saacxp    set numerod=@numerod_new from saacxp    where numeroN=@numerod_old
  
update sataxcom  set numerod=@numerod_new from sataxcom  where numerod=@numerod_old  
update sataxitc  set numerod=@numerod_new from sataxitc  where numerod=@numerod_old  
update saseprcom set numerod=@numerod_new from saseprcom where numerod=@numerod_old  
update sapagcxp  set numerod=@numerod_new from sapagcxp  where numerod=@numerod_old  
--update saTAXCXP  set numerod=@numerod_new from saTAXCXP  where numerod=@numerod_old
-----------------------------------------------------------------------------------------------
select * from sacomp    where numerod=@numerod_NEW

select * from saitemcom where numerod=@numerod_NEW

select * from saacxp    where numerod=@numerod_NEW

select * from sataxcom  where numerod=@numerod_NEW

select * from sataxitc  where numerod=@numerod_NEW

select * from saseprcom where numerod=@numerod_NEW

select * from sapagcxp  where numerod=@numerod_NEW