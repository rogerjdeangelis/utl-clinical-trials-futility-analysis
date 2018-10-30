Clinical trials futility analysis                                                                          
                                                                                                           
github                                                                                                     
https://github.com/rogerjdeangelis/utl-clinical-trials-futility-analysis                                   
                                                                                                           
SAS Forum                                                                                                  
https://tinyurl.com/y9754fqp                                                                               
https://communities.sas.com/t5/SAS-Statistical-Procedures/intrim-futility-analysis/m-p/508648              
                                                                                                           
see package futility documentation                                                                         
https://cran.r-project.org/web/packages/futility/futility.pdf                                              
                                                                                                           
It has been a long time since I did clinical analysis and I am                                             
out of my comfort zone. I suggest you read the R doc carefully.                                            
                                                                                                           
There are other 'futility' analysis in R.                                                                  
                                                                                                           
                                                                                                           
INPUT                                                                                                      
=====                                                                                                      
                                                                                                           
see                                                                                                        
https://tinyurl.com/y7gec28x                                                                               
https://github.com/rogerjdeangelis/utl-clinical-trials-futility-analysis/blob/master/interim.sas7bdat      
                                                                                                           
                                                                                                           
 SD1.INTERIM total obs=750 (randomly generated data)                                                       
                                                                                                           
                      days?                      last_                                                     
  arm    schedule2    entry      exit     visit_dt    event    dropout    complete    followup             
                                                                                                           
   1         0          22        .         47.116      0         0           0           1                
   1         0          20        .         88.215      0         0           0           1                
   1         0          25        .         54.001      0         0           0           1                
   1         0          31        .         78.615      0         0           0           1                
   1         0          23        .         87.260      0         0           0           1                
  ...                                                                                                      
                                                                                                           
OUTPUT                                                                                                     
======                                                                                                     
                                                                                                           
Output datasets are on my github                                                                           
                                                                                                           
https://github.com/rogerjdeangelis/utl-clinical-trials-futility-analysis                                   
https://github.com/rogerjdeangelis/utl-clinical-trials-futility-analysis/blob/master/arms.sas7bdat         
https://github.com/rogerjdeangelis/utl-clinical-trials-futility-analysis/blob/master/postrate.sas7bdat     
https://github.com/rogerjdeangelis/utl-clinical-trials-futility-analysis/blob/master/meta.sas7bdat         
                                                                                                           
                                                                                                           
 SD1.POSTRATES total obs=5                                                                                 
 -------------------------                                                                                 
                                                                                                           
  event Post Rates by arm                                                                                  
                                                                                                           
  ARMS    COMPLETE                                                                                         
                                                                                                           
  ARM1    0.0033548                                                                                        
  ARM2    0.0025508                                                                                        
  ARM3    0.0015753                                                                                        
  ARM4    0.0041515                                                                                        
  ARM5    0.0024646                                                                                        
                                                                                                           
                                                                                                           
 SD1.META total obs=1                                                                                      
 --------------------                                                                                      
                                           BetaOverBetaPlusTk  TkOverTstar                                 
  NTRIALS      N    ENROLRATE    DROPRATE     BETAOVER         TKOVERTS    RANSEED    POST                 
                                                                                                           
     5       1500       10       0.028428      0.66716          0.24945       9         .                  
                                                                                                           
 SD1.ARMS total obs=7,500                                                                                  
 ------------------------                                                                                  
                                                                                                           
  ARMS     ENTRY      EXIT     EVENT    DROPOUT                                                            
                                                                                                           
  ARM1        22    102.000      0         0                                                               
  ARM1        20    100.000      0         0                                                               
  ARM1        25    105.000      0         0                                                               
  ....                                                                                                     
                                                                                                           
  ARM5   119.168    199.168      0         0                                                               
  ARM5   119.343    199.343      0         0                                                               
  ARM5   119.430    199.430      0         0                                                               
                                                                                                           
                                                                                                           
PROCESS                                                                                                    
=======                                                                                                    
                                                                                                           
