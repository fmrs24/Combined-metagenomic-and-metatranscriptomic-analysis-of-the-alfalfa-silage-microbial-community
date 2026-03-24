#!/bin/bash

#SBATCH --time=300:00:00				##(day-hour:minute:second) sets the max time for the job 
#SBATCH --cpus-per-task=62  			##request number of cpus 
#SBATCH --mem=200G						##max ram for the job 

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=INPUT@iastate.edu		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="slurmlog_%j-SortMeRNA"		##stores slurm logfile to text file called slurmlog_(assigned job number) 

module load sortmerna/2017-07-13-xcwrsx3

#github: https://github.com/sortmerna/sortmerna/releases/

#index the database
#indexdb --ref /work/sse/Faith/sortmeRNA_db/smr_v4.3_default_db.fasta,/work/sse/Faith/sortmeRNA_db/smr_v4.3_default_db

DB_FASTA="/work/sse/Faith/sortmeRNA_db/smr_v4.3_default_db.fasta"
DB_PREFIX="/work/sse/Faith/sortmeRNA_db/smr_v4.3_default_db"

for INPUT_FASTQ in *__unmapped_unmapped.fastq; do
    echo "Processing $INPUT_FASTQ"

    OUT_PREFIX="${INPUT_FASTQ%.fastq}"

    sortmerna \
      --ref "${DB_FASTA},${DB_PREFIX}" \
      --reads "$INPUT_FASTQ" \
      --fastx \
      --aligned "${OUT_PREFIX}_rRNA.fastq" \
      --other "${OUT_PREFIX}_non_rRNA.fastq" \
      --log \
      -a 62

    echo "Finished processing $INPUT_FASTQ"
done

echo "All files processed."