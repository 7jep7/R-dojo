################################################################################
# Stacked Bar Chart Script for Species Habitat Comparison
################################################################################
# 
# PURPOSE:
# This script creates a stacked bar chart to visualize species occurrence 
# across two different habitats:
#   - Habitat A (Agriculture/AG)
#   - Habitat B (Forest/FOREST)
#
# The chart shows:
#   - Bars of equal length (100%) for each species
#   - Two colors indicating the percentage found in each habitat
#   - Species ordered by their occurrence percentage in Habitat A
#
# INPUT FILES:
#   - CSV or XLSX file with data from Habitat A (Agriculture)
#   - CSV or XLSX file with data from Habitat B (Forest)
#
# AUTHOR: R-dojo Project
# DATE: 2024
#
################################################################################

# ==============================================================================
# SECTION 1: LOAD REQUIRED LIBRARIES
# ==============================================================================
# Libraries are collections of pre-written code that add functionality to R
# If you don't have these installed, run in R console:
#   install.packages("ggplot2")
#   install.packages("readxl")
#   install.packages("dplyr")

# ggplot2: For creating beautiful, publication-quality graphics
library(ggplot2)

# readxl: For reading Excel files (.xlsx)
library(readxl)

# dplyr: For data manipulation and transformation
library(dplyr)

# ==============================================================================
# SECTION 2: DEFINE INPUT FILES
# ==============================================================================
# Specify the paths to your data files
# Replace these with the actual paths to your files

# File containing species counts from Agriculture habitat
habitat_a_file <- "habitat_a_agriculture.csv"

# File containing species counts from Forest habitat
habitat_b_file <- "habitat_b_forest.csv"

# ==============================================================================
# SECTION 3: LOAD DATA FUNCTION
# ==============================================================================
# This function loads data from either CSV or XLSX files
# It checks the file extension and uses the appropriate reading method

load_data <- function(file_path) {
  # Check if file exists
  if (!file.exists(file_path)) {
    stop(paste("Error: File not found:", file_path))
  }
  
  # Get file extension (the part after the last dot)
  file_ext <- tolower(tools::file_ext(file_path))
  
  # Load data based on file type
  if (file_ext == "csv") {
    # Read CSV file
    data <- read.csv(file_path, stringsAsFactors = FALSE)
  } else if (file_ext %in% c("xlsx", "xls")) {
    # Read Excel file
    data <- read_excel(file_path)
  } else {
    stop(paste("Error: Unsupported file format:", file_ext, 
               "Please use CSV or XLSX files."))
  }
  
  return(data)
}

# ==============================================================================
# SECTION 4: LOAD THE DATA FILES
# ==============================================================================
# Load both habitat datasets
# These should contain at least two columns:
#   1. Species name (e.g., "species", "Species", "species_name")
#   2. Count or abundance (e.g., "count", "abundance", "n")

cat("Loading data files...\n")

# Load Habitat A data (Agriculture)
habitat_a_data <- load_data(habitat_a_file)
cat("Habitat A (Agriculture) data loaded:", nrow(habitat_a_data), "rows\n")

# Load Habitat B data (Forest)
habitat_b_data <- load_data(habitat_b_file)
cat("Habitat B (Forest) data loaded:", nrow(habitat_b_data), "rows\n")

# ==============================================================================
# SECTION 5: DATA PREPARATION
# ==============================================================================
# Prepare and combine the data from both habitats

# Rename columns to standard names for easier processing
# Adjust these column names based on your actual data
# Common variations: "species", "Species", "species_name", "taxon"
#                    "count", "Count", "abundance", "n", "number"

# For Habitat A
colnames(habitat_a_data)[1] <- "species"  # First column: species name
colnames(habitat_a_data)[2] <- "count"    # Second column: count/abundance

# For Habitat B
colnames(habitat_b_data)[1] <- "species"  # First column: species name
colnames(habitat_b_data)[2] <- "count"    # Second column: count/abundance

# Add habitat identifier to each dataset
habitat_a_data$habitat <- "Agriculture"
habitat_b_data$habitat <- "Forest"

# Combine both datasets into one data frame
combined_data <- rbind(habitat_a_data, habitat_b_data)

# ==============================================================================
# SECTION 6: CALCULATE PERCENTAGES
# ==============================================================================
# For each species, calculate what percentage of observations occurred
# in each habitat

# Group data by species and calculate total count per species
species_totals <- combined_data %>%
  group_by(species) %>%
  summarise(total_count = sum(count, na.rm = TRUE))

# Join totals back to main data and calculate percentages
plot_data <- combined_data %>%
  left_join(species_totals, by = "species") %>%
  mutate(percentage = (count / total_count) * 100)

