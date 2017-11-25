#
#
#
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


cutree2category<-function(x)
{
	tmp<-data.frame(name=names(x), category=x)
	return(tapply(tmp$name, tmp$category, function(x)return(as.vector(x)), simplify=FALSE))
}

getMember<-function(categoryList, relativeEntropyList, threshold="75%")
{
#	tmpfun<-function(x, threshold="75%")
#	{
#		categoryMemberRE <- unlist(`[`(relativeEntropyList, x))
#		return(quantile(categoryMemberRE)[threshold])
#	}
#	thresholdList<-lapply(categoryList, tmpfun, threshold = threshold)
	
	mergeList<-lapply(categoryList, function(x){unlist(`[`(relativeEntropyList, x))})
	thresholdList<-lapply(mergeList, function(x, threshold){quantile(x)[threshold]}, threshold = threshold)
	tmpFun<-function(x, category)
	{
		th<-thresholdList[[category[x]]]
		return(mergeList[[x]][ mergeList[[x]] >= th ])
	}
	result<-lapply(seq_along(mergeList), tmpFun, category=names(mergeList))
	names(result)<-names(mergeList)
	return(result)
}


getDistMat<-function(filename)
{
	mydata <- read.table(filename, header = T, sep = "\t", stringsAsFactors = F, comment.char="")
	numMotif <- length(unique(mydata$X.Query.ID))
	disMat<-matrix(nrow=numMotif, ncol=numMotif)
	rownames(disMat)<-unique(mydata$X.Query.ID)
	colnames(disMat)<-unique(mydata$X.Query.ID)
	for(i in 1:dim(mydata)[1])
	{
		disMat[mydata[i, 1], mydata[i, 2]] <- mydata[i, 6]
	}
	mat <- 10 - log10(as.dist(disMat) + 1e-8)
}

hierarchicalClustering<-function(disMat, k)
{
	clusters <- hclust(disMat, method = "ward.D")
	result<-cutree(clusters, k = k)
	return(result)
}