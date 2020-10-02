/* loadDataForVariable.c
**
** this is the interface that is used ot load the data for a variable into an array.
**
*/
#include "ncdcTigge.h"


/*
** addGribRecordToArray()
**	This function takes a pointer to memory, creates its own copy of it, and then stores
**	the address into an array for future retrieval.  If the array is not large enough,
**	it is realloced to the requires size.  Once the new grib record is stored, the 
**	length of it is stored in bytesPerRecord[][] so that it can be accessed later.
**
**	Parameters:
**		int				varName		The enumerated variable name
**		void**			array		the array of pointers to store the location of the new data
**		const void*		record		the pointer to the data you wish to store
**		size_t			size		the size of the data that you wish to store (record)
**	
**	Returns:
**		void**			returns the pointer to the new array containing the saved grib records.
*/
void** addGribRecordToArray(int varName, void** array, const void* record, size_t size){
	// do some memory swapping to append the grib_handle to the end of the array.
	void* newRecord = NULL;
	void** tempArray = NULL;


	// generate the size of the old array
	size_t prevSize = numberOfSavedRecords[varName];
	//printf("%d\n", prevSize);
	
	// extend the array.
	tempArray = realloc(array, (prevSize+1)*sizeof(void*));

	// error checking
	if(tempArray == NULL){
		fprintf(stderr, "Could not realloc the memory correctly.\n");
		exit(1);
	}else{
		array = tempArray;
	}
	

	// allocate the memory space for the grib record and copy it in.
	newRecord = calloc(size, 1);
	newRecord = memcpy(newRecord, record, size);
	
	// save the size off.
	bytesPerRecord[varName][prevSize] = (long)size;
	
	array[prevSize] = newRecord;
	numberOfSavedRecords[varName]++;
	
	return array;
}



/*
** loadDataForVariable()
**	This function is the interface for loading data into an array for use in
**	computing time-integrated variables  
**
** Parameters:
**	int		varName		the enumerated variable name
**	void**	gribBuffer	the array where the grib records will be stored.
**
** Returns:
**	void**	returns the pointer to the array storing the grib records.
*/
void** loadDataForVariable(int varName, void** gribBuffer, int n_lat, int n_lon)
	{

	printf("%s %s%s","Loading data for: ",variableShortName(varName),"\n");

	// first, test if the variable is a real one.
	if( variableShortName(varName) == NULL )
		{
		fprintf(stderr, "Error, The requested variable is not valid.   varName = %d\n", varName);
		return NULL;
		}

	// now test if the variable is on the "to-do" list
	if( !processQueueContains(variableShortName(varName)) )
		{
		//printf("%s is not on the list, skipping it.\n", variableShortName(varName));
		return NULL;
		}

	// add to this if() switch when you get more variables.
	if(varName == TIME_INTEGRATED_OUTGOING_LONG_WAVE_RADIATION)
		{ 
		return loadDataForTimeIntegratedOutgoingLongWaveRadiation(gribBuffer, n_lat, n_lon);
		}

	if(varName == TIME_INTEGRATED_SURFACE_LATENT_HEAT_FLUX)
		{
		return loadDataForTimeIntegratedSurfaceLatentHeatFlux(gribBuffer, n_lat, n_lon);
		}

	if(varName == TIME_INTEGRATED_SURFACE_SENSIBLE_HEAT_FLUX)
		{
		return loadDataForTimeIntegratedSurfaceSensibleHeatFlux(gribBuffer, n_lat, n_lon);
		}
	
	if(varName == TIME_INTEGRATED_SURFACE_NET_SOLAR_RADIATION)
		{
		return loadDataForTimeIntegratedSurfaceNetSolarRadiation(gribBuffer, n_lat, n_lon);
		}
	
	if(varName == TIME_INTEGRATED_SURFACE_NET_THERMAL_RADIATION)
		{
		return loadDataForTimeIntegratedSurfaceNetThermalRadiation(gribBuffer, n_lat, n_lon);
		}

    if(varName == TIME_INTEGRATED_SNOW_FALL_WATER_EQUIVALENT )
        {
        return loadDataForTimeIntegratedSnowFallWaterEquivalent(gribBuffer, n_lat, n_lon);
        }

	if(varName == TOTAL_PRECIPITATION)
		{
		return loadDataForTotalPrecipitation(gribBuffer, n_lat, n_lon);
		}
	
	return NULL;
	}



/*
** freeDataForVariable()
**	This function frees all of the data for a paticular time-integrated variable
**
** Parameters:
**	int		varName		the enumerated variable name.
**	void**	array		the array of pointers to the saved off grib records.
**
*/
void freeDataForVariable(int varName, void** array)
	{
	int i;
	for(i = 0; i<numberOfSavedRecords[varName]; i++)
		{
		free(array[i]);
		array[i] = NULL;
		}
	numberOfSavedRecords[varName] = 0;
	return;
	}

