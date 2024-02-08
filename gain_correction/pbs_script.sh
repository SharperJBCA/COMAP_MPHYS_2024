#!/bin/bash
#PBS -N name_of_job
#PBS -o outputfile.log
#PBS -e errorfile.err
#PBS -l walltime=24:00:00
#PBS -l nodes=2:ppn=32
#PBS -m e
#PBS -M <email_address>  

# Change to the directory from which the job was submitted
cd $PBS_O_WORKDIR

# Load any required modules python and openmpi
module load anaconda-python365 
module load openmpi-1.10.4-withtm
module load gcc-9.3.0

echo "" > test.log
source ../venv-fornax/bin/activate >> test.log
echo "Running on $(hostname)" >> test.log 

filelist=/path/to/filelist/containing/files/to/process
prefix=name_for_job
source=preset_coordinates # galactic
iband=0 # bands available 0 = 27GHz, 1 = 29GHz, 2 = 31GHz, 3 = 33GHz
tod_dset=tod # tod with gain correction = tod; tod without gain correction = tod_original 

# Some MPI related calculations 
# Count the number of lines in the filelist
num_files=$(wc -l < "$filelist")

# Determine the number of processes to launch
num_processes=$((num_files > 32 ? 32 : num_files))

echo "Launching $num_processes processes." >> test.log

# Launch map-making code 
mpirun -n $num_processes --map-by ppr:16:node python read_comap_tod.py $filelist $source $prefix $iband $tod_dset
