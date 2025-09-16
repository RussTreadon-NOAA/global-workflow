#!/usr/bin/env python3

"""
This script is a Python conversion of the provided bash script.
It performs the following actions:
1.  Changes to the rotation directory ($ROTDIR).
2.  Extracts various GFS analysis and restart files from HPSS using htar.
3.  Calculates a previous cycle's date to extract older GDAS restart files.
4.  Creates log files to signify completion of steps.
5.  Exits with a non-zero status code if any command fails.
"""

import os
import sys
import subprocess
from datetime import datetime, timedelta

def get_env_variable(var_name):
    """
    Fetches an environment variable. Exits with an error if it's not set.
    """
    value = os.getenv(var_name)
    if value is None:
        print(f"Error: Environment variable '{var_name}' is not set.", file=sys.stderr)
        sys.exit(1)
    return value

def run_command(command):
    """
    Runs a command using subprocess. Exits if the command fails.
    """
    try:
        # Using subprocess.run is the modern and recommended approach
        result = subprocess.run(command, check=False) # check=False to handle exit code manually
        if result.returncode != 0:
            print(f"Error: Command failed with exit code {result.returncode}", file=sys.stderr)
            sys.exit(result.returncode)
    except FileNotFoundError:
        print(f"Error: Command not found: '{command[0]}'", file=sys.stderr)
        sys.exit(127)
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    """
    Main function to execute the script logic.
    """
    # --- Setup and Environment Variables ---
    rot_dir = get_env_variable('ROTDIR')
    hpss_project = get_env_variable('HPSS_PROJECT')
    user = get_env_variable('USER')
    machine = get_env_variable('machine')
    pdy = get_env_variable('PDY')
    cyc = get_env_variable('cyc')
    assim_freq = get_env_variable('assim_freq')

    # Change to the rotation directory
    try:
        os.chdir(rot_dir)
    except FileNotFoundError:
        print(f"Error: Rotation directory not found: '{rot_dir}'", file=sys.stderr)
        sys.exit(1)

    htar_base_command = ["/apps/hpss/htar", "-T", "4"]

    # --- File Extraction Logic ---

    # Extract gfs sfcanl tiles
    gfs_restarta_path = f"/NCEPDEV/{hpss_project}/1year/{user}/{machine}/scratch/gsi_test/{pdy}{cyc}/gfs_restarta.tar"
    run_command(htar_base_command + ["-xvf", gfs_restarta_path])

    # Extract gfs atminc.
    gfs_netcdfa_path = f"/NCEPDEV/{hpss_project}/1year/{user}/{machine}/scratch/gsi_test/{pdy}{cyc}/gfs_netcdfa.tar"
    run_command(htar_base_command + ["-xvf", gfs_netcdfa_path])

    # Create loganl for atmanlupp
    loganl_path = os.path.join(f"gfs.{pdy}", cyc, "analysis", "atmos", f"gfs.t{cyc}z.loganl.txt")
    os.makedirs(os.path.dirname(loganl_path), exist_ok=True)
    with open(loganl_path, "w") as f:
        f.write(f"gfs {pdy}{cyc} atmanl and sfcanl done\n")

    # Extract gsistat and minmon
    gfsa_tar_path = f"/NCEPDEV/{hpss_project}/1year/{user}/{machine}/scratch/gsi_test/{pdy}{cyc}/gfsa.tar"
    gsistat_member = f"gfs.{pdy}/{cyc}/analysis/atmos/gfs.t{cyc}z.gsistat"
    minmon_member = f"gfs.{pdy}/{cyc}/products/atmos/minmon"
    
    run_command(htar_base_command + ["-xvf", gfsa_tar_path, gsistat_member])
    run_command(htar_base_command + ["-xvf", gfsa_tar_path, minmon_member])

    # Extract ioda format conventional ps dump
    gdas_tar_path = f"/NCEPDEV/{hpss_project}/1year/{user}/{machine}/scratch/gsi_test/{pdy}{cyc}/gdas.tar"
    conventional_ps_member = f"gdas.{pdy}/{cyc}/obs/gdas.t{cyc}z.conventional_ps.tm00.nc"
    run_command(htar_base_command + ["-xvf", gdas_tar_path, conventional_ps_member])

    # --- Previous Cycle Calculation and Extraction ---
    
    # Calculate the date and cycle for the previous run
    try:
        start_datetime = datetime.strptime(f"{pdy}{cyc}", "%Y%m%d%H")
        assim_hours = int(assim_freq)
        gdate_datetime = start_datetime - timedelta(hours=assim_hours)
        gdate_str = gdate_datetime.strftime("%Y%m%d%H")
        gpdy = gdate_str[:8]
        gcyc = gdate_str[8:]
    except (ValueError, TypeError) as e:
        print(f"Error during date calculation: {e}", file=sys.stderr)
        sys.exit(1)

    # Extract gdas restart from the previous cycle
    gdas_restartb_path = f"/NCEPDEV/{hpss_project}/1year/{user}/{machine}/scratch/gsi_test/{gpdy}{gcyc}/gdas_restartb.tar"
    run_command(htar_base_command + ["-xvf", gdas_restartb_path])
    
    # --- Finalization ---

    # Create final log file
    final_log_path = os.path.join(rot_dir, f"gfs.{pdy}", cyc, "analysis", "atmos", f"gfs.t{cyc}z.atmanlfinal.f000.txt")
    os.makedirs(os.path.dirname(final_log_path), exist_ok=True)
    with open(final_log_path, "w") as f:
        f.write(f"stage_ic_nudge done for {pdy}{cyc}\n")
    
    print("################################################################################")
    print("Script finished successfully.")
    sys.exit(0)

if __name__ == "__main__":
    main()

