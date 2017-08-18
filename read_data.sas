%global path_to_repository;
%let path_to_repository =  C:\Users\dhasan\Documents\GitHub\Growing-up-with-SAS-it-gets-real ;

/*Specify where you would like to store the datasets*/
libname lib "&path_to_repository.\Datasets";

%macro read_csv;
  %do i =4 %to 7;
     proc import datafile="&path_to_repository.\CSV_raw_data\201&i.VAERSData\201&i.VAERSDATA.csv" out= data201&i. dbms=csv  ; 
        getnames=yes; 
	 run;
     data l_data201&i;
  	    set  data201&i %if &i = 5 %then (rename = (HOSPDAYs=HOSPDAY)) ;;  
  	    %if &i = 5 %then 
          HOSPDAYS = input(strip(HOSPDAY), ? 8.) ; ;
	    YEAR = 201&i;
  	    keep VAERS_ID YEAR AGE_YRS CAGE_YR CAGE_MO DIED L_THREAT ER_VISIT HOSPITAL HOSPDAYS  ;
     run;
     proc import datafile="&path_to_repository.\CSV_raw_data\201&i.VAERSData\201&i.VAERSVAX.csv" out= vaccine201&i. dbms=csv  ; 
        getnames=yes; 
     run; 
     %let Conc_Desease = %str(strip(Disease)||strip(ifc(not missing(Disease),',','')));
     data l_vaccine201&i /*(keep=VAERS_ID YEAR Disease VACCINE)*/;
     	set  vaccine201&i ;
  	    length  VACCINE $20 Disease $200 ;
  	    YEAR = 201&i; 
        VACCINE = strip(VAX_TYPE);
  	    if find(upcase(VACCINE),"MMRV") or find(upcase(VACCINE),"VARCEL") or find(upcase(VACCINE),"VARZOS") then
          Disease = &Conc_Desease||"Chickenpox";
  	    if find(upcase(VACCINE),"6VAX-F") or find(upcase(VACCINE),"DPIPV") or 
     	   upcase(substr(VACCINE,1,2))="TD" or find(upcase(VACCINE),"DPP") or find(upcase(VACCINE),"DT")  then
          Disease = &Conc_Desease||"Diphtheria";
  	    if index(upcase(VACCINE),"DTPPHI") or index(upcase(VACCINE),"HBPV") or
     	   index(upcase(VACCINE),"HBHEPB") or index(upcase(VACCINE),"HIB") or
     	   find(upcase(VACCINE),"6VAX-F") or upcase(VACCINE)="DTAPH" or	find(upcase(VACCINE),"DTPIHI") then
   	      Disease = &Conc_Desease||"Haemophilus b";
        if index(upcase(VACCINE),"HEPA") or index(upcase(VACCINE),"HEPAB") then
	      Disease = &Conc_Desease||"Hepatitis A"; 
     	if upcase(VACCINE)="HEP" or find(upcase(VACCINE),"6VAX-F") or index(upcase(VACCINE),"HEPB") or index(upcase(VACCINE),"DTPHEP") or
   	       index(upcase(VACCINE),"DTAPHE") or index(upcase(VACCINE),"HEPAB") then
          Disease = &Conc_Desease||"Hepatitis B";
 	    if index(upcase(VACCINE),"FLU") or index(upcase(VACCINE),"H5N1") then
	      Disease = &Conc_Desease||"Influenza";
	    if find(upcase(VACCINE),"MEA") or find(upcase(VACCINE),"MER") or index(upcase(VACCINE),"MM") then
          Disease = &Conc_Desease||"Measles";
 	    if index(upcase(VACCINE),"MU") or index(upcase(VACCINE),"MM") then
          Disease = &Conc_Desease||"Mumps";
  	    if index(upcase(VACCINE),"DTAP") or find(upcase(VACCINE),"6VAX-F") or find(upcase(VACCINE),"DPIPV") or find(upcase(VACCINE),"DPP") or
     	   index(upcase(VACCINE),"DTP") or find(upcase(VACCINE),"PER") or find(upcase(VACCINE),"TDAP") then
	      Disease = &Conc_Desease||"Pertussis";
  	    if find(upcase(VACCINE),"6VAX-F") or index(upcase(VACCINE),"DTAPHE") or	find(upcase(VACCINE),"DTAPIP") or find(upcase(VACCINE),"DPP") or
     	   find(upcase(VACCINE),"DTAPHEPBIP") or find(upcase(VACCINE),"DTPPHI")	or find(upcase(VACCINE),"DTPIHI") or index(upcase(VACCINE),"IPV") or
     	   find(upcase(VACCINE),"OPV") then
          Disease = &Conc_Desease||"Polio";
  	    if index(upcase(VACCINE),"PNC") or find(upcase(VACCINE),"PPV") then
	      Disease = &Conc_Desease||"Pneumococcal";
     	if upcase(substr(VACCINE,1,2)) = "RV" then
          Disease = &Conc_Desease||"Rotavirus";
	    if upcase(substr(VACCINE,1,3))="MER" or find(upcase(VACCINE),"MMR") or upcase(substr(VACCINE,1,3))="MUR" or
           upcase(substr(VACCINE,1,3))="RUB" then
	      Disease = &Conc_Desease||"Rubella";
	    if find(upcase(VACCINE),"6VAX-F") or find(upcase(VACCINE),"DTPPHI") or find(upcase(VACCINE),"DTAPIP") or index(upcase(VACCINE),"DTAPHE") or
     	  (upcase(substr(VACCINE,1,2)) = "DT" and upcase(substr(VACCINE,1,4)) ne "DTOX") or find(upcase(VACCINE),"MNQHIB") or upcase(substr(VACCINE,1,2)) in( "TD",'TT')  then
          Disease = &Conc_Desease||"Tetanus";
  	    if not missing(Disease); 
     run;
  %end;
  data   data2014_2017;
     set l_data2014 l_data2015 l_data2016 l_data2017;
  proc sort ;
     by VAERS_ID YEAR;
  run; 
  
  data  vaccine2014_2017;
     set l_vaccine2014 l_vaccine2015 l_vaccine2016 l_vaccine2017;
  proc sort ;
     by VAERS_ID YEAR;
  run;
  proc format;
	invalue yes_no  
       "Y" = 1   
       "N" = 2;
    invalue obs_taken 
       'One'      = 2 
       'Multiple' = 1;
  run;
  data data2014_2017_AGE;
     set data2014_2017;
     if not missing(DIED) or not missing(L_THREAT) or not missing(ER_VISIT)	or not missing(HOSPITAL) or not missing (HOSPDAYS) then
  	   EMERGENT = "Y";
     else 
       EMERGENT = "N";
	 EMERGENT_N = input(EMERGENT, yes_no.); 
     /*Age of patient in years calculated by (vax_date - birthdate)*/
      CALCULATED_AGE=ifn(not missing(CAGE_YR),sum(CAGE_YR,CAGE_MO,0),CAGE_MO);
 	  if 1 < CALCULATED_AGE <= 1.75 or 1<AGE_YRS<=1.75 ;
  run; 
