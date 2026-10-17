# PredPSP Shiny App

This Shiny application recreates the PredPSP website layout with Home, Run Server, Dataset, Help, and Contact Us sections.

## Run locally

1. Install R (recommended R 4.3 or later) and RStudio.
2. Install the required packages:

```r
install.packages(c("shiny", "lightgbm"))
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install("Biostrings")
install.packages("ftrCOOL")
```

3. Open this folder as the working directory and run:

```r
shiny::runApp()
```

## Prediction workflow

- Select C3 or C4 plant model.
- Paste FASTA protein sequences or upload a FASTA file.
- Only the 20 standard amino-acid residues are accepted.
- Maximum 500 sequences per submission.
- Results include the model probability and a threshold-based label, and can be downloaded as CSV.

## Important validation note

The app adapts the original supplied `psp_c3.R` and `psp_c4.R` feature/model workflow. Run a local test with the example FASTA and compare against the original server's expected output before public deployment. Exact runtime compatibility depends on the installed versions of `lightgbm`, `Biostrings`, and `ftrCOOL`.
