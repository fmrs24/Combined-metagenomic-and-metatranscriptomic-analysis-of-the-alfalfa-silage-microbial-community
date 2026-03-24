#!/bin/bash

#SBATCH --time=24:00:00				##(day-hour:minute:second) sets the max time for the job 
#SBATCH --cpus-per-task=60  			##request number of cpus 
#SBATCH --mem=100G						##max ram for the job 

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=INPUT@iastate.edu		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output="slurmlog_%j-add prefix and make salmon index"		##stores slurm logfile to text file called slurmlog_(assigned job number) 


#make prefix for fasta  files (ffn for fasta of CDS from prokka)

mkdir -p prefixed

# prefix each fasta header with the file name 

for f in /work/PATH/USED_MAGs_9_22_25/prokka_annotations/prokka_ffn/*.ffn; do
    base=$(basename "$f" .ffn)
    awk -v prefix="$base" '/^>/{print ">"prefix"_"substr($0,2); next} {print}' "$f" > prefixed/"$base".pref.ffn
done

#concatenate the files
cat prefixed/*.pref.ffn > combined_salmon_ref.fna

module load salmon/1.10.2-gpjydps

salmon index -t combined_salmon_ref.fna -i combined_salmon_index --keepDuplicates

#quasi refers to kmer based approach - boasts nearly identical accuracy to full alignments

#--keepduplicates - normally, salmon removes identical seuences in the transcriptome  (same sequences figgerent header)
#important to keep for metagenomes where different MAGs might have identical CDS sequences
#without it, salmon could merge identical sequences from different MAGs

#salmon git: https://github.com/COMBINE-lab/salmon