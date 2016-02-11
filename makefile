# Makefile for ncdcTigge
# NCDC TIGGE project.
# 2007


CC = gcc
CFLAGS = -Wall -g
LIBS = -lm -L/home/nomads/grib_api-1.13.0/lib -lgrib_api -ljasper
INC = 
DIST_PREFIX = /home/nomads/tigge

# Files Listed Here
SRC = util.c newGribRecord.c loadDataForVariable.c generateVariable.c \
	loadDataForTestVariable.c generateTestVariable.c generateTimeIntegratedSnowFallWaterEquivalent.c generateSnowFallWaterEquivalent.c \
	generateTimeIntegratedOutgoingLongWaveRadiation2016.c generateTimeIntegratedSurfaceLatentHeatFlux2016.c \
	generateTimeIntegratedSurfaceSensibleHeatFlux2016.c generateTimeIntegratedSurfaceNetSolarRadiation2016.c \
	generateTimeIntegratedSurfaceNetThermalRadiation2016.c generateTotalPrecipitation.c generateTotalColumnWater.c \
	generatePotentialTemperature.c generateSoilTemperature2016.c generateSoilMoisture.c
	
OBJ = $(SRC:.c=.o)

TIGGE_SRC = ncdcTigge.c
TIGGE_OBJ = $(TIGGE_SRC:.c=.o)

TEST_SRC = ncdcTiggeTest.c
TEST_OBJ = $(TEST_SRC:.c=.o)

# test_prefix can be changed to your home dir
TEST_PREFIX = /home/santhony/CUnit

TEST_LIBS = -L$(TEST_PREFIX)/lib -lcunit
TEST_INC = -I$(TEST_PREFIX)/include

# Targets
all: ncdcTigge
test: ncdcTest

# link the objects
ncdcTigge: $(TIGGE_OBJ)
	@echo ""
	@echo "  Linking objects..."
	@echo ""
	$(CC) $(OBJ) $(TIGGE_OBJ) $(LIBS) -o ncdcTigge

ncdcTest: $(TEST_OBJ)
	$(CC) $(OBJ) $(TEST_OBJ) $(LIBS) $(TEST_LIBS) -o ncdcTest

dist: ncdcTigge
	cp ncdcTigge ftpprdPullAll.pl ftpprdPull-a.pl ftpprdPull-b.pl run_ncep_convert.pl runQcOutput.pl runRecoverInput.pl runTigge.pl runUploader.pl runQcInput.pl runCheck.pl getGensTar.pl finalize.pl grib_convert_setup output-list.txt $(DIST_PREFIX)/


## compile the files
$(TIGGE_OBJ): $(OBJ)
	@echo ""
	@echo Compiling files
	$(CC) -c $(CFLAGS) $(TIGGE_SRC) $(INC)
	@echo ""

$(TEST_OBJ): $(OBJ)
	$(CC) -c $(CFLAGS) $(TEST_SRC) $(INC) $(TEST_INC)


#  base files
$(OBJ):
	$(CC) -c $(CFLAGS) $(SRC) $(INC)



.PHONY: clean all test dist
clean:
	rm -f ncdcTest ncdcTigge *.o
	@echo "   -- cleaned up files --"
	@echo ""

