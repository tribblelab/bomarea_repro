setwd("~/Desktop/bomarea_traits/")

library(dplyr)
library(tidyr)
library(vegan)
library(readxl)
library(ape)
library(tidytree)
library(car)

traits <- read_xlsx("data/bomarea traits.xlsx", sheet = 1, na = "N/A")
# erase that pesky Bomarea torquifes row

traits <- traits[-which(traits$speciesName == "Bomarea torquifes"), ]
traits <- traits[is.na(traits$acceptedName)==FALSE, ]

get_most_frequent_discrete_value <- function(vec) {
  tbl <- table(vec)
  if (dim(tbl) > 0) {
    value <- names(tbl)[which.max(tbl)]
    return(value)
  } else {
    return (NA)
  }
  }

### Name Check
sameName <- function(df) {
  if (is.na(df[2])) {
          return(NA)
  } else{
          if (df[1] != df[2]) {
                  return(1)
          } else {
                  return(NA)
          }   
  }
} #making a function that checks if names are the same

subsetName <- traits[, c("speciesName", "acceptedName")]
subsetName$ifSame <- apply(subsetName, 1, sameName)
subsetName <- na.omit(subsetName)
write.csv(subsetName, file = "NameCheck")
### Name Check End

traits %>% 
  group_by(acceptedName) %>% 
  summarise(numBranchP = mean(numBranchP, na.rm = T), 
            numBracts = mean(numBracts, na.rm = T),
            numBranch1 = mean(numBranch1, na.rm = T), 
            numBranch2 = mean(numBranch2, na.rm = T),
            numBranch3 = mean(numBranch3, na.rm = T),
            numBranch4 = mean(numBranch4, na.rm = T),
            numBranch5 = mean(numBranch5, na.rm = T),
            Bracteoles = get_most_frequent_discrete_value(Bracteoles),
            ifFruiting = get_most_frequent_discrete_value(ifFruiting),
            matFruit = get_most_frequent_discrete_value(matFruit),
            ifFlowering = get_most_frequent_discrete_value(ifFlowering),
            matFlower = get_most_frequent_discrete_value(matFlower),
            allFlowersMat = get_most_frequent_discrete_value(allFlowersMat),
            nectarGuides = get_most_frequent_discrete_value(nectarGuides),
            colorTepalP = get_most_frequent_discrete_value(colorTepalP),
            colorTepalS = get_most_frequent_discrete_value(colorTepalS),
            ifTepalLengthMatch = get_most_frequent_discrete_value(ifTepalLengthMatch),
            ETepalLength = get_most_frequent_discrete_value(ETepalLength),
            ifExcerted = get_most_frequent_discrete_value(ifExcerted)) -> traits_by_species

traits_by_species_averaged <- cbind(traits_by_species[, c("acceptedName","numBranchP","numBracts","numBranch1")],
                                    traits_by_species[, c("Bracteoles","ifFruiting","matFruit","ifFlowering",       
                                                         "matFlower","allFlowersMat","nectarGuides",      
                                                         "colorTepalP","colorTepalS","ifTepalLengthMatch",
                                                         "ETepalLength","ifExcerted")]) #binding columns

#cleaning (inf to NA, Nan to NA, empty to NA, then converting those into NA instead of "NA")
traits_by_species_averaged[sapply(traits_by_species_averaged, is.infinite)] <- NA
traits_by_species_averaged[sapply(traits_by_species_averaged, is.nan)] <- NA
traits_by_species_averaged <- as.data.frame(apply(traits_by_species_averaged, 
                                                 2, 
                                                 car::recode, 
                                                 recodes = "'NA' = NA"))
traits_by_species_averaged <- as.data.frame(apply(traits_by_species_averaged, 
                                                  2, 
                                                  car::recode, 
                                                  recodes = "'' = NA"))
#turning these into numerical data
traitdata <- traits_by_species_averaged
traitdata$numBranchP <- as.numeric(traitdata$numBranchP)
traitdata$numBracts <- as.numeric(traitdata$numBracts)
traitdata$numBranch1 <- as.numeric(traitdata$numBranch1)

#looking and 2 & 3 columns in dataset (branching and bracts)
typeset <- function(df) {
  if (any(is.na(df))) {
          return(NA)
  } else {
          if (df[2]==TRUE & df[3]==FALSE) { ## umbellike, no bracteoles
                  return(0)
          }
          else if (df[2]==TRUE & df[3]==TRUE) { ## umbellike w/ bracteoles
                  return(1)
          }
          else if (df[2]==FALSE & df[3]==TRUE) { ## non umbel (branching) w/ bracteoles
                  return(2)
          } else {
                  return(NA)
          }  
  }
}

