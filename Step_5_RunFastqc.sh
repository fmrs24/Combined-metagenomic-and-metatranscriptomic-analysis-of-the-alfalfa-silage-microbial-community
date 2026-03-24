#!/bin/bash
# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename
# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=30   # 8 processor core(s) per node
#SBATCH --mem=50G   # maximum memory per node
#SBATCH --mail-user=INPUT@iastate.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --output="sb%j- Metagenome 2025 FASTQC raw data run "
module load fastqc
fastqc --extract ../DIRECTORY/*.gz