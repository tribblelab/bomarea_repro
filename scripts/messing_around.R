library(readxl)
library(writexl)
library(dplyr)

setwd("~/Desktop/bomarea_traits/")
df <- read_xlsx("data/bomarea traits.xlsx")

# Function to calculate sparsity
calc_spars <- function(row) {
  # Sum total branch lengths across all 5 columns, ignoring NAs
  total_branch_length <- sum(as.numeric(row[c("lengthTotal1", "lengthTotal2", 
                                              "lengthTotal3", "lengthTotal4", 
                                              "lengthTotal5")]), na.rm = TRUE)
  # Get total number of flowers
  total_flowers <- as.numeric(row["allFlowersMat"])
  
  # Return sparsity if total_branch_length > 0; otherwise, return NA
  if (total_branch_length > 0 && !is.na(total_flowers)) {
    return(total_flowers / total_branch_length)
  } else {
    return(NA)
  }
}

# Apply function row-wise and create a new column for sparsity
df$sparsity <- apply(df, 1, calc_spars)

# Optional: Save the updated data to a new file
write_xlsx(df, "sparsity_calculated_data.csv", row.names = FALSE)