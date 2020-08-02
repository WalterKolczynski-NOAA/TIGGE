/* NCDC Tigge
**
** ncdcTigge.c
** The runner application for the NCDC Tigge Project (phase 1)
**
*/
#include "ncdcTigge.h"

/* private function definitions */
void printUsage();


/* the main function */
int main(int argc, char** argv)
	{
	mtrace();
	
	int ensembleMember;
	int forecastHour;
	int year, month, day, hour;
	char syear[5], smonth[3], sday[3], shour[3];
	int i;
	int status = -1;
	char aFileName[128];
	char bFileName[128];
	time_t ensembleStart, ensembleEnd;
	double elapsedEnsembleTime;

	ignoreMissingInput = 0;


	//  =---------- ARG PARSER ----------=

	printf("\nncdcTigge : Start\n\n");

	// check and parse the input parameters
	// if there are less than 2 arguements.
	if(argc <2 )
		{
		// if there is not the right amount of parameters
		printUsage();
		return 1;
		}
	
	// if there are more than 2 arguements.
	if(argc >= 2)
		{
		// process the date arg.
		if( strlen(argv[1]) != 10 )
			{
			// check if the string is of the correct length
			printUsage();
			return(1);
			}
			// copy the strings into the other memory addresses.
		strncpy(syear, &argv[1][0], 4);
		strncpy(smonth, &argv[1][4], 2);
		strncpy(sday, &argv[1][6], 2);
		strncpy(shour, &argv[1][8], 2);
			// and end the string.
		syear[4] = '\0';
		smonth[2] = '\0';
		sday[2] = '\0';
		shour[2] = '\0';
			// now convert to their integer counterpart.
		year = atoi(syear);
		month = atoi(smonth);
		day = atoi(sday);
		hour = atoi(shour);
		
			// reset the queue.
		fillQueueWithBogusData();
			
			// exactly 2 args, no more.
		if(argc == 2)
			{
			printf("no variable args, going with default (all)\n");
			fillQueueWithDefault();
			}

		// process any other arg after that.
		if(argc > 2 && argc <= NUMBER_OF_VARIABLES+2)
			{
			for(i=2; i<argc; i++)
				{
				status = addVariableToProcessList(i-2, argv[i]);
				// check the status.
				if(status == 0)
					{
					//printf("%s was added.\n", argv[i]); 
					/* do nothing, keep going */
					}
				else if(status == 1)
					{
				// all was reached, break out
				//printf("all was included in variable args... filling up!\n");
					fillQueueWithDefault();
					break;
					}
				else 
					{
					fprintf(stderr, "Status code from addVariableToProcessList() is %d.  Exiting.\n", status);
					return 1;
					}
				}
			}
		}
    // END if(argc >= 2)	
	
	
	printf("Done Arg parser.\n\n");

	/* Definitions for the Time Integrated Variables */
	//void** testVariableBuffer = NULL;

	void** timeIntegratedOutgoingLongWaveRadiationBuffer = NULL;
	void** timeIntegratedSurfaceLatentHeatFluxBuffer = NULL;
	void** timeIntegratedSurfaceSensibleHeatFluxBuffer = NULL;
	void** timeIntegratedSurfaceNetSolarRadiationBuffer = NULL;
	void** timeIntegratedSurfaceNetThermalRadiationBuffer = NULL;
	void** timeIntegratedSnowFallWaterEquivalentBuffer = NULL;
	void** totalPrecipitationBuffer = NULL;

	// 				-- pseudo-structure --
	//     LOOP OVER ENSEMBLE MEMBERS
	//			LOOP OVER FORECASTS HOURS foreach member
	//				LOOP OVER SELECTED VARIABLES foreach forecast

	printf("Ensemble Member #:  PROGRESS (* = 1 6-hr forecast step)\n");
	printf("=========================================================\n\n");

	// for each ensemble member, we are going to generate all the variables.
	for(ensembleMember = 0; ensembleMember < ENSEMBLE_MEMBERS; ensembleMember++)
		{
		//printf("Ensemble Member: %d\n  ", ensembleMember);

		// Some variables are calcuated as instant values for each fct.hour
		// These can be inserted inside of this forecast hour loop.
		//
		// The others need to have those variables stored off.
		// the stored records will be used for the time-integrated variables.
		
		printf(" M %02d:  [", ensembleMember);
		fflush(stdout);
		// start the clock
		time(&ensembleStart);		


		for(forecastHour = 0; forecastHour <= FORECAST_HOURS; forecastHour += 6)
			{


			// it is ok to fill missing input on fct hour 0 on some rad. fields
			ignoreMissingInput = 1;
			if( forecastHour != 0 )
				{ ignoreMissingInput = 0; }

			// Open the A & B files
			generateInputFilename(0, year, month, day, hour, forecastHour, ensembleMember, aFileName);
			generateInputFilename(1, year, month, day, hour, forecastHour, ensembleMember, bFileName);

			printf("opening : %s & %s\n",aFileName,bFileName);

			aFile = fopen(aFileName, "r");
			bFile = fopen(bFileName, "r");
			
			// check if the files opened correctly.
			if(aFile == NULL)
				{
				fprintf(stderr, "The File \"%s\" was not opened correctly\n",
					aFileName);
				return 1;
				}
			if(bFile == NULL)
				{
				fprintf(stderr, "The File \"%s\" was not opened correctly\n",
					bFileName);
				return(1);
				}

			printf("+");

                        timeIntegratedOutgoingLongWaveRadiationBuffer = loadDataForVariable(TIME_INTEGRATED_OUTGOING_LONG_WAVE_RADIATION, timeIntegratedOutgoingLongWaveRadiationBuffer);
                        timeIntegratedSurfaceLatentHeatFluxBuffer = loadDataForVariable(TIME_INTEGRATED_SURFACE_LATENT_HEAT_FLUX, timeIntegratedSurfaceLatentHeatFluxBuffer);
                        timeIntegratedSurfaceSensibleHeatFluxBuffer = loadDataForVariable(TIME_INTEGRATED_SURFACE_SENSIBLE_HEAT_FLUX, timeIntegratedSurfaceSensibleHeatFluxBuffer);
                        timeIntegratedSurfaceNetSolarRadiationBuffer = loadDataForVariable(TIME_INTEGRATED_SURFACE_NET_SOLAR_RADIATION, timeIntegratedSurfaceNetSolarRadiationBuffer);
                        timeIntegratedSurfaceNetThermalRadiationBuffer = loadDataForVariable(TIME_INTEGRATED_SURFACE_NET_THERMAL_RADIATION, timeIntegratedSurfaceNetThermalRadiationBuffer);

			// End of the fields that have missing file protection.
			ignoreMissingInput = 0;

	// NON- Time Integrated variables.
	//status = generateVariable(TEST_VARIABLE, year, month, day, hour, forecastHour, ensembleMember, NULL);

			status = generateVariable(SNOW_FALL_WATER_EQUIVALENT, year, month, day, hour, forecastHour, ensembleMember, NULL);
			status = generateVariable(TOTAL_COLUMN_WATER, year, month, day, hour, forecastHour, ensembleMember, NULL);
			status = generateVariable(POTENTIAL_TEMPERATURE, year, month, day, hour, forecastHour, ensembleMember, NULL);
			status = generateVariable(SOIL_MOISTURE, year, month, day, hour, forecastHour, ensembleMember, NULL);
			status = generateVariable(SOIL_TEMPERATURE, year, month, day, hour, forecastHour, ensembleMember, NULL);
	
			// Load the data for the Time integrated variables
			//testVariableBuffer = loadDataForVariable(TEST_VARIABLE_TI, testVariableBuffer);


			totalPrecipitationBuffer = loadDataForVariable(TOTAL_PRECIPITATION, totalPrecipitationBuffer);
            timeIntegratedSnowFallWaterEquivalentBuffer = loadDataForVariable(TIME_INTEGRATED_SNOW_FALL_WATER_EQUIVALENT, timeIntegratedSnowFallWaterEquivalentBuffer);

			// close the ncep files that are still open.
			fclose(aFile);
			fclose(bFile);
			printf("*");		// poor mans "Status bar" tick
			fflush(stdout);
			}

// printf("DEBUG - start loading time integration -\n");

		// Calculate the time-integrated variables
		// These use the data collected from the inner loop

		generateVariable(TIME_INTEGRATED_OUTGOING_LONG_WAVE_RADIATION, year, month, day, hour, 0, ensembleMember, timeIntegratedOutgoingLongWaveRadiationBuffer);
		generateVariable(TIME_INTEGRATED_SURFACE_LATENT_HEAT_FLUX, year, month, day, hour, 0, ensembleMember, timeIntegratedSurfaceLatentHeatFluxBuffer);
		generateVariable(TIME_INTEGRATED_SURFACE_SENSIBLE_HEAT_FLUX, year, month, day, hour, 0, ensembleMember, timeIntegratedSurfaceSensibleHeatFluxBuffer);
		generateVariable(TIME_INTEGRATED_SNOW_FALL_WATER_EQUIVALENT, year, month, day, hour, 0, ensembleMember, timeIntegratedSnowFallWaterEquivalentBuffer);
		generateVariable(TIME_INTEGRATED_SURFACE_NET_SOLAR_RADIATION, year, month, day, hour, 0, ensembleMember, timeIntegratedSurfaceNetSolarRadiationBuffer);
		generateVariable(TIME_INTEGRATED_SURFACE_NET_THERMAL_RADIATION, year, month, day, hour, 0, ensembleMember, timeIntegratedSurfaceNetThermalRadiationBuffer);
		generateVariable(TOTAL_PRECIPITATION, year, month, day, hour, 0, ensembleMember, totalPrecipitationBuffer);


		// Free memory used for this ensemble members time-integrated variables

		freeDataForVariable(TIME_INTEGRATED_OUTGOING_LONG_WAVE_RADIATION, timeIntegratedOutgoingLongWaveRadiationBuffer);
		freeDataForVariable(TIME_INTEGRATED_SURFACE_LATENT_HEAT_FLUX, timeIntegratedSurfaceLatentHeatFluxBuffer);
		freeDataForVariable(TIME_INTEGRATED_SURFACE_SENSIBLE_HEAT_FLUX, timeIntegratedSurfaceSensibleHeatFluxBuffer);
		freeDataForVariable(TIME_INTEGRATED_SURFACE_NET_SOLAR_RADIATION, timeIntegratedSurfaceNetSolarRadiationBuffer);
		freeDataForVariable(TIME_INTEGRATED_SURFACE_NET_THERMAL_RADIATION, timeIntegratedSurfaceNetThermalRadiationBuffer);
        freeDataForVariable(TIME_INTEGRATED_SNOW_FALL_WATER_EQUIVALENT, timeIntegratedSnowFallWaterEquivalentBuffer);
		freeDataForVariable(TOTAL_PRECIPITATION, totalPrecipitationBuffer);
		
		// stop the clock
		time(&ensembleEnd);
		elapsedEnsembleTime = abs(difftime(ensembleStart, ensembleEnd));		
		
		printf("]\n\t\tDone : Total Time: %02d:%02d \n", (int)floor(elapsedEnsembleTime/60), ((int)elapsedEnsembleTime)%60 );
		}

	//free(testVariableBuffer);
	free(timeIntegratedOutgoingLongWaveRadiationBuffer);
	free(timeIntegratedSurfaceLatentHeatFluxBuffer);
	free(timeIntegratedSurfaceSensibleHeatFluxBuffer);
	free(timeIntegratedSurfaceNetSolarRadiationBuffer);
	free(timeIntegratedSurfaceNetThermalRadiationBuffer);
	free(timeIntegratedSnowFallWaterEquivalentBuffer);
	free(totalPrecipitationBuffer);

	printf("\nncdcTigge Process exited normally.\n\n");
	return 0;
	}


