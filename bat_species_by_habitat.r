#!/usr/bin/env Rscript

# bat_species_by_habitat.r
#
# Purpose: Read two bat measurement files (AG and FOREST), count
# occurrences per species, normalize for unequal sampling effort,
# compute per-species percent occurrence in each habitat (adds to 100%),
# and plot a horizontal stacked bar chart (each species = 100%).
#
# Usage:
#   Rscript bat_species_by_habitat.r path_to_AG.csv path_to_FOREST.xlsx
#
# Dependencies: dplyr, tidyr, ggplot2, readxl

## -----------------------------
## Helpers and argument parsing
## -----------------------------
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  cat("Error: please provide two input files: AG and FOREST\n")
  cat("Usage: Rscript bat_species_by_habitat.r data_AG.csv data_FOREST.xlsx\n")
  quit(status = 1)
}

file_AG <- args[1]
file_FOREST <- args[2]

# Load required packages (stop with informative message if missing)
required <- c("dplyr", "tidyr", "ggplot2", "readxl")
missing_pkgs <- required[!(required %in% installed.packages()[, "Package"]) ]
if (length(missing_pkgs) > 0) {
  stop(paste0("Missing required packages: ", paste(missing_pkgs, collapse = ", "),
              ". Please install them, e.g. install.packages(\"dplyr\")"))
}

library(dplyr)
library(tidyr)
library(ggplot2)
library(readxl)


## -----------------------------
## Robust readers for CSV/XLSX
## -----------------------------
read_table_file <- function(path) {
  # Read CSV (by extension .csv) or first sheet of xlsx
  ext <- tools::file_ext(path)
  if (tolower(ext) %in% c("csv")) {
    # use base read.csv for minimal dependencies
    df <- tryCatch(
      read.csv(path, stringsAsFactors = FALSE, check.names = FALSE),
      error = function(e) stop("Failed to read CSV: ", e$message)
    )
  } else if (tolower(ext) %in% c("xls", "xlsx")) {
    df <- tryCatch(
      read_excel(path),
      error = function(e) stop("Failed to read Excel: ", e$message)
    )
    # read_excel returns tibble; convert to data.frame for consistent behavior
    df <- as.data.frame(df, stringsAsFactors = FALSE)
  } else {
    stop("Unsupported file extension for ", path, ". Use .csv or .xlsx/.xls")
  }
  return(df)
}


## -----------------------------
## Read inputs
## -----------------------------
cat("Reading AG file:", file_AG, "\n")
cat("Reading FOREST file:", file_FOREST, "\n")
if (!file.exists(file_AG)) stop("AG input file does not exist: ", file_AG)
if (!file.exists(file_FOREST)) stop("FOREST input file does not exist: ", file_FOREST)

df_AG <- read_table_file(file_AG)
df_FOREST <- read_table_file(file_FOREST)

# Check for ID column
if (!("ID" %in% colnames(df_AG))) stop("AG file must contain column named 'ID'")
if (!("ID" %in% colnames(df_FOREST))) stop("FOREST file must contain column named 'ID'")


## -----------------------------
## Count occurrences per species
## -----------------------------
# Each row is one measurement. Count rows per species (ID)
count_AG <- df_AG %>%
  group_by(ID) %>%
  summarise(Count_AG = n(), .groups = "drop")

count_FOREST <- df_FOREST %>%
  group_by(ID) %>%
  summarise(Count_FOREST = n(), .groups = "drop")

# Full join so species present only in one habitat still appear
counts <- full_join(count_AG, count_FOREST, by = "ID") %>%
  replace_na(list(Count_AG = 0, Count_FOREST = 0)) %>%
  rename(Species = ID)


## -----------------------------
## Sampling effort and normalization
## -----------------------------
total_measurements_AG <- sum(counts$Count_AG)
total_measurements_FOREST <- sum(counts$Count_FOREST)

cat(sprintf("Total measurements - AG: %d, FOREST: %d\n",
            total_measurements_AG, total_measurements_FOREST))

# Avoid division by zero: if total is zero, set proportions to 0 (no data)
counts <- counts %>%
  mutate(
    Prop_AG = ifelse(total_measurements_AG > 0, Count_AG / total_measurements_AG, 0),
    Prop_FOREST = ifelse(total_measurements_FOREST > 0, Count_FOREST / total_measurements_FOREST, 0)
  )


## -----------------------------
## Per-species relative occurrence (sums to 100% per species)
## -----------------------------
counts <- counts %>%
  mutate(
    PropSum = Prop_AG + Prop_FOREST,
    Perc_in_AG = ifelse(PropSum > 0, (Prop_AG / PropSum) * 100, NA_real_),
    Perc_in_FOREST = ifelse(PropSum > 0, (Prop_FOREST / PropSum) * 100, NA_real_)
  )


## -----------------------------
## Print intermediate table
## -----------------------------
output_table <- counts %>%
  select(Species, Count_AG, Count_FOREST) %>%
  mutate(
    total_measurements_AG = total_measurements_AG,
    total_measurements_FOREST = total_measurements_FOREST
  ) %>%
  bind_cols(counts %>% select(Prop_AG, Prop_FOREST, Perc_in_AG, Perc_in_FOREST))

cat("\nIntermediate results:\n")
print(output_table)


## -----------------------------
## Plot: horizontal stacked bar (each species = 100%)
## -----------------------------
# Prepare long format where each species has two rows (AG, FOREST) summing to 100
plot_df <- counts %>%
  select(Species, Perc_in_AG, Perc_in_FOREST) %>%
  pivot_longer(cols = starts_with("Perc_in_"),
               names_to = "Habitat",
               values_to = "Percent") %>%
  mutate(Habitat = recode(Habitat,
                          Perc_in_AG = "AG",
                          Perc_in_FOREST = "FOREST")) %>%
  # drop species with no data in either habitat
  filter(!is.na(Percent))

# Order species by % in AG descending for plotting
species_order <- counts %>% arrange(desc(Perc_in_AG)) %>% pull(Species)
plot_df$Species <- factor(plot_df$Species, levels = species_order)

# Colors (paper-friendly palette requested)
cols <- c("AG" = "#0072B2", "FOREST" = "#D55E00")

# Create plot matching requested academic style
plt <- ggplot(plot_df, aes(x = Species, y = Percent, fill = Habitat)) +
  geom_bar(stat = "identity", width = 0.7) +
  coord_flip() +
  scale_y_continuous(labels = scales::percent_format(scale = 1), expand = c(0, 0), limits = c(0, 105)) +
  scale_fill_manual(values = cols) +
  labs(title = "Brazil", x = NULL, y = "Prop. labelled", fill = NULL) +
  theme_minimal(base_size = 11) +
  theme(
    # grids: no vertical grid, subtle horizontal grid
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_line(color = "#EEEEEE"),
    # legend on top, horizontal
    legend.position = "top",
    legend.direction = "horizontal",
    legend.title = element_blank(),
    # axis text and title sizes
    axis.text.y = element_text(size = 9),
    plot.title = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 10)
  )

# Save as PDF (height scales with number of species)
out_pdf <- "bat_species_by_habitat.pdf"
ggsave(out_pdf, plt, width = 8, height = max(3, 0.3 * length(unique(plot_df$Species))), device = "pdf")

cat(sprintf("Plot saved to %s\n", out_pdf))

## -----------------------------
## End
## -----------------------------
