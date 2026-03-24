#!/bin/bash

#SBATCH --time=64:00:00					##(day-hour:minute:second) sets the max time for the job 
#SBATCH --cpus-per-task=200  			##request number of cpus 
#SBATCH --mem=200G						##max ram for the job 

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=INPUT@iastate.edu		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="slurmlog_%j-drep 70 25"		##stores slurm logfile to text file called slurmlog_(assigned job number) 

module load py-drep/3.4.2-py310-openmpi4-hrctjeq

module load py-checkm-genome/1.2.1-py310-openmpi4-237ifjc


########Prep work! #########
	#make a filtered down sheet (see example) with only the bin names (including .fa file extension!), completeness, and contamination as the three columns from your checkM output
    #this quality information will be used by dRepPrefill for use in its screening
    #Info here: https://drep.readthedocs.io/en/latest/advanced_use.html "Using external genome quality information"

########Step 1: Run dRep to dereplicate your bins (both tested min contig sizes)########
dRep dereplicate --completeness 70 --contamination 25 minlen1500_with_read_depth_drep_70-25 -p 200 -g metabat2_1500_with_read_depth/*.fa --genomeInfo CheckmOut_1500_dRep.csv

##Syntax notes
    #Base command: dRep dereplicate outout_directory -g path/to/genomes/*.fasta
    #GENOME FILTERING OPTIONS:
    #-l LENGTH, --length LENGTH  Minimum genome length (default: 50000)
    #-comp COMPLETENESS, --completeness COMPLETENESS  Minumum genome completeness (default: 75)
    #-con CONTAMINATION, --contamination CONTAMINATION  Maximum genome contamination (default: 25)
    #--genomeInfo = path to dRepCheckMPrefillSheet generated as indicated at top of this script
    #-g indicates the location of your genomes/bins
    
    ##Notes: dRep actually has checkM built in, so theoretically doing them separately is unnecessary- however on Pronto the implementation of checkM within dRep wasn't working for me so I did them separately and used the precalculated completeness/contamination method
#Manual: https://drep.readthedocs.io/en/latest/  https://drep.readthedocs.io/en/latest/module_descriptions.html 