/*
** printUsage()
**	Prints the usage statement if a user fails to input the correct parameters.
*/

void printUsage(){
	printf(" ncdcTigge: \n");
	printf("   This application is for the generation of missing TIGGE variables.  The application \n");
	printf("   reads the current NCEP data for the given date, processes it, and produces 11 missing \n");
	printf("   TIGGE variables.\n");
	printf("\n");
	printf(" ncdcTigge usage:\n");
	printf("   ncdcTigge <yyyymmddhh> [variable_name] ...\n");
	printf("       <yyyymmddhh> is the string representing the date and time of the model run. \n");
	printf("       [variable_name] is the TIGGE short name for the variable(s) to be processed. \n");
	printf("           You may list as many as you like.  All variables will be processed if none \n");
	printf("           are supplied, or the keyword \"all\" is used. \n");
	printf("\n");
	printf(" Supported TIGGE Variables: \n");
	printf("    Short Name      Long Name  \n");
	printf("    -------------------------  \n");
	printf("    pt              Potential Temperature  \n");
	printf("    sf6             Snow Fall Water Equivalent  \n");
    printf("    sf              Time-integrated Snow Fall Water Equivalent \n");
	printf("    sm              Soil Moisture  \n");
	printf("    st              Soil Temperature  \n");
	printf("    ttr             Time-integrated Outgoing Long Wave Radiation  \n");
	printf("    slhf            Time-integrated Surface Latent Heat Flux  \n");
	printf("    ssr             Time-integrated Net Solar Radiation  \n");
	printf("    str             Time-integrated Surface Net Thermal Radiation  \n");
	printf("    sshf            Time-integrated Surface Sensible Heat Flux  \n");
	printf("    tcw             Total Column Water  \n");
	printf("    tp              Total Precipitation  \n");
	printf("\n");
}
