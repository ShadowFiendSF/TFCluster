#
# This script was used for eliminating redundant motif
#
# Author:        Ryan Lee
# Date: 2017/10/16
# 1. determined pairwise motif similarity using the TOMTOM program
# 2. compiled a pseudo-distance matrix
# 3. 10 - log10-transformed TOMTOM q value
#
# @param memeFile meme file
# @param tomtomFile tomtom format filename
# @param BA, BC, BG, BT genome backgroud A, C, G, T frequency
# @param threshold q value quantile by default "75%"
#
#
##########################################################################
###################R version function#####################################
#############anothor Cpp version for better performance###################
#output <- function(resultList, memeFile, outputFile="result.meme")
#{
#	con<-file(memeFile, open="r")
#	out<-file(outputFile, open="wt")
#	while(length(oneLine<-readLines(con, n=1))>0)
#	{
#		if(grepl("^(MEME|ALPHABET|strands)", oneLine, perl=T))
#		writeLines(oneLine, out, sep = "\n\n")
#		if(grepl("^MOTIF\\.*", oneLine, perl=T)) break
#	}
#	
#	print_meme<-function(x, con = con)
#	{
#		motifID <- names(x)
#		motifID<-paste("^MOTIF", motifID, sep=" ")
#		for(i in 1:length(motifID))
#		{
#			seek(con, where = 0, origin = "start", rw = "read")
#			while(length(oneLine<-readLines(con, n=1))>0)
#			{
#				find <- FALSE
#				if(grepl(motifID[i], oneLine, perl=T))
#				{
#					writeLines(oneLine, out, sep = "\n")
#					while(length(oneLine<-readLines(con, n=1))>0)
#					{
#						if(grepl("^(URL)", oneLine, perl=T))
#						{
#							writeLines(oneLine, out, sep = "\n\n")
#							break
#						}else{
#							writeLines(oneLine, out, sep = "\n")
#						}
#					}
#					find <- TRUE
#					break
#				}
#			}
#			if(!find) stop("Loss motif!\n")
#		}
#	}
#	
#	lapply(resultList, print_meme, con = con)
#	
#	close(con)
#	close(out)
#}


.output<-function(resultList, memeFile, outputFile="result.meme")
{
	if(!is.list(resultList) && !is.character(memeFile) && !is.character(outputFile))
		stop("ParamterTypeError!")
	if(length(memeFile)!=1 && length(outputFile)!=1)
		stop("FileParamError!")
	if(length(resultList)==0)
		stop("ResultListLengthError!")
	.Call("output_", resultList, memeFile, outputFile)
}







main<-function(memeFile, tomtomFile, outputFile="result.meme", Numclusters = 300, threshold = "75%", BA=0.25, BC=0.25, BG=0.25, BT=0.25)
{

	disMat <- getDistMat(filename = tomtomFile)
	message("Compiled Distance Matrix!")
	clusterRes <- hierarchicalClustering(disMat = disMat, k = Numclusters)
	categoryList <- cutree2category(clusterRes)
	
	memeList <- parseMeme(filename = memeFile)
	relativeEntropyList <- relativeEntropy(meme=memeList, BA=BA, BC=BC, BG=BG, BT=BT)
	message("Computation of relative Entropy Completed! ")
	result<-getMember(categoryList=categoryList, relativeEntropyList=relativeEntropyList ,threshold=threshold)
	.output(result, memeFile)
	message(paste("Result is ", outputFile))
	return(result)
}
testit<-function()
{
	result<-TFCluster::main("/data2/lizhaohong/motifAnalysis/all.meme","/data2/lizhaohong/motifAnalysis/tomtom_output_files_thresh1/tomtom.txt")
	localE<-new.env()
	attr(localE, "name")<-"testit"
	assign("sum", 0, envir=localE)
	lapply(result,function(x)
		  		 {
		   			tmpsum <- get("sum", envir = localE)
				 	tmpsum <- tmpsum + length(x)
					assign("sum", tmpsum, envir = localE)
		   		}
		   )
	message(paste("The number of TF: ", get("sum", envir = localE),"!",sep=""))
	con<-file("result.meme", open="r")
	total <- 0
	while(length(oneLine<-readLines(con, n=1))>0)
	{
		if(grepl("^MOTIF\\.*", oneLine, perl=T)) total <- total + 1
	}
	message(paste("The number of TF: ", total,"!",sep=""))
	close(con)
#	unlink("result.meme")
	if(total == get("sum", envir=localE))
	   	message("Pass the test!")
	else 
		stop("Test failed!")
}