%mend read_csv;



/*read raw data*/
%read_csv;

%macro keep_VAERS;
   /* We need to keep only VAERS in all datasets where VACCINE dataset intersects with DATA dataset*/
   proc sql;
     create table keep_VAERS as 
       select distinct a.VAERS_ID, a.YEAR
      from  data2014_2017_AGE natural inner join vaccine2014_2017 as a;
   quit;

   data lib.data2014_2017;
      merge data2014_2017_AGE(in = in1) keep_VAERS(in = in2);
      by VAERS_ID YEAR;
      if in1 & in2;
   run;

   data lib.vaccine2014_2017;
      merge vaccine2014_2017(in = in1) keep_VAERS(in = in2) lib.data2014_2017(keep = VAERS_ID  YEAR EMERGENT EMERGENT_N);
      by VAERS_ID YEAR;
      if in1 & in2;
   run;
%mend  keep_VAERS;

/* Keep only needed VAEs*/
%keep_VAERS;

proc sql FEEDBACK noprint;

   create table VAERS_IDS as
      select data.* ,  case when .<vac.N_TAKEN_V <=1 then 'One' else 'Multiple' end as TAKEN, 
             input(calculated TAKEN, ? obs_taken.) as N_TAKEN
    from lib.vaccine2014_2017  as data
         natural left join
         ( select VAERS_ID, YEAR, count( distinct DISEASE) as N_TAKEN_V 
             from lib.vaccine2014_2017 group by VAERS_ID, YEAR 
         ) vac ;


   create table SE_TAB as        
    select YEAR, EMERGENT , DISEASE,  
	       count(distinct case when TAKEN = 'One'  then  VAERS_ID else . end) as ONE label = "ONE ",
           count(distinct case when TAKEN = 'Multiple' then  VAERS_ID else . end) as MUL label = "MULTIPLE"	 
	from VAERS_IDS    
    group by 1,2 ,3 
    order by 1,2;
 
