# Stacked Bar Chart Script

## Overview
This R script creates a stacked bar chart to visualize species distribution across two different habitats (Agriculture and Forest). The chart displays bars of equal length (100%) with two colors indicating the percentage of each species found in each habitat, ordered by occurrence in Agriculture.

## Purpose
- Compare species occurrence between two habitats
- Visualize the proportion of species found in Agriculture vs Forest
- Identify habitat preferences for different species
- Create publication-quality graphics for reports and presentations

## Requirements

### Software
- R (version 3.6 or higher recommended)
- RStudio (optional, but recommended for beginners)

### R Packages
The script requires three R packages:
```r
install.packages("ggplot2")   # For creating charts
install.packages("readxl")     # For reading Excel files
install.packages("dplyr")      # For data manipulation
```

## Input Data Format

Your data files should be in CSV or XLSX format with at least two columns:

1. **Species column**: Names of the species (text)
2. **Count column**: Number of observations or abundance (numeric)

### Example CSV Format:
```csv
species,count
Sparrow,45
Robin,32
Blackbird,28
```

### File Requirements:
- **Habitat A file**: Data from Agriculture habitat
- **Habitat B file**: Data from Forest habitat
- Both files should contain data for the same set of species
- Column names can vary (the script will rename them)

## How to Use

### Step 1: Prepare Your Data
1. Organize your species data into two separate files:
   - One file for Agriculture habitat data
   - One file for Forest habitat data
2. Save as CSV or XLSX format

### Step 2: Update File Paths
Open `stacked_bar_chart.R` and modify the file paths in **SECTION 2**:
```r
habitat_a_file <- "path/to/your/habitat_a_agriculture.csv"
habitat_b_file <- "path/to/your/habitat_b_forest.csv"
```

### Step 3: Check Column Names
If your data files use different column names, update **SECTION 5**:
```r
colnames(habitat_a_data)[1] <- "your_species_column_name"
colnames(habitat_a_data)[2] <- "your_count_column_name"
```

### Step 4: Run the Script
In RStudio:
- Open `stacked_bar_chart.R`
- Click the "Source" button or press `Ctrl+Shift+S` (Windows/Linux) or `Cmd+Shift+S` (Mac)

In R console:
```r
source("stacked_bar_chart.R")
```

## Output

The script produces:
1. **Interactive plot**: Displayed in RStudio or R graphics window
2. **Saved image**: `species_habitat_stacked_bar_chart.png` (300 DPI, suitable for publications)
3. **Console output**: Summary statistics showing:
   - Total number of species
   - Top 5 species in Agriculture
   - Top 5 species in Forest

## Example Files

The repository includes example data files:
- `habitat_a_agriculture.csv`: Sample Agriculture habitat data
- `habitat_b_forest.csv`: Sample Forest habitat data

You can run the script with these example files to see how it works before using your own data.

## Customization

### Change Colors
In **SECTION 7**, modify the color codes:
```r
scale_fill_manual(values = c("Agriculture" = "#E69F00",  # Orange
                             "Forest" = "#009E73"),      # Green
```

### Adjust Plot Size
In **SECTION 8**, change dimensions:
```r
ggsave(filename = output_file,
       width = 12,    # Change width
       height = 8,    # Change height
       dpi = 300)     # Change resolution
```

### Modify Text Size
In **SECTION 7**, adjust theme parameters:
```r
theme(
  axis.text.x = element_text(angle = 45, hjust = 1, size = 10),  # X-axis labels
  axis.title = element_text(size = 12, face = "bold"),           # Axis titles
  plot.title = element_text(size = 14, face = "bold")            # Main title
)
```

## Troubleshooting

### Error: "Package not found"
**Solution**: Install required packages:
```r
install.packages("ggplot2")
install.packages("readxl")
install.packages("dplyr")
```

### Error: "File not found"
**Solution**: 
- Check that file paths are correct
- Use full paths if relative paths don't work
- Verify files exist in the specified location
- Check your working directory: `getwd()`

### Error: "Column names not found"
**Solution**: 
- Check actual column names in your data: `names(your_data)`
- Update column name assignments in SECTION 5

### Plot looks crowded
**Solution**: 
- Increase plot width/height in `ggsave()`
- Adjust text angle/size in theme settings
- Reduce font size for axis labels

## Learning Notes for Beginners

### What is a Stacked Bar Chart?
A stacked bar chart displays multiple variables on the same bar, stacked vertically. Each bar represents 100% of the data, divided into segments showing the proportion of each category.

### Why Use This Visualization?
- Easy to compare proportions across multiple groups
- Shows both absolute differences and relative percentages
- Good for highlighting patterns in categorical data

### Understanding the Code Structure
The script is organized into clear sections:
1. **Library loading**: Import necessary tools
2. **File paths**: Specify data locations
3. **Functions**: Reusable code for loading data
4. **Data loading**: Read files into R
5. **Data preparation**: Clean and organize data
6. **Calculations**: Compute percentages
7. **Visualization**: Create the chart
8. **Export**: Save the final plot
9. **Summary**: Print statistics

Each section is well-commented to explain what the code does and why.

## Support

For questions or issues:
1. Check the comments in `stacked_bar_chart.R`
2. Review this README
3. Verify your data format matches the requirements
4. Ensure all packages are installed

## License

This script is part of the R-dojo project for creating academic figures.
