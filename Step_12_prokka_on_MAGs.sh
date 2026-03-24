#!/bin/bash

#SBATCH --time=14-00:00:00				##(day-hour:minute:second) sets the max time for the job 
#SBATCH --cpus-per-task=150  			##request number of cpus 
#SBATCH --mem=200G						##max ram for the job 

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=INPUT@iastate.edu		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output="slurmlog_%j-prokka-MAGs"		##stores slurm logfile to text file called slurmlog_(assigned job number) 


module load prokka/1.14.5

############################################

#establishing working directory
INPUT_DIR="/work/PATH/USED_MAGs_9_22_25"
OUTPUT_DIR="${INPUT_DIR}/prokka_annotations"

mkdir -p $OUTPUT_DIR

# Loop through all genome fasta files that need annotated
for genome in ${INPUT_DIR}/*.fasta; do
    # Get basename without extension
    base=$(basename "$genome" .fasta)
    
    # Run prokka
    prokka --cpus $SLURM_CPUS_PER_TASK \
           --outdir ${OUTPUT_DIR}/${base} \
           --prefix ${base} \
           $genome
done

prokka -v