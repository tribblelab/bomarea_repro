Step 1: Using raw data to make a nexus file of inflorescence types for Bomarea
    a. run "bomareacode.R" on "bomarea traits.xlsx"
    b. you should have "type.nexus" in your data file
    c. change the unknowns in the type.nexus file

Step 2: Generate a tree using type.nexus and bom_only_MAP.tre
    a. Set working directory in zsh
        cd ~/Desktop/bomarea_traits/
    b. Open RevBayes in zsh and execute script
        i. rb
        ii. run "infl_type_ard.Rev" script until ->
        iii. keep window open
    c. In zsh combine and remove first 10% of data
        i. change directory to ~/Desktop/bomarea_traits/output
        ii. run code to combine runs
            awk 'FNR == 1 && NR != 1 { next } { print }' infl_type_ard_states_run_1.txt infl_type_ard_states_run_2.txt > infl_type_ard_states_combined.txt
        iii.run code to remove first 10% of code
            total_lines=$(wc -l < infl_type_ard_states_combined.txt)
            skip_lines=$((total_lines / 10))
            awk -v skip="$skip_lines" 'NR > skip || NR == 1' infl_type_ard_states_combined.txt > infl_type_ard_states_combined_trimmed.txt
    d. Return to RevBayes window
        i. execute the lines after ->
        ii. you should have "infl_type_ase_ard.tree" in your output folder

Step 3: Plot tree in R
    a. Run "plotresults.R" with "infl_type_ase_ard.tree" and save the plot as a .png

Step 4: Create a Violin Plot using rates
    a. run "plotviolinrates.R" and save plot as .png