%utl_submit_r64('                                                                                          
library(futility);                                                                                         
library(haven);                                                                                            
library(SASxport);                                                                                         
interimData<-read_sas("d:/sd1/have.sas7bdat");                                                             
interimData$arm <- factor(interimData$arm);                                                                
completeData <- completeTrial.pooledArms(interimData=interimData, nTrials=5, N=1500,                       
enrollRatePeriod=24, eventPriorWeight=0.5, eventPriorRate=0.001, fuTime=80,                                
visitSchedule=seq(0, 80, by=4),                                                                            
visitSchedule2=c(0,seq(from=8,to=80,by=12)), randomSeed=9);                                                
completeTrial.pooledArms(interimData=interimData, nTrials=5, N=1500,                                       
enrollRatePeriod=24, eventPriorWeight=0.5, eventPriorRate=0.001, fuTime=80,                                
visitSchedule=seq(0, 80, by=4),                                                                            
visitSchedule2=c(0,seq(from=8,to=80,by=12)), saveDir="./", randomSeed=9);                                  
str(completeData);                                                                                         
arm1<-as.data.frame(completeData$trialData[1]);                                                            
arm2<-as.data.frame(completeData$trialData[2]);                                                            
arm3<-as.data.frame(completeData$trialData[3]);                                                            
arm4<-as.data.frame(completeData$trialData[4]);                                                            
arm5<-as.data.frame(completeData$trialData[5]);                                                            
want<-c(completeData$nTrials);                                                                             
meta<-as.data.frame(t(c(                                                                                   
  completeData$nTrials,                                                                                    
  completeData$N,                                                                                          
  completeData$rates$enrollRate,                                                                           
  completeData$rates$dropRate,                                                                             
  completeData$BetaOverBetaPlusTk,                                                                         
  completeData$TkOverTstar,                                                                                
  completeData$randomSeed,                                                                                 
  completeData$w.post)));                                                                                  
str(meta);                                                                                                 
colnames(meta)<-c("ntrials","N","nrolRate","dropRate","BetaOver","TkOverTs","ranSeed","post");             
str(meta);                                                                                                 
postrate<-as.data.frame(completeData$rates$eventPostRate);                                                 
write.xport(arm1,arm2,arm3,arm4,arm5,postrate,meta,file="d:/xpt/interim.xpt");                             
');                                                                                                        
                                                                                                           
                                                                                                           
LOG                                                                                                        
===                                                                                                        
                                                                                                           
 List of 8                                                                                                 
  $ trialData         :List of 5                                                                           
   ..$ :'data.frame':	1500 obs. of  4 variables:                                                           
   .. ..$ entry  : num [1:1500] 22 20 25 31 23 18 24 21 24 39 ...                                          
   .. ..$ exit   : num [1:1500] 102 100 105 111 103 98 104 101 104 119 ...                                 
   .. ..$ event  : int [1:1500] 0 0 0 0 0 0 0 0 0 0 ...                                                    
   .. ..$ dropout: int [1:1500] 0 0 0 0 0 0 0 0 0 0 ...                                                    
   ..$ :'data.frame':	1500 obs. of  4 variables:                                                           
   .. ..$ entry  : num [1:1500] 22 20 25 31 23 18 24 21 24 39 ...                                          
   .. ..$ exit   : num [1:1500] 102 100 105 111 103 98 104 101 104 119 ...                                 
   .. ..$ event  : int [1:1500] 0 0 0 0 0 0 0 0 0 0 ...                                                    
   .. ..$ dropout: int [1:1500] 0 0 0 0 0 0 0 0 0 0 ...                                                    
   ..$ :'data.frame':	1500 obs. of  4 variables:                                                           
   .. ..$ entry  : num [1:1500] 22 20 25 31 23 18 24 21 24 39 ...                                          
   .. ..$ exit   : num [1:1500] 102 100 105 111 103 98 104 101 104 119 ...                                 
   .. ..$ event  : int [1:1500] 0 0 0 0 0 0 0 0 0 0 ...                                                    
   .. ..$ dropout: int [1:1500] 0 0 0 0 0 0 0 0 0 0 ...                                                    
   ..$ :'data.frame':	1500 obs. of  4 variables:                                                           
   .. ..$ entry  : num [1:1500] 22 20 25 31 23 18 24 21 24 39 ...                                          
   .. ..$ exit   : num [1:1500] 102 100 105 111 103 98 104 101 104 119 ...                                 
   .. ..$ event  : int [1:1500] 0 0 0 0 0 0 0 0 0 0 ...                                                    
   .. ..$ dropout: int [1:1500] 0 0 0 0 0 0 0 0 0 0 ...                                                    
   ..$ :'data.frame':	1500 obs. of  4 variables:                                                           
   .. ..$ entry  : num [1:1500] 22 20 25 31 23 18 24 21 24 39 ...                                          
   .. ..$ exit   : num [1:1500] 102 100 105 111 103 98 104 101 104 119 ...                                 
   .. ..$ event  : int [1:1500] 0 0 0 0 0 0 0 0 0 0 ...                                                    
   .. ..$ dropout: int [1:1500] 0 0 0 0 0 0 0 0 0 0 ...                                                    
  $ nTrials           : num 5                                                                              
  $ N                 : num 1500                                                                           
  $ rates             :List of 3                                                                           
   ..$ enrollRate   : num 10                                                                               
   ..$ dropRate     : num 0.0284                                                                           
   ..$ eventPostRate: num [1:5] 0.00335 0.00255 0.00158 0.00415 0.00246                                    
  $ BetaOverBetaPlusTk: num 0.667                                                                          
  $ TkOverTstar       : num 0.249                                                                          
  $ randomSeed        : num 9                                                                              
  $ w.post            : logi NA                                                                            
 'data.frame':	1 obs. of  8 variables:                                                                     
  $ V1: num 5                                                                                              
  $ V2: num 1500                                                                                           
  $ V3: num 10                                                                                             
  $ V4: num 0.0284                                                                                         
  $ V5: num 0.667                                                                                          
  $ V6: num 0.249                                                                                          
  $ V7: num 9                                                                                              
  $ V8: num NA                                                                                             
 'data.frame':	1 obs. of  8 variables:                                                                     
  $ ntrials : num 5                                                                                        
  $ N       : num 1500                                                                                     
  $ nrolRate: num 10                                                                                       
  $ dropRate: num 0.0284                                                                                   
  $ BetaOver: num 0.667                                                                                    
  $ TkOverTs: num 0.249                                                                                    
  $ ranSeed : num 9                                                                                        
  $ post    : num NA                                                                                       
 >                                                                                                         
                                                                                                           