# Calculate percentage in Agriculture for sorting
species_ag_percent <- plot_data %>%
  filter(habitat == "Agriculture") %>%
  select(species, percentage) %>%
  rename(ag_percent = percentage)

# Join Agriculture percentage back to plot data for ordering
plot_data <- plot_data %>%
  left_join(species_ag_percent, by = "species") %>%
  mutate(species = factor(species)) %>%
  arrange(desc(ag_percent))

# Reorder species factor levels by Agriculture percentage (descending)
plot_data$species <- factor(plot_data$species, 
                            levels = unique(plot_data$species[order(plot_data$ag_percent, 
                                                                    decreasing = TRUE)]))

# ==============================================================================
# SECTION 7: CREATE THE STACKED BAR CHART
# ==============================================================================
# Now we create the visualization using ggplot2

cat("\nCreating stacked bar chart...\n")

# Create the plot
stacked_bar_plot <- ggplot(plot_data, 
                           aes(x = species,        # Species on x-axis
                               y = percentage,     # Percentage on y-axis
                               fill = habitat)) +  # Color by habitat
  
  # Add bars (stacked by default)
  geom_bar(stat = "identity",           # Use actual values, not counts
           position = "stack",           # Stack bars on top of each other
           width = 0.8) +                # Bar width
  
  # Customize colors
  scale_fill_manual(values = c("Agriculture" = "#E69F00",  # Orange for Agriculture
                               "Forest" = "#009E73"),      # Green for Forest
                    name = "Habitat Type") +               # Legend title
  
  # Add labels and title
  labs(title = "Species Distribution Across Habitats",
       subtitle = "Percentage occurrence in Agriculture vs Forest (ordered by Agriculture %)",
       x = "Species",
       y = "Percentage (%)") +
  
  # Customize theme
  theme_minimal() +                      # Clean, minimal theme
  theme(
    # Rotate x-axis labels for better readability
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y = element_text(size = 10),
    axis.title = element_text(size = 12, face = "bold"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5),
    legend.position = "right",
    legend.title = element_text(size = 11, face = "bold"),
    legend.text = element_text(size = 10),
    panel.grid.major.x = element_blank()  # Remove vertical grid lines
  )

# Display the plot
print(stacked_bar_plot)

# ==============================================================================
# SECTION 8: SAVE THE PLOT
# ==============================================================================
# Save the plot to a file for use in reports or presentations

# Define output file name
output_file <- "species_habitat_stacked_bar_chart.png"

# Save the plot
ggsave(filename = output_file,
       plot = stacked_bar_plot,
       width = 12,              # Width in inches
       height = 8,              # Height in inches
       dpi = 300,               # Resolution (dots per inch)
       units = "in")            # Units for width and height

cat("\nPlot saved as:", output_file, "\n")

# ==============================================================================
# SECTION 9: SUMMARY STATISTICS (OPTIONAL)
# ==============================================================================
# Print summary information about the data

cat("\n=== SUMMARY STATISTICS ===\n")
cat("Total number of species:", length(unique(combined_data$species)), "\n")

# Calculate and display species with highest Agriculture percentage
top_ag_species <- species_ag_percent %>%
  arrange(desc(ag_percent)) %>%
  head(5)

cat("\nTop 5 species in Agriculture:\n")
print(top_ag_species)

# Calculate and display species with lowest Agriculture percentage (highest Forest)
bottom_ag_species <- species_ag_percent %>%
  arrange(ag_percent) %>%
  head(5)

cat("\nTop 5 species in Forest (lowest Agriculture %):\n")
print(bottom_ag_species)

cat("\n=== SCRIPT COMPLETED SUCCESSFULLY ===\n")

################################################################################
# NOTES FOR BEGINNERS:
################################################################################
# 
# 1. DATA FORMAT: Your input files should have at least two columns:
#    - Column 1: Species name (text)
#    - Column 2: Count or abundance (number)
#
# 2. FILE PATHS: Make sure the file paths in SECTION 2 point to your actual
#    data files. You can use:
#    - Relative paths: "data/my_file.csv" (relative to current directory)
#    - Absolute paths: "C:/Users/YourName/Documents/my_file.csv" (full path)
#
# 3. RUNNING THE SCRIPT:
#    - In RStudio: Open the script and click "Source" or press Ctrl+Shift+S
#    - In R console: Run source("stacked_bar_chart.R")
#
# 4. TROUBLESHOOTING:
#    - If packages are missing, install them first (see SECTION 1)
#    - If file not found, check the file paths and working directory
#    - If column names don't match, adjust them in SECTION 5
#
# 5. CUSTOMIZATION:
#    - Colors: Change the color codes in scale_fill_manual()
#    - Plot size: Adjust width and height in ggsave()
#    - Text size: Modify size parameters in theme()
#
################################################################################
