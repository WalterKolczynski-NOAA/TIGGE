#! /bin/env python3

import datetime
import os
import subprocess
from functools import partial
import argparse
import contextlib

# Make sure print statements are flushed immediately, otherwise
#   print statments may be out-of-order with subprocess output
print = partial(print, flush=True)

hpss_pgrb2a_pattern = '/NCEPPROD/hpssprod/runhistory/rh%Y/%Y%m/%Y%m%d/com_gens_prod_gefs.%Y%m%d_%H.pgrb2a.tar'
hpss_pgrb2b_pattern = '/NCEPPROD/2year/hpssprod/runhistory/rh%Y/%Y%m/%Y%m%d/com_gens_prod_gefs.%Y%m%d_%H.pgrb2b.tar'
htar_command = 'htar -xvf {file}'

destination_pattern = '{com}/gefs.%Y%m%d/%H'


def main():
	parser = argparse.ArgumentParser(description="Pulls 1.0 deg GEFS products from HPSS for TIGGE")
	parser.add_argument('time', type=lambda s: datetime.datetime.strptime(s, "%Y%m%d%H"), help="Cycle date in YYYYMMDDHH format")

	time = parser.parse_args().time

	com = os.environ.get('GEFS_COM')
	if com is None:
		print(f"FATAL ERROR in {__file__}: GEFS_COM is not defined!")
		quit(100)

	destination = time.strftime(destination_pattern.format(com=com))

	with contextlib.suppress(FileExistsError):
		os.makedirs(destination)

	os.chdir(destination)

	subprocess.check_call(htar_command.format(file=time.strftime(hpss_pgrb2a_pattern)), shell=True)
	subprocess.check_call(htar_command.format(file=time.strftime(hpss_pgrb2b_pattern)), shell=True)

	print(f"{__file__} completed successfully")


if __name__ == "__main__":
	main()
