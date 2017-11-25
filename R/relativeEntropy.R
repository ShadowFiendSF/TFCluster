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

relativeEntropy<-function(meme, BA=0.25, BC=0.25, BG=0.25, BT=0.25)
{
	backgroud<-c(BA, BC, BG, BT)
	RE<-function(matrix, backgroud)
	{
		for(i in 1:ncol(matrix))
		{
			matrix[,i] <- ifelse(matrix[,i] <= 0, -Inf, matrix[,i] * log2(matrix[,i]/backgroud[i]))
		}
		return(matrix)
	}
	sumx<-function(x)
	{
		s<-0
		for(i in 1:length(x))
		{
			if(!is.infinite(x[i])) s <-s + x[i]
		}
		return(s)
	}
	seqRE<-function(matrix)
	{
		tmp<-apply(matrix, 1, sumx)
		return(sum(tmp[is.finite(tmp)], na.rm = T))
	}
	siteRE<-lapply(meme, RE, backgroud)
	siteRE<-lapply(siteRE, seqRE)
	return(siteRE)
}
