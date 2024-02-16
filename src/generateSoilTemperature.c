/* generate Soil Temperature
** 
**  Generates the Soil Temperature variable and writes out the file.
**
**  Danny Brinegar & Steven Anthony, 2007
**  Dan Swank (2016)
*/
#include "ncdcTigge.h"

void generateSoilTemperature(int yyyy, int mm, int dd, int hh, int fff, int em){
	grib_handle* gh = NULL;

        rewind(aFile);
        rewind(bFile);

	grib_handle* ncepUpperSoilTemperature = NULL;
	size_t ncepValuesSize = get_n_points(yyyy,mm,dd,hh);
	int n_lat = get_n_lat(yyyy,mm,dd,hh);
	int n_lon = get_n_lon(yyyy,mm,dd,hh);
	double* ncepUpperSoilTemperatureValues = NULL;
	
	grib_handle* ncepLowerSoilTemperature = NULL;
	double* ncepLowerSoilTemperatureValues = NULL;	
	
	double* tiggeSoilTemperatureValues = NULL;	
	
	char fileName[256];
	
	long ncepDiscipline, ncepParameterCategory, ncepParameterNumber, ncepLevel, ncepLevelValue;
	int i, found1, found2;
	int errorCode;
	
	/*
	** Section 1.  read the A file (from NCEP)
	*/
	
	// first, is the file here?
	if(aFile == NULL)
		{
		fprintf(stderr, "Error, could not read the a-type file.  Exiting generateSoilTemperature() \n");
		return;
		}
        if( bFile == NULL )
                {
                fprintf( stderr, "Error, could not read the b-type file.  Exiting generateSoilTemperature( )\n");
                return;
                }


	
	// first create the new skeleton file.
	gh = newGribRecord(yyyy, mm, dd, hh, fff, em, n_lat, n_lon);

	// name format from:   http://tigge.ecmwf.int/ldm_protocol.html
	generateFileName(SOIL_TEMPERATURE, yyyy, mm, dd, hh, fff, em, fileName);



	// start plugging in the metadata.
	// product definition template number, this means that it conforms to template 4.XX, where XX is this number */
	GRIB_CHECK(grib_set_long(gh, "discipline", 2), 0);
	GRIB_CHECK(grib_set_long(gh, "productDefinitionTemplateNumber", 1), 0);
	
	GRIB_CHECK(grib_set_long(gh, "parameterCategory", 0), 0);
	GRIB_CHECK(grib_set_long(gh, "parameterNumber", 2), 0);
	
	GRIB_CHECK(grib_set_long(gh, "typeOfFirstFixedSurface", 106), 0);
	GRIB_CHECK(grib_set_long(gh, "scaleFactorOfFirstFixedSurface", 0), 0);
	GRIB_CHECK(grib_set_long(gh, "scaledValueOfFirstFixedSurface", 0), 0);
	
	GRIB_CHECK(grib_set_long(gh, "typeOfSecondFixedSurface", 106), 0);
	GRIB_CHECK(grib_set_long(gh, "scaleFactorOfSecondFixedSurface", 1), 0);
	GRIB_CHECK(grib_set_long(gh, "scaledValueOfSecondFixedSurface", 2), 0);
	
	//GRIB_CHECK(grib_set_long(gh, "yearOfEndOfOverallTimeInterval", yyyy), 0);
	
	//GRIB_CHECK(grib_set_long(gh, "yearOfEndOfOverallTimeInterval", yyyy), 0);
	//GRIB_CHECK(grib_set_long(gh, "monthOfEndOfOverallTimeInterval", mm), 0);
	//GRIB_CHECK(grib_set_long(gh, "dayOfEndOfOverallTimeInterval", dd), 0);
	//GRIB_CHECK(grib_set_long(gh, "hourOfEndOfOverallTimeInterval", hh), 0);
	//GRIB_CHECK(grib_set_long(gh, "minuteOfEndOfOverallTimeInterval", 0), 0);
	//GRIB_CHECK(grib_set_long(gh, "secondOfEndOfOverallTimeInterval", 0), 0);
	
	//GRIB_CHECK(grib_set_long(gh, "numberOfMissingInStatisticalProcess", 0), 0);
	
	//GRIB_CHECK(grib_set_long(gh, "typeOfStatisticalProcessing", 1), 0);
	//GRIB_CHECK(grib_set_long(gh, "typeOfTimeIncrementBetweenSuccessiveFieldsUsedInTheStatisticalProcessing", 2), 0);
	
	//GRIB_CHECK(grib_set_long(gh, "lengthOfTimeRange", 0), 0);
	//GRIB_CHECK(grib_set_long(gh, "indicatorOfUnitForTimeIncrement", 255), 0);
	//GRIB_CHECK(grib_set_long(gh, "timeIncrement", 0), 0);
	

	// set marsStartStep to make it stop yelling.
	GRIB_CHECK(grib_set_long(gh, "marsStartStep", 0), 0);
	GRIB_CHECK(grib_set_long(gh, "forecastTime",(long)fff ), 0);

	found1 = found2 = 0;
	ncepDiscipline = ncepParameterCategory = ncepParameterNumber = ncepLevel = ncepLevelValue = -1;


	// optomized for 2 variables, hopefully this will speed things up quite a bit.
	// while either is not found, continue looking.
	while(!found1 || !found2){
		if( (ncepUpperSoilTemperature != NULL) && !found1 ) grib_handle_delete(ncepUpperSoilTemperature);
		if( (ncepLowerSoilTemperature != NULL) && !found2 ) grib_handle_delete(ncepLowerSoilTemperature);
		
		if( !found1 && !found2 )
			{
			// search for the first one.
			// With Dec.02.2015 GENS change, we need to be looking through BOTH a&b


			//printf("DEBUG: Looking through A file.\n");
			ncepUpperSoilTemperature = grib_handle_new_from_file(0, aFile, &errorCode);

			if( ncepUpperSoilTemperature == NULL ) 
				{
				// printf("DEBUG: Looking through B file.\n");
				ncepUpperSoilTemperature = grib_handle_new_from_file( 0, bFile, &errorCode );
				}


			if( ncepUpperSoilTemperature == NULL ) 
				{
				printf("Error: (ncepUpperSoilTemperature) unable to create handle from file. error code: %d \n", errorCode);
				return;
				}


			GRIB_CHECK(grib_get_long(ncepUpperSoilTemperature, "discipline", &ncepDiscipline), 0);
			GRIB_CHECK(grib_get_long(ncepUpperSoilTemperature, "parameterCategory", &ncepParameterCategory), 0);
			GRIB_CHECK(grib_get_long(ncepUpperSoilTemperature, "parameterNumber", &ncepParameterNumber), 0);
			GRIB_CHECK(grib_get_long(ncepUpperSoilTemperature, "typeOfFirstFixedSurface", &ncepLevel), 0);
			GRIB_CHECK(grib_get_long(ncepUpperSoilTemperature, "scaledValueOfFirstFixedSurface", &ncepLevelValue), 0);


//printf("DEBUG (%i %i %i %i %i) \n",ncepDiscipline,ncepParameterCategory,ncepParameterNumber,ncepLevel,ncepLevelValue);

			// if it is either one of the variables.
			if( ((ncepDiscipline == 2) && (ncepParameterCategory == 0) && (ncepParameterNumber == 2) && (ncepLevel == 106) && (ncepLevelValue == 0) ) ||
				((ncepDiscipline == 2) && (ncepParameterCategory == 0) && (ncepParameterNumber == 2) && (ncepLevel == 106) && (ncepLevelValue == 10) ) )
				{
				found1 = 1;
				ncepDiscipline = ncepParameterCategory = ncepParameterNumber = ncepLevel = ncepLevelValue = -1;
			}
		
		}else if( found1 && !found2)
			{
			// search for the second one.

			ncepLowerSoilTemperature = grib_handle_new_from_file(0, aFile, &errorCode);

				// As like above, try the B file too.
                        if (ncepLowerSoilTemperature == NULL)
				{
				ncepLowerSoilTemperature = grib_handle_new_from_file(0, bFile, &errorCode );
				}


			if (ncepLowerSoilTemperature == NULL) {
				printf("Error22: (ncepLowerSoilTemperature) unable to create handle from file. error code: %d \n", errorCode);
				return;
			}
			GRIB_CHECK(grib_get_long(ncepLowerSoilTemperature, "discipline", &ncepDiscipline), 0);
			GRIB_CHECK(grib_get_long(ncepLowerSoilTemperature, "parameterCategory", &ncepParameterCategory), 0);
			GRIB_CHECK(grib_get_long(ncepLowerSoilTemperature, "parameterNumber", &ncepParameterNumber), 0);
			GRIB_CHECK(grib_get_long(ncepLowerSoilTemperature, "typeOfFirstFixedSurface", &ncepLevel), 0);
			GRIB_CHECK(grib_get_long(ncepLowerSoilTemperature, "scaledValueOfFirstFixedSurface", &ncepLevelValue), 0);
			
			// if it is either one of the variables
			if( ((ncepDiscipline == 2) && (ncepParameterCategory == 0) && (ncepParameterNumber == 2) && (ncepLevel == 106) && (ncepLevelValue == 0) ) ||
				((ncepDiscipline == 2) && (ncepParameterCategory == 0) && (ncepParameterNumber == 2) && (ncepLevel == 106) && (ncepLevelValue == 10) ) ){
				found2 = 1;
				ncepDiscipline = ncepParameterCategory = ncepParameterNumber = ncepLevel = ncepLevelValue = -1;
			}
		}
	}
	
	ncepUpperSoilTemperatureValues = calloc(ncepValuesSize, sizeof(double));
	ncepLowerSoilTemperatureValues = calloc(ncepValuesSize, sizeof(double));
	GRIB_CHECK(grib_get_double_array(ncepUpperSoilTemperature, "values", ncepUpperSoilTemperatureValues, &ncepValuesSize), 0);
	GRIB_CHECK(grib_get_double_array(ncepLowerSoilTemperature, "values", ncepLowerSoilTemperatureValues, &ncepValuesSize), 0);


	// both are now stored off.
	tiggeSoilTemperatureValues = calloc(ncepValuesSize, sizeof(double));


	if(tiggeSoilTemperatureValues == NULL){
		fprintf(stderr, "Error, There was a problem Allocating the memory for storing the data. Exiting generateSoilTemperature()\n");
		exit(1);
	}
	// Store off the bitmap information (this is a land mask)
	GRIB_CHECK( grib_set_long(gh, "bitMapIndicator", 0), 0);

	// for each point in the grid.
	for(i=0; i<ncepValuesSize; i++){
		tiggeSoilTemperatureValues[i] = (ncepUpperSoilTemperatureValues[i] + ncepLowerSoilTemperatureValues[i]) / 2.0;
	}

	// store the data into the grib file
	GRIB_CHECK( grib_set_double_array(gh, "values", tiggeSoilTemperatureValues, ncepValuesSize),  0);
	

	if(writeGribToFile(gh, fileName) != 0){
		printf("ERROR, did not write the file \"%s\" out successfully.\n", fileName);
	}

	// free allocated memory
	free(ncepUpperSoilTemperatureValues);
	free(ncepLowerSoilTemperatureValues);
	free(tiggeSoilTemperatureValues);
		
	
	// delete grib_handles
	grib_handle_delete(gh);
	grib_handle_delete(ncepUpperSoilTemperature);
	grib_handle_delete(ncepLowerSoilTemperature);

	// rewind the files
	rewind(aFile);
	rewind(bFile);

}
