# Bomarea Inflorescence Trait Analysis

This project uses herbarium specimen data to analyze inflorescence types across *Bomarea* species using a combination of R, RevBayes, and bash. The workflow generates phylogenetic trees, ancestral state reconstructions, and transition rate violin plots.

---

## Step 1: Create a Nexus File of Inflorescence Types

1. **Run `bomareacode.R` on `bomarea traits.xlsx`**
    - This script takes measurements from herbarium specimens and the Excel sheet, categorizes inflorescences (type, branchiness, size, and sparsity) and outputs a `.nexus` file.

2. **Output**
    - You should have a file named `type.nexus` in your data folder.
    - **NEXUS format:** A widely used file format in bioinformatics for storing taxa, morphological/molecular characters, trees, etc.

---

## Step 2: Generate a Tree with RevBayes

1. **Set your working directory**

    ```bash
    cd ~/Desktop/bomarea_traits/
    ```

2. **Open RevBayes and run the analysis**

    - Start RevBayes:

    ```bash
    rb
    ```

    - In RevBayes, execute the script:

    ```rev
    source("infl_type_ard.Rev")
    ```

    - This script runs a Markov Chain Monte Carlo (MCMC) analysis using the `.tree` (molecular data) and `.nexus` (trait data) files.  
      > For more details on MCMC, see the [RevBayes MCMC tutorial](https://revbayes.github.io/tutorials/mcmc/archery.html).

3. **Combine runs and remove the burn-in (first 10%)**

    - In another terminal window, navigate to the output folder:

    ```bash
    cd ~/Desktop/bomarea_traits/output
    ```

    - Combine results from two MCMC runs:

    ```bash
    awk 'FNR == 1 && NR != 1 { next } { print }' infl_type_ard_states_run_1.txt infl_type_ard_states_run_2.txt > infl_type_ard_states_combined.txt
    ```

    - Remove the first 10% ("burn-in") of the combined results:

    ```bash
    total_lines=$(wc -l < infl_type_ard_states_combined.txt)
    skip_lines=$((total_lines / 10))
    awk -v skip="$skip_lines" 'NR > skip || NR == 1' infl_type_ard_states_combined.txt > infl_type_ard_states_combined_trimmed.txt
    ```

4. **Finish the RevBayes analysis**

    - In the original RevBayes window, execute the two remaining lines after the `->` prompt.
    - This will:
      - Calculate ancestral states (pie charts at phylogenetic nodes).
      - Output a tree file for visualization.

5. **Output**

    - You should now have a file called `infl_type_ase_ard.tree` in your output folder.

---

## Step 3: Plot the Phylogenetic Tree

1. **Run `plotresults.R`**

    - Input the file `infl_type_ase_ard.tree`.
    - This will generate a phylogeny with:
      - Species names
      - Trait states
      - Node pie charts showing ancestral states
      - A legend

2. **Save the plot as a `.png` file.**

---

## Step 4: Create a Violin Plot of Transition Rates

1. **Run `plotviolinrates.R`**

    - This script creates a violin plot showing the rates of transitions between inflorescence types.

2. **Save the plot as a `.png` file.**

---

## Definitions

| Term | Definition |
| :--- | :--- |
| **Inflorescences** | Arrangement of flowers on a floral axis (e.g., the brown part of a sunflower consists of many tiny flowers). |
| **Genus** | A classification level above species, grouping together similar species. |
| **Bomarea** | A genus of tropical plants with diverse inflorescence structures. |
| **Phylogeny** | A "tree of life" diagram showing evolutionary relationships among organisms. |
| **Herbarium** | A collection of preserved plant specimens. |
| **Taxa** | The tips of the phylogeny representing species. |
| **Markov Chain Monte Carlo (MCMC)** | A method for sampling from probability distributions, used here to estimate ancestral states and trait transition rates. |

---
