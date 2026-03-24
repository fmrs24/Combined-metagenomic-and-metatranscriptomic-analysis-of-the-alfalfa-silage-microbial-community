 
install.packages("remotes")
install.packages("tidyverse")
install.packages("ggrepel")
install.packages("caret")
install.packages("viridis")
install.packages("grid")
install.packages("vegan")
# Windows users will also need to have RTools installed! http://jtleek.com/modules/01_DataScientistToolbox/02_10_rtools/

# To install the latest version:
remotes::install_github("david-barnett/microViz")
remotes::install_github("joey711/phyloseq")

#microviz github: https://github.com/david-barnett/microViz

library(phyloseq)
library(microViz)
library(DESeq2)
library(vegan)
library(ggplot2)
library(dplyr)
library(grid) 
library(tidyverse) 
library(ggrepel) 
library(caret) 
library(viridis)
library(grid) 


set.seed(941996)

# run this after running this script: Untreated_Only_MAG_Dependent_Transcriptome_10_1_25.Rmd

# Additionally, Figure 2 of this paper is what inspired this plot:
#https://doi.org/10.1016/j.soilbio.2023.108994

#here is the link to the code that they used 
#https://github.com/KatjaKo/captured-metatrans/blob/main/code/overall_overview.Rmd



################################################################################

#Preparing deseq2 data for use in PCA

# vst = DESeq2 function for variance stabilizing transformation. Normalizes the count data and stabilizes the variance across different levels  of gene expression
# vst is used to compare samples or gene patterns between samples; used for clustering, PCA, heatmaps
# We set blind = FALSE (see vigette: https://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html)

vst_data <- vst( dds_analyzed, blind = FALSE)

#extract matrix
vst_mat <- assay(vst_data)

#remove genes with 0 variance (sd = 0) (PCA cannot handle these)
  #literally just removed butyrate column
vst_mat <- vst_mat[apply(vst_mat, 1, sd) != 0, ]

################################################################################

#Preparing the wetlab data

wetlab <- read.csv("correct_wetlab_data_12_7_25.csv", header = TRUE)

#set the sample_ids as rownames
###rownames(wetlab) <- wetlab$sample

#remove column
###wetlab$sample <- NULL

#remove all factors or character columns
wetlab$Sm.Silo.No. <- NULL
wetlab$Sample.Description <- NULL
wetlab$No. <- NULL
wetlab$Trt <- NULL
wetlab$MRS..LAB. <- NULL
wetlab$PDA..Mold. <- NULL
wetlab$PDA..Yeast. <- NULL

#remove 
wetlab$IVDMD <- NULL
wetlab$IVTD30 <- NULL
wetlab$DIG8H <- NULL
wetlab$NFC <- NULL
wetlab$RFC <- NULL
wetlab$RDC <- NULL
wetlab$CAL <- NULL
wetlab$ANE <- NULL
wetlab$NEL <- NULL
wetlab$RFV <- NULL
wetlab$RFQ <- NULL

#note, SUGAR is perfectly co-linear with glucose
wetlab$SUGAR <- NULL

################################################################################
############################# Generate PCA #####################################
################################################################################

#switch to samples as rows and run pca
pca <- prcomp(t(vst_mat), scale. = TRUE)

#make a dataframe that contains the pca scores
scores <- as.data.frame(pca$x[, 1:2])
scores$sample <- rownames(scores)

#combine with the wetlab data
pca_df <- merge(scores, wetlab, by = "sample")

#remove non-numeric columns (sample ID + Days)
env_vars <- wetlab[, !(names(wetlab) %in% c("sample", "Days_Ensiled"))]

#run envfit
ef <- envfit(pca, env_vars, permutations = 9999, scaling = 1)

#extract arrows and associated statistics
ef_arrows <- as.data.frame(ef$vectors$arrows[, 1:2])
colnames(ef_arrows) <- c("x", "y")
ef_arrows$var  <- rownames(ef_arrows)
ef_arrows$r2   <- ef$vectors$r
ef_arrows$pval <- ef$vectors$pvals

#only keep significant variables
sig_arrows <- ef_arrows[ef_arrows$pval < 0.05, ]

#select the TOP 10 strongest arrows by r2
sig_top10 <- sig_arrows[order(-sig_arrows$r2), ][1:10, ]

################################################################################
########################### SCALE THE ARROWS ###################################
################################################################################

# PCA ranges
pc_range  <- apply(pca$x[, 1:2], 2, range)
axis_span <- min(diff(pc_range))

# Maximum arrow length among the top 10
arrow_len <- sqrt(sig_top10$x^2 + sig_top10$y^2)
max_arrow <- max(arrow_len)

# Target arrow length = 30% of PCA axis range
#ADJUST TO MAKE BIGGER
target_fraction <- 0.30
scale_factor <- target_fraction * axis_span / max_arrow
scale_factor

#scale the arrows
sig_top10_scaled <- sig_top10
sig_top10_scaled$x <- sig_top10$x * scale_factor
sig_top10_scaled$y <- sig_top10$y * scale_factor

################################################################################
########################### MAKE PCA SCATTERPLOT ###############################
################################################################################

#order Days_Ensiled correctly
pca_df$Days_Ensiled <- factor(
  pca_df$Days_Ensiled,
  levels = c("Day_1", "Day_3", "Day_5", "Day_7", "Day_14", "Day_32")
)


my_colors <- c(
  "Day_1"  = "#C26A77", 
  "Day_3"  = "#D55E00",  
  "Day_5"  = "#F0E442",  
  "Day_7"  = "#94CBEC",  
  "Day_14" = "#0072B2",  
  "Day_32" = "#009E73"
)

gg_pca <- ggplot(pca_df, aes(PC1, PC2)) +
  geom_point(aes(fill = Days_Ensiled), 
             size = 4, alpha = 0.9, shape = 21, color = "black") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey70") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey70") +
  xlab(paste0("PC1 (", round(summary(pca)$importance[2,1] * 100, 2), "%)")) +
  ylab(paste0("PC2 (", round(summary(pca)$importance[2,2] * 100, 2), "%)")) +
  scale_fill_manual(values = my_colors) +
  theme_bw(base_size = 14) +
  theme(
    panel.grid   = element_blank(),
    axis.text    = element_text(size = 12),
    axis.title   = element_text(size = 14),
    legend.title = element_text(size = 12),
    legend.text  = element_text(size = 10)
  )


gg_pca

################################################################################
############################## ADD THE ARROWS ##################################
################################################################################

gg_biplot <- gg_pca +
  geom_segment(
    data = sig_top10_scaled,
    aes(x = 0, y = 0, xend = x, yend = y),
    inherit.aes = FALSE,
    arrow = arrow(length = unit(0.25, "cm")),
    size = 0.6,
    color = "black"
  ) +
  geom_label_repel(
    data = sig_top10_scaled,
    aes(x = x, y = y, label = var),
    inherit.aes = FALSE,
    size = 4,
    fill = "white",
    box.padding = 0.2,
    segment.color = "gray40"
  )

gg_biplot


################################################################

#as we can see, the arrows need scaled

#Envfit arrows are:
  
  #unit-length correlation vectors, scaled to fit the PCA space

  #typically between –1 and +1

  #almost always tiny relative to PCA scores

  #So their raw length does not represent biological magnitude.



#The statistical interpretation of envfit arrows comes from:
  
  #direction → correlated with PCA axes

#relative length → strength of correlation (already encoded in r²)

#significance → p-values

#None of these depend on graphic size.




