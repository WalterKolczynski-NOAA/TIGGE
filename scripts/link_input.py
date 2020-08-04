#! /bin/env python3

import datetime
import os
import subprocess
import typing
import shutil
from functools import partial
from pathlib import Path
import argparse

# Make sure print statements are flushed immediately, otherwise
#   print statments may be out-of-order with subprocess output
print = partial(print, flush=True)

cycle_frequency = 6
n_members = 21
forecast_hours = range(0, 385, 6)

source_pattern = '{source_dir}/gefs.%Y%m%d/%H/pgrb2{grib_type}'
filepattern = '{directory}/ge{member}.t%Hz.pgrb2{grib_type}f{forecast_hour:02d}'

members = list(map(lambda m: f'c{m:02d}' if (m == 0) else f'p{m:02d}', range(0, n_members)))


def main():
	parser = argparse.ArgumentParser(description="Creates symbolic links to 1.0 deg GEFS products for TIGGE")
	parser.add_argument('time', type=lambda s: datetime.datetime.strptime(s, "%Y%m%d%H"), help="Cycle date in YYYYMMDDHH format")

	time = parser.parse_args().time

	input_dir = os.environ.get('TIGGE_INPUT')
	if(input_dir is None):
		input_dir = str(Path(__file__).parent.parent) + "/input"

	source_dir = os.environ.get('GEFS_COM')
	if(source_dir is None):
		source_dir = subprocess.getoutput('compath.py gens/prod')

	print(time.strftime(f'Checking %Y%m%d_%H'))
	destination_dir = time.strftime(f'{input_dir}/%Y%m%d%H')
	source_filelist = get_source_filenames(source_dir, time)
	link_filelist = get_link_filenames(destination_dir, time)

	if all([os.path.islink(f) for f in link_filelist]):
		if all([os.path.isfile(f) for f in link_filelist]):
			print('  Links already completed for this time')
		else:
			print('  Data no longer exists, removing old directory')
			shutil.rmtree(destination_dir)

	elif any([not os.path.isfile(f) for f in source_filelist]):
		print("  Files don't exist for this time")
		for f2 in source_filelist:
			print(f'{f2}: {os.path.isfile(f2)}')
		quit(100)

	else:
		print("  Creating links...")
		os.makedirs(destination_dir, exist_ok=True)

		for f in source_filelist:
			os.symlink(f, f'{destination_dir}/{os.path.basename(f)}')

	exit(0)


def get_link_filenames(directory: str, when: datetime) -> typing.List[str]:
	files = [when.strftime(filepattern.format(directory=directory, grib_type=grib_type, member=member, forecast_hour=forecast_hour))
		for grib_type in ['a', 'b']
		for member in members
		for forecast_hour in forecast_hours]
	return files


def get_source_filenames(source_dir: str, when: datetime) -> typing.List[str]:
	files = [when.strftime(filepattern.format(directory=when.strftime(source_pattern.format(source_dir=source_dir, grib_type=grib_type)), grib_type=grib_type, member=member, forecast_hour=forecast_hour))
		for grib_type in ['a', 'b']
		for member in members
		for forecast_hour in forecast_hours]
	return files


if __name__ == "__main__":
	main()
