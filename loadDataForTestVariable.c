/*
**  loadDataForTestVariable.c
**
**
**
*/
#include "ncdcTigge.h"

void** loadDataForTestVariable(void** gribBuffers){
	// seek to a variable.
	grib_handle* h = NULL;
	int err;
	int i;
	void** retBuffer = NULL;
	const void* buffer = NULL;
	size_t size = 0;
	
	// test if this is the first one.
	if(!numberOfSavedRecords[TEST_VARIABLE_TI]){
		printf("TEST_VARIABLE first run. \n");
		numberOfSavedRecords[TEST_VARIABLE_TI] = 0;
	}
	
	// just a test, go to the 2nd one.
	for(i=0; i<2; i++){
		h = grib_handle_new_from_file(0, aFile, &err);
		if (h == NULL) {
			printf("Error: unable to create handle from file. error code: %d \n", err);
			return NULL;
		}
	}
	
	// returns a pointer to the message (buffer) and its size.
	GRIB_CHECK(grib_get_message(h, &buffer, &size), 0);
	
	retBuffer = addGribRecordToArray(TEST_VARIABLE_TI, gribBuffers, buffer, size);
	
	// data is stored in buffer right now.
	//size_t x = sizeof(buffer);
	
	grib_handle_delete(h);
	// you must rewind the file that you scanned through!!!
	rewind(aFile);
	
	// h should now be set, so we want to add it to the grib handle array, and return it.
	//return addGribRecordToArray(gribBuffers, buffer);
	return retBuffer;
}
