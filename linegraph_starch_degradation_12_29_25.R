

# starch degradation line graph


# ----------------------------
# Inputs
# ----------------------------
norm_counts_MAG <- read.csv("normalized_counts_for_detection_edited.csv", header = TRUE)

eggnog_annot_subset <- eggnog_annot %>%
  dplyr::select(query, Description, Preferred_name, EC, KEGG_ko) %>%
  tidyr::separate_rows(EC, sep = ",") %>%
  dplyr::mutate(EC = stringr::str_trim(EC))

starch_deg_EC <- read.csv("starch_degradation_EC.csv", header = TRUE) %>%
  dplyr::mutate(EC = stringr::str_trim(EC))

# timepoint order for plotting
timepoint_order <- c("Day_1_Avg","Day_3_Avg","Day_5_Avg","Day_7_Avg","Day_14_Avg","Day_32_Avg")

# ----------------------------
# Filter to starch-degradation genes (by EC) and join to counts
# ----------------------------
eggnog_starch_deg <- eggnog_annot_subset %>%
  dplyr::filter(EC %in% starch_deg_EC$EC)

starch_deg_data <- merge(
  norm_counts_MAG,
  eggnog_starch_deg,
  by.x = "Gene",
  by.y = "query",
  all.y = TRUE
)

# ----------------------------
# Combined expression across ALL MAGs and ALL genes:
# sum across genes+MAGs within each replicate sample column
# ----------------------------
combined_rep <- starch_deg_data %>%
  dplyr::summarise(dplyr::across(starts_with("UnT_Day"), ~ sum(.x, na.rm = TRUE))) %>%
  tidyr::pivot_longer(
    cols = dplyr::everything(),
    names_to = "Sample",
    values_to = "TotalNormCount"
  ) %>%
  dplyr::mutate(
    DayNum    = stringr::str_match(Sample, "Day(\\d+)")[, 2],
    RepNum    = stringr::str_match(Sample, "rep(\\d+)")[, 2],
    Timepoint = paste0("Day_", DayNum, "_Avg")
  ) %>%
  dplyr::filter(!is.na(Timepoint))

# Mean ± SD across replicates per timepoint
combined_summary <- combined_rep %>%
  dplyr::group_by(Timepoint) %>%
  dplyr::summarise(
    TotalMean = mean(TotalNormCount, na.rm = TRUE),
    TotalSD   = sd(TotalNormCount, na.rm = TRUE),
    n_reps    = sum(!is.na(TotalNormCount)),
    .groups = "drop"
  ) %>%
  dplyr::mutate(
    Timepoint = factor(Timepoint, levels = timepoint_order),
    Log10_TotalMean = log10(TotalMean + 1),
    Log10_SD = (log10(TotalMean + TotalSD + 1) -
                  log10(pmax(TotalMean - TotalSD, 0) + 1)) / 2
  ) %>%
  dplyr::filter(!is.na(Timepoint))

# ----------------------------
# STAR overlay (wetlab data)
# ----------------------------
mydata <- read.csv("correct_wetlab_data_12_7_25.csv", header = TRUE)

star_data <- mydata %>%
  dplyr::mutate(
    Days_Ensiled = factor(
      Days_Ensiled,
      levels = c("Day_1","Day_3","Day_5","Day_7","Day_14","Day_32")
    ),
    Timepoint = factor(
      paste0(as.character(Days_Ensiled), "_Avg"),
      levels = timepoint_order
    )
  ) %>%
  dplyr::group_by(Timepoint) %>%
  dplyr::summarise(
    STAR_mean = mean(STAR, na.rm = TRUE),
    STAR_sd   = sd(STAR, na.rm = TRUE),
    n_star    = sum(!is.na(STAR)),
    .groups = "drop"
  ) %>%
  dplyr::filter(!is.na(Timepoint))



# ============================================================
# Force BOTH axes (expression + starch) to start at 0
# ============================================================

# Left axis (expression)
expr_range <- c(0, max(combined_summary$Log10_TotalMean, na.rm = TRUE))

# Right axis (starch) — force min = 0
star_max   <- max(star_data$STAR_mean + star_data$STAR_sd, na.rm = TRUE)
star_range <- c(0, star_max)

# Scaling factor between axes
star_scale <- diff(expr_range) / diff(star_range)

# Map starch values onto left axis
star_to_left <- function(s) s * star_scale   # starch = 0 -> y = 0

# ============================================================
# Plot
# ============================================================
ggplot(combined_summary,
       aes(x = Timepoint,
           y = Log10_TotalMean,
           group = 1,
           color = "Starch degrading enzyme transcription")) +
  
  # Expression (left axis)
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_errorbar(
    aes(
      ymin = pmax(Log10_TotalMean - Log10_SD, 0),
      ymax = Log10_TotalMean + Log10_SD
    ),
    width = 0.15
  ) +
  
  # STAR overlay (right axis mapped to left)
  geom_line(
    data = star_data,
    aes(
      x = Timepoint,
      y = star_to_left(STAR_mean),
      linetype = "Starch content",
      color = "Starch content",
      group = 1
    ),
    inherit.aes = FALSE,
    linewidth = 1
  ) +
  geom_point(
    data = star_data,
    aes(
      x = Timepoint,
      y = star_to_left(STAR_mean),
      shape = "Starch content",
      color = "Starch content"
    ),
    inherit.aes = FALSE,
    size = 2
  ) +
  geom_errorbar(
    data = star_data,
    aes(
      x = Timepoint,
      ymin = star_to_left(pmax(STAR_mean - STAR_sd, 0)),
      ymax = star_to_left(STAR_mean + STAR_sd),
      color = "Starch content"
    ),
    inherit.aes = FALSE,
    width = 0.15
  ) +
  
  # Axes
  scale_y_continuous(
    name = "Log10(Average Normalized Count)",
    limits = c(0, NA),
    expand = expansion(mult = c(0, 0.05)),
    sec.axis = sec_axis(
      ~ . / star_scale,
      name = "Starch (% of Dry Matter)"
    )
  ) +
  
  # Legends
  scale_color_manual(
    values = c("Starch degrading enzyme transcription" = "#009E73", "Starch content" = "black"),
    name = ""
  ) +
  scale_linetype_manual(values = c("Starch content" = 1), name = "") +
  scale_shape_manual(values = c("Starch content" = 16), name = "") +
  
  # Theme
  theme_bw() +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(face = "bold", hjust = 0.5),
    legend.position = "right"
  ) +
  
  labs(
    title = "Starch-degrading enzyme transcription and starch content over time",
    x = "Timepoint"
  )






