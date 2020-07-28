#! /bin/env python3

import datetime
import os
import subprocess
import typing
import shutil
from functools import partial

# Make sure print statements are flushed immediately, otherwise
#   print statments may be out-of-order with subprocess output
print = partial(print, flush=True)

cycle_frequency = 6
max_iterations = 100
n_members = 21
forecast_hours = range(0, 385, 6)

input_dir = os.environ['TIGGE_INPUT']
source_dir = subprocess.getoutput('compath.py gens/prod')
source_pgrb2_dict = {'a': f"{source_dir}/gefs.%Y%m%d/%H/pgrb2a", 'b': f"{source_dir}/gefs.%Y%m%d/%H/pgrb2b"}
filepattern = '{directory}/ge{member}.t%Hz.pgrb2{grib_type}f{forecast_hour:02d}'

# Stop looking backwards after this many cycles don't have data
# This value be at least 2 to account for the current run not having completed
max_failures = 3

members = list(map(lambda m: f'c{m:02d}' if (m == 0) else f'p{m:02d}', range(0, n_members)))


def main():
	now = datetime.datetime.utcnow()
	last_cycle = now.hour - (now.hour % cycle_frequency)
	current_run = now.replace(hour=last_cycle, minute=0, second=0, microsecond=0)

	print(now.strftime(f'Now: %Y%m%d_%H:%M:%S'))
	print(current_run.strftime(f'Most recent cycle: %Y%m%d_%H:%M:%S'))

	failures = 0
	iterations = 0

	while failures < max_failures and iterations < max_iterations:
		print(current_run.strftime(f'Checking %Y%m%d_%H'))
		destination_dir = current_run.strftime(f'{input_dir}/%Y%m%d%H')
		source_filelist = get_source_filenames(current_run)
		link_filelist = get_link_filenames(destination_dir, current_run)

		if all([os.path.islink(f) for f in link_filelist]):
			if all([os.path.isfile(f) for f in link_filelist]):
				print('  Links already completed for this time')
			else:
				print('  Data no longer exists, removing old directory')
				shutil.rmtree(destination_dir)

		elif any([not os.path.isfile(f) for f in source_filelist]):
			print("  Files don't exist for this time")
			failures += 1

		else:
			print("  Creating links...")
			os.makedirs(destination_dir, exist_ok=True)

			for f in source_filelist:
				os.symlink(f, f'{destination_dir}/{os.path.basename(f)}')

		current_run = current_run - datetime.timedelta(hours=6)
		iterations += 1

	print("Maximum failures reached, ending")

	exit(0)


def get_link_filenames(directory: str, when: datetime) -> typing.List[str]:
	files = [when.strftime(filepattern.format(directory=directory, grib_type=grib_type, member=member, forecast_hour=forecast_hour))
		for grib_type in ['a', 'b']
		for member in members
		for forecast_hour in forecast_hours]
	return files


def get_source_filenames(when: datetime) ->  typing.List[str]:
	files = [when.strftime(filepattern.format(directory=when.strftime(source_pgrb2_dict[grib_type]), grib_type=grib_type, member=member, forecast_hour=forecast_hour))
		for grib_type in ['a', 'b']
		for member in members
		for forecast_hour in forecast_hours]
	return files


if __name__ == "__main__":
	main()
