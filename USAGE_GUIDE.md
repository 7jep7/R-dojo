# Quick Start Guide - Stacked Bar Chart Script

## For Complete Beginners

This guide will walk you through using the stacked bar chart script step-by-step, even if you've never used R before.

## What You'll Create

A stacked bar chart that shows:
- **Each bar = one species**
- **Bar height = 100%** (always the same)
- **Two colors in each bar** showing what percentage of that species was found in:
  - Agriculture habitat (orange)
  - Forest habitat (green)
- **Bars ordered** by how common the species is in agriculture

## Visual Workflow

```
┌─────────────────┐       ┌─────────────────┐
│   Agriculture   │       │     Forest      │
│   Data File     │       │   Data File     │
│  (habitat_a)    │       │  (habitat_b)    │
└────────┬────────┘       └────────┬────────┘
         │                         │
         │                         │
         └────────┬────────────────┘
                  │
                  ▼
         ┌────────────────┐
         │  R Script      │
         │  Processes     │
         │  & Combines    │
         └────────┬────────┘
                  │
                  ▼
         ┌────────────────┐
         │  Stacked Bar   │
         │     Chart      │
         │  (PNG file)    │
         └────────────────┘
```

## Step-by-Step Instructions

### Step 1: Install R (One-time setup)

#### Windows:
1. Go to https://cran.r-project.org/bin/windows/base/
2. Download R
3. Run the installer
4. Accept default settings

#### Mac:
1. Go to https://cran.r-project.org/bin/macosx/
2. Download R for Mac
3. Open the .pkg file
4. Follow installation prompts

#### Linux (Ubuntu/Debian):
```bash
sudo apt-get update
sudo apt-get install r-base
```

### Step 2: Install RStudio (Recommended, One-time setup)

RStudio makes R easier to use with a friendly interface.

1. Go to https://posit.co/download/rstudio-desktop/
2. Download RStudio Desktop (Free)
3. Install it after R is installed

### Step 3: Install Required Packages (One-time setup)

Open R or RStudio and type these commands in the console:

```r
install.packages("ggplot2")
install.packages("readxl")
install.packages("dplyr")
```

Press Enter after each line. Wait for installation to complete (may take a few minutes).

### Step 4: Prepare Your Data Files

Your data files should look like this:

**Agriculture file (habitat_a_agriculture.csv):**
```
species,count
Sparrow,45
Robin,32
Blackbird,28
```

**Forest file (habitat_b_forest.csv):**
```
species,count
Sparrow,15
Robin,28
Blackbird,42
```

**Important**:
- Use the same species names in both files
- Make sure column names are in the first row
- Save as CSV (comma-separated values)

### Step 5: Set Up Your Files

Put these files in the same folder:
- `stacked_bar_chart.R` (the script)
- `habitat_a_agriculture.csv` (your agriculture data)
- `habitat_b_forest.csv` (your forest data)

### Step 6: Update File Paths in Script

Open `stacked_bar_chart.R` in RStudio or a text editor.

Find these lines (around line 50):
```r
habitat_a_file <- "habitat_a_agriculture.csv"
habitat_b_file <- "habitat_b_forest.csv"
```

If your files have different names, change them here.

### Step 7: Run the Script

**In RStudio:**
1. Open `stacked_bar_chart.R`
2. Click the "Source" button (top right of script window)
3. Or press: Ctrl+Shift+S (Windows/Linux) or Cmd+Shift+S (Mac)

**In R console:**
1. Set working directory to your folder:
   ```r
   setwd("path/to/your/folder")
   ```
2. Run the script:
   ```r
   source("stacked_bar_chart.R")
   ```

### Step 8: View Your Results

The script will:
1. Display the chart in the plot window
2. Save the chart as `species_habitat_stacked_bar_chart.png`
3. Print summary statistics in the console

## Understanding Your Data

### Input Data Structure

Each file should have:
- **Row 1**: Column headers (species, count)
- **Row 2+**: Data rows (one per species)

Example:
```
Row 1:  species,count         ← Headers
Row 2:  Sparrow,45            ← Data
Row 3:  Robin,32              ← Data
```

### How Percentages Are Calculated

For each species:
1. Add counts from both habitats
2. Calculate percentage in each habitat

Example for Sparrow:
- Agriculture: 45 birds
- Forest: 15 birds
- Total: 60 birds
- Agriculture %: (45/60) × 100 = 75%
- Forest %: (15/60) × 100 = 25%

## Common Issues and Solutions

### "Package not found"
**Problem**: You haven't installed the required packages.
**Solution**: Run the install commands from Step 3.

### "File not found"
**Problem**: R can't find your data files.
**Solution**: 
- Check file names match exactly (including .csv)
- Make sure files are in the same folder as the script
- Try using full file paths: `"C:/Users/YourName/Documents/data.csv"`

### "Cannot open connection"
**Problem**: File path is incorrect or file is open in Excel.
**Solution**: 
- Close the file if it's open in another program
- Check the file path is correct
- Use forward slashes `/` or double backslashes `\\` in Windows paths

### "Object not found"
**Problem**: Column names don't match what the script expects.
**Solution**: 
- Open your CSV file
- Check the column headers
- Update the script in SECTION 5 to match your column names

### Plot looks wrong
**Problem**: Text is overlapping or chart is too small.
**Solution**: 
- Adjust plot size in the `ggsave()` function
- Change text angle or size in the `theme()` section

## Example Output

Your final chart will show:
- Species names along the bottom (x-axis)
- Percentage from 0-100% on the left (y-axis)
- Orange bars for Agriculture
- Green bars for Forest
- Species ordered with most agricultural species first

## Next Steps

Once you have the basic chart working:
1. Try changing colors (see README_stacked_bar_chart.md)
2. Modify text sizes
3. Adjust plot dimensions
4. Add your own title

## Getting Help

If you're stuck:
1. Check the error message - it often tells you what's wrong
2. Read the comments in `stacked_bar_chart.R`
3. Review `README_stacked_bar_chart.md` for detailed information
4. Make sure you completed all installation steps

## Tips for Success

✅ **Do**:
- Start with the example files to make sure everything works
- Read error messages carefully
- Check your data format matches the examples
- Save your script before running it

❌ **Don't**:
- Skip the package installation step
- Use spaces in file names
- Open data files in Excel while R is reading them
- Edit the script without backing it up first

## Glossary for Beginners

- **R**: A programming language for statistics and data visualization
- **RStudio**: A user-friendly application for working with R
- **Package**: A collection of pre-written functions that add capabilities to R
- **CSV**: Comma-Separated Values - a simple file format for data
- **Console**: The area in R/RStudio where you type commands
- **Script**: A file containing R code that can be run all at once
- **Working Directory**: The folder R is currently looking in for files

Good luck with your analysis!
