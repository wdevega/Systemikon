################################################################
#Calculating Gene Ontology Semantic Similarity
#Author: Wilfred de Vega
################################################################

library(GOSemSim) #loads GOSemSim package

listofgenes <- "samplelist.txt" #obtain list of Entrez IDs (will be modified once List of Genes format is determined)
genetable <- read.table(listofgenes, sep = "\t", header = TRUE) #organize list of genes into table
genecombo <- t(combn(genetable[,1], m = 2)) #obtain every possible combination of 2 genes. Transpose the matrix to make it easier to read.
colnames(genecombo)[1:2] <- c("Gene 1", "Gene 2") #Rename the first two columns for clarity

CCscore <- apply(genecombo, 1, function(x){ #Calculate CC GO Semantic Similarity Scores over each row (1) of the matrix
  CCSemSim <- geneSim(x[1], x[2], ont = 'CC', organism = 'human', measure = 'Rel', combine = 'BMA') #should return a vector of 3 elements
  if(length(CCSemSim) < 3){ #if a vector of a length < 3 is returned (ie. calculation fails due to lack of GO annotations)
    CC <- 0 #assign a CC score of 0
  }
  else{
    CC <- CCSemSim$geneSim #The data is organized as a vector with 3 elements so we must extract the scores this way
  }
  if(is.na(CC)){
    CC <- 0 #If the score is NA, assign a score of 0
  }
  else{
    CC <- CC
  }})

BPscore <- apply(genecombo, 1, function(x){ #Calculate BP GO Semantic Similarity Scores over each row (1) of the matrix
  BPSemSim <- geneSim(x[1], x[2], ont = 'BP', organism = 'human', measure = 'Rel', combine = 'BMA')
  if(length(BPSemSim) < 3){ #if a vector of a length < 3 is returned (ie. calculation fails due to lack of GO annotations)
    BP <- 0 #assign a BP score of 0
  }
  else{
    BP <- BPSemSim$geneSim
  }
  if(is.na(BP)){
    BP <- 0 #if BP score is NA, assign a BP score of 0
  }
  else{
    BP <- BP
  }})

RawScores <- cbind(CCscore, BPscore) #combine raw scores into table
GOSEMScore <- rowMeans(RawScores) #calculate average of raw GO Semantic Similarity Score
TOTALGOSEM <- cbind(genecombo, GOSEMScore) #compile table with all gene pairs and GOSEMScores
passthresh <- which(TOTALGOSEM[,'GOSEMScore'] > 0.2) #determines indices of the table (gene pairs) that pass the 0.2 threshold
GOSemSim <- TOTALGOSEM[passthresh,] #produce a table with gene pairs that GO Semantic Similarity threshold