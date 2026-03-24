Workflow:

Phase 1 - Preprocessing of metatranscriptomic data
Phase 2 - Preprocessing metagenomic data and generating metagenome assembled genomes (MAGs)
Phase 3 - Mapping transcripts to MAGs
Phase 4 - Data analysis and visualization in R


#################################################

Phase 1 - Preprocessing of metatranscriptomic data

Step 1 - Initial quality check - Run: Step_1_RunFastqc.sh

Step 2 - Quality filtering and adapter removal - Run: Step_2_bbduk_2_21_2025.sh
	NOTE: for this scipt to work, make sure you have the file "bbduk_adapters.fasta" in the same folder

Step 3 - Remove alfalfa and human contaminating reads - Run: Step3A_remove_alfalfa.sh & Step3B_remove_human.sh
	NOTE: for this script to work, make sure you provide reference genomes in a fasta format

Step 4 - Remove rRNA sequences using SortmeRNA - Run: Step_4_SortmeRNA.sh
	NOTE: for this script to work, you must download and then index available SortmeRNA databases: 	https://github.com/sortmerna/sortmerna/releases/

#################################################

Phase 2 - Preprocessing metagenomic data and generating metagenome assembled genomes (MAGs)

Step 5 - Initial quality check - Run: Step_5_RunFastqc.sh

Step 6 - Quality filtering and adapter removal - Run: Step6_bbduk_paired_end_2_28_2025.sh
	NOTE: for this scipt to work, make sure you have the file "bbduk_adapters.fasta" in the same folder

Step 7 - Remove alfalfa and human contaminating reads - Run: Step7A_bbmap_remove_alfalfa_3_4_25.sh & Step7B_bbmap_remove_human_3_5_25.sh
	NOTE: for this script to work, make sure you provide reference genomes in a fasta format

Step 8 - Assembling into contigs using MEGAHIT - Run:Step_8_MEGAHIT_denovo_coassembly_3_6_25.sh

Step 9 - Calculating read depth per contig - Run: Step_9_read_depth_per_contig_bbmap_3_10_25.sh

Step 10 - Binning contigs (metabat1) and checking quality (CheckM) - Run: Step_10_metabat_binning_checkm_3_11_25.sh

Step 11 - Removal of low quality and duplicate bins (dRep) - Run: Step_11_dRep_70_25_from_metabat_1500_9_3_25.sh

Step 12 - Annotate with Prokka - Run: Step_12_prokka_on_MAGs.sh

#################################################

Phase 3 - Mapping transcripts to MAGs

Step 13 - Preparing combined Salmon reference from the coding sequences (from prokka) of the MAGs - Run: 	Step13A_append_prefix_make_salmon_index_script.sh
	Step13B_combine_faa.sh
	Step13C_prep_salmon_ref.sh

Step 14 - Running Salmon for transcription estimates per MAG coding sequence - Run: Step_14_run_salmon.sh

#################################################

Phase 4 - Data analysis and visualization in R

Primary analysis: MAG_Dependent_Transcriptome_10_1_25.Rmd

Accessory scripts:
FINAL_PCA_12_8_25.R -> PCA plot with vectors
linegraph_starch_degradation_12_29_25.R -> example of script to make line graphs



