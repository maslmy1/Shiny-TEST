*CLEARS SAS LOG AND RESULTS FOR CLEANER WORKING ENVIRONMENT;
dm "log; clear; odsresults; clear;";

PROC IMPORT
	DATAFILE = 'C:\Users\ERobi\Documents\GitHub\Perception-of-Log-Scales\lineups-pilot-analysis\data\sim_response_data.csv'
	OUT = sim_lineup_data
	REPLACE;
	GUESSINGROWS = 50;
RUN;

TITLE "Simulated Lineup Results Data";
PROC PRINT DATA = sim_lineup_data (OBS = 10) NOOBS;
RUN;

TITLE "Simulated Lineup Model";
PROC GLIMMIX DATA = sim_lineup_data;
	CLASS 	wp nick_name data_name pic_id test_param param_value target_curvature null_curvature curvature;

	MODEL 	correct = curvature|test_param / D = Binomial LINK = logit;

	RANDOM	intercept / SUBJECT = nick_name;
	RANDOM	intercept / SUBJECT = data_name;
	RANDOM	curvature / SUBJECT = nick_name*data_name;

	LSMEANS	test_param*curvature / PLOT = MEANPLOT(SLICEBY = test_param CL ILINK JOIN) ILINK CL;
	SLICE	test_param*curvature / SLICEBY = curvature LINES;

	NLOPTIONS MAXITER = 100;
RUN;
