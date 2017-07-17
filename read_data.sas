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
  data  lib.data2014_2017;
     set l_data2014 l_data2015 l_data2016 l_data2017;
  proc sort ;
     by VAERS_ID YEAR;
  run; 
  data  lib.vaccine2014_2017;
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
  /*data data2014_2017_AGE;
     set data2014_2017;
     if not missing(DIED) or not missing(L_THREAT) or not missing(ER_VISIT)	or not missing(HOSPITAL) or not missing (HOSPDAYS) then
  	   EMERGENT = "Y";
     else 
       EMERGENT = "N";
	 EMERGENT_N = input(EMERGENT, yes_no.);*/
     /*Age of patient in years calculated by (vax_date - birthdate)*/
    /* CALCULATED_AGE=ifn(not missing(CAGE_YR),sum(CAGE_YR,CAGE_MO,0),CAGE_MO);
 	  
  run;*/
%mend read_csv;



/*read raw data*/
%read_csv;