quit;

proc sql noprint; 
   select distinct DISEASE into : All_VV separated by '" "' from SE_TAB where ONE>= 5 and MUL>= 5;
quit;
data MEET_VAC;
   set VAERS_IDS (where = (DISEASE in ("&All_VV")));
run;

data SAMPLE;
   set MEET_VAC;
COMMENT - Delete duplicated vaccines for one VAE;
proc sort dupout = DUP_VAC nodupkey;
   by DISEASE VAERS_ID;
proc freq noprint;
   by DISEASE;
   table N_TAKEN*EMERGENT_N /chisq relrisk;
   output out = TESTS chisq RELRISK;
run;
 
data chisq_odds;
   set TESTS (keep = DISEASE _PCHI_ P_PCHI _CRAMV_ _RROR_ L_RROR U_RROR);
   length col1- col5 $100;
   col1 = strip(DISEASE); col2 = put(round(_PCHI_,.01), 8.2 -c);
   col3 = put(round(_CRAMV_,.01), 8.2 -c);
   col4 = put( _RROR_ , ODDSR8.3 -r)||' ('||put( L_RROR , ODDSR8.3 -c)||','||put( U_RROR , ODDSR8.3 -c)||')' ;
   col5 = put(round(P_PCHI,.01), PVALUE6.4 -l);
   label col1 = "Vaccines" col2 = 'Chi-Square' col3 = "Cramer's V%sysfunc(byte(178))" col4 = "Odds Ratio%sysfunc(byte(179)) ( 95% CI )" col5 = "p-value%sysfunc(byte(185)) ";
run;
title1 "Association between emergent VAERS and number of taken vaccinations.";
title2 "Populations infants in age 12-23 month.";
footnote1 "%sysfunc(byte(185))Corresponding p-value for Chi-Square statistic.";
footnote2 "%sysfunc(byte(178))the strenght measure of the assosiations that the Chi-Square test detected.";
footnote3 "%sysfunc(byte(179))the odds of emergent vaccination when it was received multiple vaccines to one vaccine.";
proc print data = chisq_odds  L;
   var col1-col5;
run;



/* Check if combo better then multiple vaccines */

 
proc sort data =  VAERS_IDS dupout = issue nodupkey;
   by VAERS_ID  Disease TAKEN;
run;
/*Make one record for multiple vaccination*/
data _Mul_Disease;
  set  VAERS_IDS;
  by VAERS_ID   Disease TAKEN;
  length Dise $200;retain Dise;
  if first.VAERS_ID then Dise = strip(Disease);
  if TAKEN = 'Multiple' and not first.VAERS_ID  then 
    Dise = strip(Dise)||","||strip(Disease);
  else Dise = Disease; 
  if last.VAERS_ID;  
run;
/* create macro variables with combo vaccination(ones taken) */
proc sql ; 
   select distinct Dise into : combo separated by '@' from _Mul_Disease where TAKEN = 'One' and countw(Dise,',') >=2;
   select count(distinct Dise) into : n_combo separated by '@' from _Mul_Disease where TAKEN = 'One' and countw(Dise,',') >=2;
quit;
/* keeps records with matched deseases */
%macro keeps;
  data keeps ;
     set _Mul_Disease;
     length combo Dis_vac $1200;
	 combo = "&combo";
     %do i = 1 %to  &n_combo;
	    
	  if TAKEN = 'One' and Dise = scan(combo,&i,'@') then do; y = "Y";Dise1 =Dise;end; 

        if TAKEN = 'Multiple' then do;
           Dis_vac = scan(combo,&i,'@'); 
		   nn =0;
		   n = countw(Dis_vac,',') ;
           do i = 1 to n;
		      if find(Dise,strip(scan(Dis_vac, i ,',' )),'i') then nn = nn+1;			  
		   end;
		   do k = 1 to countw(Dise,',') ;
		      
		        if  not find(Dis_vac,strip(scan(Dise, k , ',')),'i' ) then nn= nn+.0001; 		  
		      		      
		   end;

           if n  = nn   then do;  y = "Y";  Dise1 = Dis_vac; end;
		end;
 
	 %end;

     if y = "Y";
  run;
%mend keeps;

%keeps;

 /*check the result*/
proc freq data =  keeps ; 
   table Dise1*EMERGENT  /chisq; 
run;
 
