library(RevGadgets)
library(ggplot2)
library(ape)
setwd("~/Desktop/bomarea_traits/")
infl_type <- processAncStates("output/infl_type_ase_ard.tree", state_labels = c("0" = "Plain umbel",
                                                                                "1" = "Bracteole umbel",
                                                                                "2" = "Compound inflorescence"))
plotAncStatesPie(infl_type, tip_labels = TRUE)
ggsave("infl_type_ase_ard_tree.png", width = 10, height = 10, dpi = 200)

#rates <- readTrace(c("output/infl_type_ard_run_1.log",
#                     "output/infl_type_ard_run_2.log"))

#rates <- combineTraces(rates)

#plotTrace(rates, match = "rate")





