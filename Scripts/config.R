# ENTROPY BASED ========================

entropy <- function(X) {
  shannon = sum(sapply(X, FUN = function(x) ifelse(x!=0, -x*log2(x), 0 )))
  return(shannon)
}

plotGuess <-function(w, colors, L){
  splitted = unlist(str_split(w, ''))
  if (length(splitted) ==L) {
    plot = as.data.frame(cbind(toupper(splitted) , colors))
    colnames(plot) = c('letters','colors')
    plot$x = 1:L
    plot$y = 1
    ggplot(plot)+geom_rect(aes(xmin = x, xmax=x+1, ymin = y-1, ymax=y, fill = colors), color = 'black')+
      geom_text( aes(x=x +1/2, y=y/2, label=letters), size=7) +
      scale_fill_manual(values = c('green' = 'green2','yellow'='gold','grey'='grey'))+
      ylim(c(0,1))+
      theme_classic()+
      theme(axis.line=element_blank(),
            axis.text.x=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),
            legend.position="none",
            plot.background=element_blank())
  }
}



getColors <- function(guess, truth, L) {
  splitted_guess= unlist(str_split(guess, ''))
  splitted_truth= unlist(str_split(truth, ''))
  if (length(splitted_guess) ==L) {
    matchmat = sapply(1:L, function(x) { sapply(1:L, function(y) { splitted_guess[y] == splitted_truth[x] } ) })
    ## Mark greens (diagonal)
    greens = ifelse(diag(matchmat),'green', NA)
    matchmat[which(diag(matchmat)),] <- F
    matchmat[,which(diag(matchmat))] <- F
    
    ## If a letter is doubled, mark only the first yellow
    idxcol = which(colSums(matchmat)>1)
    first_occurence = apply(as.data.frame(matchmat[,idxcol]), MARGIN = 2, function(x) {which(x)[1]} )
    matchmat[,idxcol]<-F
    for (i in 1:length(idxcol)) {
      matchmat[first_occurence[i],idxcol[i]]<-T # Only the first occurence is yellow
    }
    yellows = ifelse(rowSums(matchmat)!=0, 'yellow', NA)
    
    res = rbind(greens, yellows)
    res = apply(res,2, function(x) paste(ifelse(!is.na(x), x, ''), collapse=""))
    res[is.na(res) | res=='']<-'grey'
    return(res)
  }
}


getGuessesInformations <- function(colorsMat_in) {
  probList = sapply(1:nrow(colorsMat_in), FUN = function(x) { as.data.frame(cbind(table(colorsMat_in[x,])))/ length(colorsMat_in[x,]) } )
  names(probList) <-rownames(colorsMat_in)
  shannon = as.data.frame(sapply(probList, entropy))
  p_mean =  as.data.frame(sapply(probList, mean))
  
  colnames(shannon)<-'information'
  colnames(p_mean)<-'p_mean'
  
  shannon$word = rownames(shannon)
  p_mean$word = rownames(p_mean)
  
  info = merge(p_mean, shannon, by = 'word')
  info = info[order(info$information, decreasing = T), ]
  return(info)
}


getNextSuggestion<-function(guess_in, target_in, colorsMat_in) {
  colors1 = colorsMat_in[guess_in,target_in]
  
  idx = which(colorsMat_in[guess_in, ] ==colors1)
  if (length(idx) >=2) {
    colorsMat1_in = colorsMat_in[, which(colorsMat_in[guess_in, ] ==colors1)] # keep only target with that colors matching
    colorsMat1_in = colorsMat1_in[- which(rownames(colorsMat1_in) ==guess_in),] # remove the previous guess from universe
    
    # probList = sapply(1:nrow(colorsMat1_in), FUN = function(x) { as.data.frame(cbind(table(colorsMat1_in[x,])))/ length(colorsMat1_in[x,]) } )
    # names(probList) <-rownames(colorsMat1_in)
    # shannon = as.data.frame(sapply(probList, entropy))
    # p_mean =  as.data.frame(sapply(probList, mean))
    # 
    # colnames(shannon)<-'information'
    # colnames(p_mean)<-'p_mean'
    # shannon$word = rownames(shannon)
    # p_mean$word = rownames(p_mean)
    # info = merge(p_mean, shannon, by = 'word')
    # info = info[order(info$information, decreasing = T), ]
    
    info = getGuessesInformations(colorsMat1_in)
    
    return(list(colors1, info, colorsMat1_in))
  } else { return(list(colors1, names(idx), colorsMat_in[guess_in,target_in]))}
}

