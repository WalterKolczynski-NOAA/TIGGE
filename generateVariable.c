/* generateVariable.c
**
**
**  provides a unified interface for generating the variables.
*/
#include "ncdcTigge.h"


/* generateVariable
**   The interface that is used to generate a variable.
**
** Parameters:
**	int		varName				The name of the variable to be generated.  Enumerated in the header "ncdcTigge.h" 
**  int		yyyy				The year of the model run that we are generating.
**  int		mm					The month of the model run that we are generating.
**  int		dd					The day of the model run that we are generating.
**  int		hh					The hour of the model run that we are generating.
**  int		fff					The forecast hour offset
**  int		em					The ensemble member
**  void**  resource			A pointer to an array holding the data for the time integration. (only used
**									in time-integrated variables)
*/
int generateVariable(int varName, int yyyy, int mm, int dd, int hh, int fff, int em, void** resource){
	// use this as a switch to choose how you want to process the data.
	// This allows us to just enumerate a value, add a switch statement here, and flush out the code.
	// example:

/*  This code had the right idea, but is in the wrong place.

		// Dan Swank Feb.2016
		// selectively excuse records that will not have data records to load.
		// when (ignoreMissingInput) is not zero, a blank record will be inserted in for missing input recs.

        if( (fff == 0) && (varName == TIME_INTEGRATED_OUTGOING_LONG_WAVE_RADIATION || 
			varName == TIME_INTEGRATED_SURFACE_SENSIBLE_HEAT_FLUX ||
			varName == TIME_INTEGRATED_SURFACE_LATENT_HEAT_FLUX ||
			varName == TIME_INTEGRATED_SURFACE_NET_THERMAL_RADIATION ||
			varName == TIME_INTEGRATED_SURFACE_NET_SOLAR_RADIATION 
			) )
		{ ignoreMissingInput = 1; }
	else	{ ignoreMissingInput = 0; }
  */


	// first, test if the variable is a real one. (lol, don't send a bogus variable name!)
	if( variableShortName(varName) == NULL )
		{
		fprintf(stderr, "Error, The requested variable is not valid.   varName = %d\n", varName);
		return 0;
		}

	// now test if the variable is on the "to-do" list
	if( !processQueueContains(variableShortName(varName)) ){
		//printf("%s is not on the list, skipping it.\n", variableShortName(varName));
		return 0;
	}

	// SNOW_FALL_WATER_EQUIVALENT
	if(varName == SNOW_FALL_WATER_EQUIVALENT){
	  generateSnowFallWaterEquivalent(yyyy, mm, dd, hh, fff, em);
	  }

    // T.I. SNOW_FALL_WATER_EQUIVALENT
    if(varName == TIME_INTEGRATED_SNOW_FALL_WATER_EQUIVALENT)
		{
		generateTimeIntegratedSnowFallWaterEquivalent(yyyy, mm, dd, hh, fff, em, resource);
		}

	// TIME_INTEGRATED_OUTGOING_LONG_WAVE_RADIATION
	if(varName == TIME_INTEGRATED_OUTGOING_LONG_WAVE_RADIATION)
		{
		generateTimeIntegratedOutgoingLongWaveRadiation(yyyy, mm, dd, hh, em, resource);
		}

	// TIME_INTEGRATED_SURFACE_LATENT_HEAT_FLUX
	if(varName == TIME_INTEGRATED_SURFACE_LATENT_HEAT_FLUX){
		generateTimeIntegratedSurfaceLatentHeatFlux(yyyy, mm, dd, hh, em, resource);
	}

	// TIME_INTEGRATED_SURFACE_SENSIBLE_HEAT_FLUX
	if(varName == TIME_INTEGRATED_SURFACE_SENSIBLE_HEAT_FLUX){
		generateTimeIntegratedSurfaceSensibleHeatFlux(yyyy, mm, dd, hh, em, resource);
	}

	// TIME_INTEGRATED_SURFACE_NET_SOLAR_RADIATION
	if(varName == TIME_INTEGRATED_SURFACE_NET_SOLAR_RADIATION){
		generateTimeIntegratedSurfaceNetSolarRadiation(yyyy, mm, dd, hh, em, resource);
	}

	// TIME_INTEGRATED_SURFACE_NET_THERMAL_RADIATION
	if(varName == TIME_INTEGRATED_SURFACE_NET_THERMAL_RADIATION){
		generateTimeIntegratedSurfaceNetThermalRadiation(yyyy, mm, dd, hh, em, resource);
	}
	
	// TOTAL_PRECIPITATION
	if(varName == TOTAL_PRECIPITATION){
		generateTotalPrecipitation(yyyy, mm, dd, hh, em, resource);
	}

	// TOTAL_PRECIPITATION
	if(varName == TOTAL_COLUMN_WATER){
		generateTotalColumnWater(yyyy, mm, dd, hh, fff, em);
	}

	// POTENTIAL_TEMPERATURE
	if(varName == POTENTIAL_TEMPERATURE){
		generatePotentialTemperature(yyyy, mm, dd, hh, fff, em);
	}

	// SOIL_MOISTURE
	if(varName == SOIL_MOISTURE){
		generateSoilMoisture(yyyy, mm, dd, hh, fff, em);
	}

	// SOIL_TEMPERATURE
	if(varName == SOIL_TEMPERATURE){
		generateSoilTemperature(yyyy, mm, dd, hh, fff, em);
	}


	/*
	// TEST_VARIABLE
	if(varName == TEST_VARIABLE){
		generateTestVariable(yyyy, mm, dd, hh, fff, em);
	}
	
	
	if(varName == TEST_VARIABLE_TI){
	// do the time integrated stuff.
		generateTestVariableTi(yyyy, mm, dd, hh, em, resource);
	}
	*/
	

	return 0;
}




