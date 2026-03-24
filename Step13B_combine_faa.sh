#!/bin/bash

#SBATCH --time=24:00:00				##(day-hour:minute:second) sets the max time for the job 
#SBATCH --cpus-per-task=60  			##request number of cpus 
#SBATCH --mem=100G						##max ram for the job 

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=INPUT@iastate.edu		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output="slurmlog_%j-add prefix concat annot"		##stores slurm logfile to text file called slurmlog_(assigned job number) 


#make prefix for faa files

mkdir -p faa_prefixed

for f in /work/PATH/USED_MAGs_9_22_25/prokka_annotations/prokka_faa/*.faa; do
    base=$(basename "$f" .faa)
    awk -v prefix="$base" '/^>/{print ">"prefix"_"substr($0,2); next} {print}' "$f" > faa_prefixed/"$base".pref.faa
done

#concatenate the files
cat faa_prefixed/*.pref.faa > combined_MAG_annot.faa  