getWorstGuessesInformations <- function(colorsMat_in) {
  probList = sapply(1:nrow(colorsMat_in), FUN = function(x) { as.data.frame(cbind(table(colorsMat_in[x,])))/ length(colorsMat_in[x,]) } )
  names(probList) <-rownames(colorsMat_in)
  shannon = as.data.frame(sapply(probList, entropy))
  p_mean =  as.data.frame(sapply(probList, mean))
  
  colnames(shannon)<-'information'
  colnames(p_mean)<-'p_mean'
  
  shannon$word = rownames(shannon)
  p_mean$word = rownames(p_mean)
  
  info = merge(p_mean, shannon, by = 'word')
  info = info[order(info$information), ]
  return(info)
}

getWorstNextSuggestion<-function(guess_in, target_in, colorsMat_in) {
  colors1 = colorsMat_in[guess_in,target_in]
  
  idx = which(colorsMat_in[guess_in, ] ==colors1)
  if (length(idx) >=2) {
    colorsMat1_in = colorsMat_in[,which(colorsMat_in[guess_in, ] ==colors1)] # keep only target with that colors matching
    colorsMat1_in = colorsMat1_in[- which(rownames(colorsMat1_in) ==guess_in),] # remove the previous guess from universe
    
    # probList = sapply(1:nrow(colorsMat1_in), FUN = function(x) { as.data.frame(cbind(table(colorsMat1_in[x,])))/ length(colorsMat1_in[x,]) } )
    # names(probList) <-rownames(colorsMat1_in)
    # shannon = as.data.frame(sapply(probList, entropy))
    # p_mean =  as.data.frame(sapply(probList, mean))
    # 
    # colnames(shannon)<-'information'
    # colnames(p_mean)<-'p_mean'
    # shannon$word = rownames(shannon)
    # p_mean$word = rownames(p_mean)
    # info = merge(p_mean, shannon, by = 'word')
    # info = info[order(info$information, decreasing = T), ]
    
    info = getWorstGuessesInformations(colorsMat1_in)
    
    return(list(colors1, info, colorsMat1_in))
  } else { return(list(colors1, names(idx), colorsMat_in[guess_in,target_in]))}
}

## NAIVE ===============
getScore <- function(words_list, freq_table) {
  score = freq_table/colSums(freq_table)
  words_score = as.data.frame(sapply(1:5, function(i) { substr(words_list,i,i) } ))
  # for each letter of each word, see which is the frequency in the dictionary to find THAT letter in THAT position
  words_score = as.data.frame(t(sapply(1:dim(words_score)[1], function(row) sapply(1:5, function(l) score[words_score[row,l],l]) )))
  
  # Take the mean of the letter frequency in a word
  words_score = rowMeans(words_score)
  
  words_list = as.data.frame(cbind(words_list, words_score))
  words_list = words_list[order(words_list$words_score, decreasing = T),]
  return(words_list)
}



scoreWords <-function(dict, alphabet) {
  ## Just a wrapper of getScore
  ## Ranks the words in dictionary, based on the letter frequency
  if (dim(dict)[1]>1) {
    freq = as.data.frame(sapply(colnames(dict), function(pos) sapply(alphabet, function(letter) sum(dict[,pos] ==letter, na.rm = T))))
    dict = unname(apply( dict[ , 1:5 ] , 1 , paste , collapse = "" ))
    score = getScore(dict, freq)
    return(score)
  } else {
    score = data.frame( 'words_list'=paste(dict[1,],collapse = ''), 'words_score'=NA)
    return(score)
  }
}



