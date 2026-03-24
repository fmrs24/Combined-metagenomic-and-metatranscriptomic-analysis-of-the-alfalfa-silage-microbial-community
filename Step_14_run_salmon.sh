#!/bin/bash

#SBATCH --time=7-00:00:00				##(day-hour:minute:second) sets the max time for the job 
#SBATCH --cpus-per-task=150  			##request number of cpus 
#SBATCH --mem=250G						##max ram for the job 

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=INPUT@iastate.edu		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output="slurmlog_%j-run salmon"		##stores slurm logfile to text file called slurmlog_(assigned job number) 

module load salmon/1.10.2-gpjydps

for fq in *.fastq; do
    sample=$(basename "$fq" .fastq)
    salmon quant -i /work/PATH/USED_MAGs_9_22_25/combined_salmon_index \
                 -l A \
                 -r "$fq" \
                 -p 150 \
                 -o "../salmon_quant/$sample"
done