#### new stuff: infl type
traitdata %>%
  mutate(umbellike = numBranch1==0) %>% #adds new column TRUE if numBranch1 is 0, FALSE if other
  mutate(bracteoles = Bracteoles=="Y") %>% #adds new column TRUE if Bracteoles == "Y", FALSE if other
  mutate(acceptedName = gsub(" ", "_", acceptedName)) %>% #random but gets rid of "_" in accepted name
  select(acceptedName, umbellike, bracteoles) -> traitdatasubset #only keeps acceptedName, umbellike, bracteoles columns

traitdatasubset$type = apply(traitdatasubset, 1, typeset) #applies typeset function to data subset

### new stuff: infl trait isolation (size + tepal traits)

traits %>%
  group_by(acceptedName) %>% #same as above for size and tepal traits
  summarise(maxBranchNo = max(numBranchP, na.rm = T),
            maxBranchLength = max(lengthTotal1, lengthTotal2, lengthTotal3, lengthTotal4, lengthTotal5, na.rm = T),
            degreeBranch = max(numBranch1, numBranch2, numBranch3, numBranch4, numBranch5, na.rm = T),
            colorTepalP = get_most_frequent_discrete_value(colorTepalP),
            colorTepalS = get_most_frequent_discrete_value(colorTepalS),
            ifTepalLengthMatch = get_most_frequent_discrete_value(ifTepalLengthMatch),
            ifExcerted = get_most_frequent_discrete_value(ifExcerted)) -> inflSelect #group and summarize
inflSelect %>%
  count(colorTepalP, sort = TRUE) #counts unique occurences and sorts
inflSelect %>%
  count(colorTepalS, sort = TRUE) #counts unique occurences and sorts


### new stuff: sparsity via length/# branches

#sparsity <- function(df){
       
#}

#match names to tree and drop tips
tree <- read.tree("data/bom_only_MAP.tre")
tips_to_drop <- tree$tip.label[grep("caudata|herbertiana", tree$tip.label)]
tree_edited <- ape::drop.tip(tree, tips_to_drop)
write.tree(tree_edited, file = "data/tree_edited.tre")
tree_df <- as_tibble(tree_edited)

get_gen_sp <- function(x) {
  if (is.na(x)) {
    return(NA)
  } else if (grepl("_cf_", x)) {
    namesplit <- unlist(strsplit(x, split = "_"))
    newname <- paste0(namesplit[1], "_", namesplit[3])
    return(newname) 
  } else {
    namesplit <- unlist(strsplit(x, split = "_"))
    newname <- paste0(namesplit[1], "_", namesplit[2])
    return(newname) 
  }
}

#combine species names
tree_df$speciesName <- unlist(lapply(tree_df$label, get_gen_sp))
tree_df <- left_join(tree_df, traitdatasubset, by = c("speciesName" = "acceptedName"))
typedat <- data.frame(label = tree_df$label, type = tree_df$type.x)
typedat <- typedat[is.na(typedat$label) == FALSE, ]
typedat$type <- replace_na(as.character(as.integer(typedat$type)), "?")

#manually added these infl types to nexus file
#make df
manual_add <- data.frame(
  label = c("Bomarea_parvifolia_Peru_Stein2019", "Bomarea_tribachiata_AlzateS_N_", "Bomarea_angustipetala_Alzate5116",
            "Bomarea_lehmannii_AlzateS_N_", "Bomarea_straminea_Alzate3300", "Bomarea_chimborazensis_Ecuador_Aedo13023",
            "Bomarea_trimorphophylla_Alzate3158", "Bomarea_hartwegii_Alzate3157", "Bomarea_alstroemeriodes_Peru_Dillon1747",
            "Bomarea_euryphylla_Ecuador_Vargas2930", "Bomarea_foliosa_Ecuador_Zak2268", "Bomarea_bredemeyerana_Venezuela_Liesner7935",
            "Bomarea_acuminata_CR_Bonifacino6051", "Bomarea_bredemeyerana_Colombia_Tribble06", "Bomarea_killipii_Peru_Vasquez33143"),

  type = c(2, 2, 2, 2, 2, 2, 2, 0, 0, 1, 1, 0, 1, 0, 2)
)

#B. parvifolia is 2
#B. tribachiata is 2
#B. lehmanii is 2
#B. straminea is 2
#B. angustipetala is 2
#B. foliosa is 1
#B. euryphylla is 1
#B. acuminata is 1
#B. bredemeyerana Venezula is 0
#B. killipii is 2
#B. bredemeyerana Colombia is 0
#B. alstroemerioides 0
#B. hartwegii is 0
#B. trimorphophylla 2
#B. chimborazensis is 2


#merge into existing df
typedat <- typedat %>%
  left_join(manual_add, by = "label") %>%
  mutate(type = ifelse(!is.na(type.y), type.y, type.x)) %>%
  select(label, type)


#make a matrix for type
typemat <- matrix(typedat$type, ncol =1)
rownames(typemat) <- typedat$label
colnames(typemat) <- "type"

#write to nexus 
write.nexus.data(typemat, file = "type_dropped_tips.nexus", format = "standard", missing = "?")
