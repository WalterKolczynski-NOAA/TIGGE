/* generateTestVariable.c
** 
**  Generates the test variable and writes out the file.
**
*/
#include "ncdcTigge.h"

void generateTestVariable(int yyyy, int mm, int dd, int hh, int fff, int em){
	grib_handle *gh;
	char fileName[128];
	//long disc, edition;
	int i;
	double* values;
	size_t dataSize = 0;
	size_t size = 0;
	const void* buffer = NULL;
	
	time_t timePointer;
	struct tm *modelRunTime;
	
	
	
	// generates the time stuff.
	time(&timePointer);
	modelRunTime = gmtime(&timePointer);
	
	modelRunTime->tm_sec = 0;
	modelRunTime->tm_min = 0;
	modelRunTime->tm_hour = hh;
	modelRunTime->tm_mday = dd;
	modelRunTime->tm_mon = mm-1;
	modelRunTime->tm_year = yyyy - 1900;
	
	mktime(modelRunTime);
	
	
	// This is the test variable.
	// this is not ment to write out actual data, just to get the skeleton file down with bogus data values there.
	
	// first create the new skeleton file.
	gh = newGribRecord(yyyy, mm, dd, hh, fff, em);
	
	// name format from:   http://tigge.ecmwf.int/ldm_protocol.html
	sprintf(fileName, "z_tigge_c_cccc_%04d%02d%02d%02d0000_glob_cf_sl_%03d_0000_test.grib", yyyy, mm, dd, hh, fff);
	printf("%s\n", fileName);
	
	
	/* Set all the stuff up that defines the "snow fall water equivalent" variable */
	// product definition template number, this means that it conforms to template 4.XX, where XX is this number */
	GRIB_CHECK(grib_set_long(gh, "productDefinitionTemplateNumber", 11), 0);
	
	GRIB_CHECK(grib_set_long(gh, "parameterCategory", 1), 0);
	GRIB_CHECK(grib_set_long(gh, "parameterNumber", 53), 0);
	
	
	
	GRIB_CHECK(grib_set_long(gh, "typeOfFirstFixedSurface", 1), 0);
	GRIB_CHECK(grib_set_missing(gh, "scaleFactorOfFirstFixedSurface"), 0);
	GRIB_CHECK(grib_set_missing(gh, "scaledValueOfFirstFixedSurface"), 0);
	
	GRIB_CHECK(grib_set_long(gh, "typeOfSecondFixedSurface", 255), 0);
	GRIB_CHECK(grib_set_missing(gh, "scaleFactorOfSecondFixedSurface"), 0);
	GRIB_CHECK(grib_set_missing(gh, "scaledValueOfSecondFixedSurface"), 0);
	
	
	GRIB_CHECK(grib_set_long(gh, "yearOfEndOfOverallTimeInterval", 2007), 0);
	GRIB_CHECK(grib_set_long(gh, "monthOfEndOfOverallTimeInterval", 10), 0);
	GRIB_CHECK(grib_set_long(gh, "dayOfEndOfOverallTimeInterval", dd+16), 0);
	GRIB_CHECK(grib_set_long(gh, "hourOfEndOfOverallTimeInterval", hh), 0);
	GRIB_CHECK(grib_set_long(gh, "minuteOfEndOfOverallTimeInterval", 0), 0);
	GRIB_CHECK(grib_set_long(gh, "secondOfEndOfOverallTimeInterval", 0), 0);
	
	//GRIB_CHECK(grib_set_long(gh, "numberOfTimeRangeSpecificationsDescribingTheTimeIntervalsUsedToCalculateTheStatisticallyProcessedField", 1), 0);
	GRIB_CHECK(grib_set_long(gh, "numberOfMissingInStatisticalProcess", 0), 0);
	
	GRIB_CHECK(grib_set_long(gh, "typeOfStatisticalProcessing", 1), 0);
	GRIB_CHECK(grib_set_long(gh, "typeOfTimeIncrementBetweenSuccessiveFieldsUsedInTheStatisticalProcessing", 2), 0);
	
	GRIB_CHECK(grib_set_long(gh, "indicatorOfUnitOfTimeRange", 1), 0);
	GRIB_CHECK(grib_set_long(gh, "lengthOfTimeRange", 0), 0);
	GRIB_CHECK(grib_set_long(gh, "indicatorOfUnitForTimeIncrement", 255), 0);
	GRIB_CHECK(grib_set_long(gh, "timeIncrement", 0), 0);
	
	
	
	// only run once for the test file.
	if( (fff == 0) && (em == 0) ){
		FILE *outGribFile = fopen(fileName, "w");
        dataSize = 65160;
		
		// allocate the memory for the data.
		values = (double*)calloc(dataSize, sizeof(double));
        if(!values){
                printf("Failed to allocate the required number of bytes.\n");
                exit(1);
        }
		
		// fill the array with numbers. 
        for(i=0; i<65160; i++){
                values[i] = (double)i;
        }

		// write the data into the grib record.
		GRIB_CHECK(grib_set_double_array(gh, "values", values, dataSize), 0);
		
		// save the message out to the buffer.
		GRIB_CHECK(grib_get_message(gh, &buffer, &size), 0);
		
		// write the buffer to the file.
		if(fwrite(buffer, 1, size, outGribFile) != size){
			printf("Cannot write file out!\n");
		}
		
		free(values);
		fclose(outGribFile);
	}
	
	
	
	// reset things
	rewind(aFile);
	grib_handle_delete(gh);
	
	
	return;
}





/*
* Generates the test variable that acts like a time-integrated variable
*
*	parameters:
*		int  yyyy	The year
*		int  mm		The Month
*		int  dd		The Day
*		int  fff	The Forecast Hour (should be zero, because it is a TI run)
*		int  em		The Ensemble Member
*		void**  gribBuffer	The array of pointers to the stored off data.
*/
void generateTestVariableTi(int yyyy, int mm, int dd, int fff, int em, void** gribBuffer){
	grib_handle* gh;
	int i;
	long forecastTime;
	
	for(i = 0; i < 65; i++){
		printf("size of bytes: %ld \n", bytesPerRecord[TEST_VARIABLE_TI][i] );
		gh = grib_handle_new_from_message(NULL,  gribBuffer[i], bytesPerRecord[TEST_VARIABLE_TI][i]);
		
		// now you have access to the grib handle.  remember to delete them before you are done.
		
		GRIB_CHECK(grib_get_long(gh,"forecastTime", &forecastTime),0);
		
		
		
		grib_handle_delete(gh);
	}
	
	return;
}

