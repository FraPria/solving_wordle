## ___________________________
## Script name: 
## Purpose of script:
## Author: Francesca Priante
## Date Created: 2022-07-20
## ___________________________
## Notes:
##   
## ___________________________

require(ggplot2)
require(data.table)
library(stringr)
library(gtools)

# Parameters =============
setwd('~/Desktop/coding_shit/solving_wordle/')
source('wordle_app/config.R')
run_naive = F
run_entropy = T
n_games = 500
L = 5


dictionary = read.delim('Data/solutions.txt', header = F)
rownames(dictionary) = dictionary$V1

dictionary1 = as.data.frame(sapply(1:5, function(i) { substr(dictionary$V1,i,i) } ))
alphabet = unique(unlist(c(dictionary1)))


colorsMat = readRDS('Data/colorsMat.rds')
info = getGuessesInformations(colorsMat_in = colorsMat)
info$rank = seq(1:dim(info)[1])
rownames(info) = info$word
info$expected_left = round(dim(colorsMat)[2]/2^info$information)

# first_guess = info[which.max(info$information),'word'] # best
first_guess = info[which.min(info$information),'word'] # worst

set.seed(3293)
target_list = dictionary[sample(1:nrow(dictionary),n_games,replace = F),'V1']

# Simulation =============
# solutions = read.delim('wordle_app/solutions.txt', header=F)
guess1 = first_guess
tmp1 = info[guess1,]

# target_list = readRDS('Rdata/naive_first_guess_LATER_500_simulations.RDS')
# target_list = target_list$target_list

games = list()
info$rank <-NULL
information = list()

for (g in 1:n_games) {
  print(g)
  target = target_list[[g]]
  
  # First random guess is right
  if (guess1 == target) { 
    #games[[g]] = 1; 
    next }
  
  suggestion1 <<- getNextSuggestion(guess1, target, colorsMat )
  colorsMat2 <<- suggestion1[[3]]
  guess2 = suggestion1[[2]]
  
  if (length(guess2) ==1) {
    # second guess is right
    # games[[g]] = c(guess1)
    information[[g]] = as.data.frame(rbind(c(info[guess1, ], 'actual_left' = 1 )))
    next
  }
  
  guess2$expected_left = round(dim(colorsMat2)[2]/2^guess2$information)
  suggestion2 <<- getNextSuggestion(head(guess2,1)$word, target, colorsMat2 )
  colorsMat3 <<- suggestion2[[3]]
  guess3 = suggestion2[[2]]
  
  if (length(guess3) ==1) {
    # third guess is right
    # games[[g]] =  c(guess1, guess2[1,'word'])
    information[[g]] = rbind(c(info[guess1, ], 'actual_left' = dim(colorsMat2)[2] ),
                             c(guess2[1, ], 'actual_left' = 1 ))
    
    next
  }
  
  guess3$expected_left = round(dim(colorsMat3)[2]/2^guess3$information)
  suggestion3 <<- getNextSuggestion(head(guess3,1)$word, target, colorsMat3 )
  colorsMat4 <<- suggestion3[[3]]
  guess4 = suggestion3[[2]]
  
  if (length(guess4) ==1) {
    # fourth guess is right
    # games[[g]] =  c(guess1, guess2[1,'word'], guess3[1,'word'])
    information[[g]] = rbind(cbind(info[guess1, ], 'actual_left' = dim(colorsMat2)[2] ),
                             cbind(guess2[1, ], 'actual_left' = dim(colorsMat3)[2] ),
                             cbind(guess3[1, ], 'actual_left' = 1 ))
    next
  }
  
  guess4$expected_left = round(dim(colorsMat4)[2]/2^guess4$information)
  suggestion4 <<- getNextSuggestion(head(guess4,1)$word, target, colorsMat4 )
  colorsMat5 <<- suggestion4[[3]]
  guess5 = suggestion4[[2]]
  
  if (length(guess5) ==1) {
    # fifth guess is right
    # games[[g]] = c(guess1, guess2[1,'word'], guess3[1,'word'], guess4[1,'word'])
    information[[g]] = rbind(cbind(info[guess1, ], 'actual_left' = dim(colorsMat2)[2] ),
                             cbind(guess2[1, ], 'actual_left' = dim(colorsMat3)[2] ),
                             cbind(guess3[1, ], 'actual_left' = dim(colorsMat4)[2] ),
                             cbind(guess4[1, ], 'actual_left' = 1 ))
    
    next
  }
  
  guess5$expected_left = round(dim(colorsMat5)[2]/2^guess5$information)
  suggestion5 <<- getNextSuggestion(head(guess5,1)$word, target, colorsMat5 )
  colorsMat6 <<- suggestion5[[3]]
  
  # games[[g]] =  c(guess1, guess2[1,'word'], guess3[1,'word'], guess4[1,'word'], guess5[1,'word'])
  information[[g]] = rbind(c(info[guess1, ], 'actual_left' = dim(colorsMat2)[2] ),
                           cbind(guess2[1, ], 'actual_left' = dim(colorsMat3)[2] ),
                           cbind(guess3[1, ], 'actual_left' = dim(colorsMat4)[2] ),
                           cbind(guess4[1, ], 'actual_left' = dim(colorsMat5)[2] ),
                           cbind(guess5[1, ], 'actual_left' = ifelse(length(colorsMat6)>1, dim(colorsMat6)[2],1) ))
  
}


names(information)<-target_list
saveRDS(information, paste0('Data/entropy_first_guess_',toupper(first_guess),'_500_simulations.RDS'))

