/*Project Steps:

1. Import Excel data file into SAS, create SAS data set named as WL0

2. Data management: 
(1) Check Data using proc Means and proc Freq 

Create a new data set WL1 using a data step program including the following steps: step (2) and (3) 
(2) Clean data: change value ‘9999’ to missing using Array statement 
(3) Create weight difference variables
wd1 = weight0 - weight1;
wd2 = weight0 - weight2;
wd12 = weight1 - weight2;

(4) Using Proc Means and Proc Freq, check weight difference variables (only pick wd2 for this project, you may use others for practice) 
and walk_steps var for making groups from these var. 

Create a new data set WL1 using a data step program including the following steps: step (5) and (6) 
(5) create groups for walk_steps: create new var ws_group
the new group var should have 3 categories:
less than 5000
'5000-10000'
greater than 10000
(6) create groups for wd2: create new var wd2_group
the new group var should have 3 categories:
not losing weight
losing <= 5 lb
greater than 10000
losing > 5 lb

3.	Create permanent data set from data set WL2: projectd.weight_loss
4.	create cross-tab using Proc Freq for walk steps' groups (walk_steps_G) and weight loss groups (loss_weight_G) to exam the possible trend

*/


*1.Import Excel data file into SAS, create SAS data set named as WL0;
proc import datafile = "/folders/myfolders/Weight_loss" 
DBMS = xlsx out = wl0 replace ;
run;

/*2. Data management: 
(1) Check Data using proc Means and proc Freq 

Create a new data set WL1 using a data step program including the following steps: step (2) and (3) 
(2) Clean data: change value ‘9999’ to missing using Array statement 
(3) Create weight difference variables
wd1 = weight0 - weight1;
wd2 = weight0 - weight2;
wd12 = weight1 - weight2;*/

/*check data --- there are other ways checking data, here I am using the Knowledge introduced in this course;
**for continuous numeric vars;*/
proc means; 
var weight0	weight1 weight2 walk_steps;
run;
/**for categorical or character values vars;*/
proc freq data = wl0 ;
table gender;
run;

/*creating WL1 including step (2) and (3);*/

data wl1;
set wl0;

array v(2)	weight1 weight2;
   DO i = 1 TO 2;                       
      IF v(i) = 9999  THEN v(i) =.;   
   END; 

wd1 = weight0 - weight1;
wd2 = weight0 - weight2; /*will be used for this project*/
wd12 = weight1 - weight2;

drop i;
run;

/*(4) Using Proc Means and Proc Freq, check weight difference variables (only pick wd2 for this project, you may use others for practice) 
and walk_steps var for making groups from these var. */

proc means data = wl1 ;
var wd2 walk_steps;
run;
proc freq data = wl1 ;
table wd2 walk_steps;
run;

/*Create a new data set WL1 using a data step program including the following steps: step (5) and (6) 
(5) create groups for walk_steps: create new var 'walk_steps_G'
the new group var should have 3 categories:
less than 5000
'5000-10000'
greater than 10000
(6) create groups for wd2: create new var 'loss_weight_G'
the new group var should have 3 categories:
not losing weight
losing <= 5 lb
losing > 5 lb*/

data wl2;
set wl1;
length walk_steps_G loss_weight_G $20;

if walk_steps < 5000 then walk_steps_G = 'less than 5000';
else if 5000 <= walk_steps < = 10000 then walk_steps_G = '5000-10000';
else walk_steps_G = '> 10000';

if wd2 ne . and wd2 <= 0 then loss_weight_G = 'not losing weight';
else if 0 < wd2 < =5 then loss_weight_G = 'losing <= 5 lb';
else if wd2> 5 then loss_weight_G = 'losing > 5 lb';
else loss_weight_G ='missing';

run;

/*3.Create permanent data set*/

libname projectd "/folders/myfolders";
data projectd.weight_loss;
set wl2;
run;

/*4.create cross-tab for walk steps' groups (Walk_steps_g) and 
weight difference/loss groups (loss_weight_g)*/
proc freq data = wl2 ;
table walk_steps_G * loss_weight_G/norow nocol;
run;