restrictDictionary <- function(guess, old_dictionary, colors) {
  right = as.numeric(colors =='green' )
  wp = as.numeric(colors =='yellow' )
  notpresent = as.numeric(colors=='grey')
  guess = as.data.frame(t(rbind(guess, 
                                'wp' = as.numeric(wp),
                                'right' = as.numeric(right),
                                'notpresent' = as.numeric(notpresent))))
  
  # wp: WRONG PLACE, but righet letter
  idx_col = which(guess$wp==1)
  idx_row = guess$guess[wp==1]
  
  s = length(idx_col) # how many wrong places letters
  
  new_dictionary = na.omit(old_dictionary)
  if (s>0) {
    for(x in(1:s) ) { 
      new_dictionary = new_dictionary[new_dictionary[,idx_col[x]]!=idx_row[x], ]
    } 
    x = as.data.frame(sapply(1:dim(new_dictionary)[1], function(row) 
      sum(!is.na(match( idx_row, new_dictionary[row,] )))))
    new_dictionary = new_dictionary[x>=length(idx_row),]    
  }
  
  # right letters
  idx_col = which(guess$right==1)
  idx_row = guess$guess[right==1]
  
  s = length(idx_col)
  
  if (s>0) {
    for(x in(1:s) ) { 
      new_dictionary = new_dictionary[new_dictionary[,idx_col[x]]==idx_row[x], ]
    }
  }
  
  
  # Not present letters
  # idx_col = which(guess$notpresent==1)
  idx_row = guess$guess[notpresent==1]
  idx_row = setdiff(idx_row, c(guess$guess[right==1], guess$guess[wp==1]))
  
  s = length(idx_row)
  
  if (s>0) {
    # letters must not be present in the word:
    x = as.data.frame( sapply(colnames(new_dictionary), function(col) 
      sapply(1:dim(new_dictionary)[1], function(row) !new_dictionary[row,col] %in% idx_row ))) 
    # colnames(x)<- 'ok_letters'
    
    if (dim(x)[2]==1) {
      x = t(x)
    }
    new_dictionary = na.omit(new_dictionary[rowSums(x, na.rm = T)==5,])
  }
  # subset(new_dictionary, V1=='c' & V2=='r' & V3=='a')
  # subset(new_dictionary2, V1=='j' & V2=='o' & V3=='i')
  # if (dim(new_dictionary)[1]>1) {
  #   new_dictionary2 = na.omit(new_dictionary[rowSums(x, na.rm = T)==5,])
  # } else {
  #   new_dictionary2 = new_dictionary
  # }
  return(new_dictionary)
}




# OLD
# 
# plotGuess <- function(guess_in, colors_in) {
#   plot = as.data.frame(cbind(toupper(unlist(str_split(guess_in, ''))) , colors_in))
#   colnames(plot) = c('letters','colors')
#   plot$x = 1:5
#   plot$y = 1
#   p <- ggplot(plot)+geom_rect(aes(xmin = x, xmax=x+1, ymin = y-1, ymax=y, fill = colors_in), color = 'black')+
#     geom_text( aes(x=x +1/2, y=y/2, label=letters), size=7) +
#     scale_fill_manual(values = c('green' = 'green2','yellow'='gold','grey'='grey'))+
#     ylim(c(-2.5,2.5))+
#     theme_classic()+
#     theme(axis.line=element_blank(),
#           axis.text.x=element_blank(),
#           axis.text.y=element_blank(),
#           axis.ticks=element_blank(),
#           axis.title.x=element_blank(),
#           axis.title.y=element_blank(),
#           legend.position="none",
#           plot.background=element_blank())
# }
# 
# getColors <- function(guess, truth) {
#   matchmat = sapply(1:5, function(x) { sapply(1:5, function(y) { guess[y] == truth[x] } ) })
#   ## Mark greens (diagonal)
#   greens = ifelse(diag(matchmat),'green', NA)
#   matchmat[which(diag(matchmat)),] <- F
#   matchmat[,which(diag(matchmat))] <- F
#   
#   ## If a letter is doubled, mark only the first yellow
#   idxcol = which(colSums(matchmat)>1)
#   first_occurence = apply(as.data.frame(matchmat[,idxcol]), MARGIN = 2, function(x) {which(x)[1]} )
#   matchmat[,idxcol]<-F
#   for (i in 1:length(idxcol)) {
#     matchmat[first_occurence[i],idxcol[i]]<-T # Only the first occurence is yellow
#   }
#   yellows = ifelse(rowSums(matchmat)!=0, 'yellow', NA)
#   
#   res = rbind(greens, yellows)
#   res = apply(res,2, function(x) paste(ifelse(!is.na(x), x, ''), collapse=""))
#   res[is.na(res) | res=='']<-'grey'
#   return(res)
# }