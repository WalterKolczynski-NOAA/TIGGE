# Makefile for ncdcTigge
# NCDC TIGGE project.
# 2007-2016

ifndef TIGGE_TOOLS
$(error ENV VAR TIGGE_TOOLS is not set, this should be the base PATH where you exported the repository - it contains ./src ./bin, etc. )
endif

CC = gcc
CFLAGS = -Wall -g
MYLIBS = $(LIBS) -lm -L$(TIGGE_TOOLS)/grib-api/lib -lgrib_api -L$(JASPER_LIBDIR) -ljasper
MYINC = $(INC) -I$(TIGGE_TOOLS)/grib-api/include -I$(JASPER_INC)
DIST_PREFIX = $(HOME)/tigge

# Files Listed Here
SRC = util.c newGribRecord.c loadDataForVariable.c generateVariable.c \
	loadDataForTestVariable.c generateTestVariable.c generateTimeIntegratedSnowFallWaterEquivalent.c generateSnowFallWaterEquivalent.c \
	generateTimeIntegratedOutgoingLongWaveRadiation2016.c generateTimeIntegratedSurfaceLatentHeatFlux2016.c \
	generateTimeIntegratedSurfaceSensibleHeatFlux2016.c generateTimeIntegratedSurfaceNetSolarRadiation2016.c \
	generateTimeIntegratedSurfaceNetThermalRadiation2016.c generateTotalPrecipitation.c generateTotalColumnWater.c \
	generatePotentialTemperature.c generateSoilTemperature2016.c generateSoilMoisture.c
	
OBJ = $(SRC:.c=.o)

TIGGE_BIN = ncdcTigge
TIGGE_SRC = $(TIGGE_BIN).c
TIGGE_OBJ = $(TIGGE_BIN).o
# TIGGE_OBJ = $(TIGGE_SRC:.c=.o)

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
# 	echo " - unpacking Pre-compiled GRIB API - "
# 	tar -xf grib-api.1-13-0-CentOS6.tar.gz -C $(TIGGE_TOOLS)
	@echo "  Linking objects..."
	@echo ""
	$(CC) $(OBJ) $(TIGGE_OBJ) $(MYLIBS) -o $(TIGGE_BIN)

ncdcTest: $(TEST_OBJ)
	$(CC) $(OBJ) $(TEST_OBJ) $(MYLIBS) $(TEST_LIBS) -o ncdcTest

dist: ncdcTigge
	cp $(TIGGE_BIN) ftpprdPullAll.pl ftpprdPull-a.pl ftpprdPull-b.pl run_ncep_convert.pl runQcOutput.pl runRecoverInput.pl runTigge.pl runUploader.pl runQcInput.pl runCheck.pl getGensTar.pl finalize.pl grib_convert_setup output-list.txt $(DIST_PREFIX)/


## compile the files
$(TIGGE_OBJ): $(OBJ)
	@echo ""
	@echo Compiling files
	$(CC) -c $(CFLAGS) $(TIGGE_SRC) $(MYINC)
	@echo ""

$(TEST_OBJ): $(OBJ)
	$(CC) -c $(CFLAGS) $(TEST_SRC) $(MYINC) $(TEST_INC)


#  base files
$(OBJ):
	$(CC) -c $(CFLAGS) $(SRC) $(MYINC)



.PHONY: clean all test dist
clean:
	rm -f ncdcTest $(TIGGE_BIN) *.o
	@echo "   -- cleaned up files --"
	@echo ""

printvars:
	@echo ""
	@echo "Influential variables:"
	@echo ""
	@echo "HOME         = $(HOME)";
	@echo "TIGGE_TOOLS  = $(TIGGE_TOOLS)";
	@echo "TIGGE_INPUT  = $(TIGGE_INPUT)";
	@echo "TIGGE_OUTPUT = $(TIGGE_OUTPUT)";
	@echo "LIBS         = $(LIBS)"
	@echo "MYLIBS       = $(MYLIBS)"
	@echo "INC          = $(INC)"
	echo "MYINC         = $(MYINC)"
	@echo "DIST_PREFIX  = $(DIST_PREFIX)";
	@echo ""

install:
# Should check for $(TIGGE_BIN) here - but could not figure syntax.
	@echo "bin is ready - Installing... "
	@echo ""
	mkdir $(TIGGE_TOOLS)/bin/
	cp $(TIGGE_BIN) $(TIGGE_TOOLS)/bin/$(TIGGE_BIN)
	cp -f ./$(TIGGE_BIN).pm $(TIGGE_TOOLS)/bin/$(TIGGE_BIN).pm
	@echo ""
	@echo " * Manual Post Install instructions *"
	@echo " * Ensure the device hosting TIGGE_TOOLS/input and /output , and/or the target of TIGGE_INPUT / TIGGE_OUTPUT has adequate space.  Create symbolic links to larger partitions if needed."
	@echo ""
	@echo ""
	@echo "Done."
	@echo ""

