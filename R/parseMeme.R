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



getcontent<-function(str, pattern)
{
	regex<-regexpr(pattern=pattern, str, perl=T)
	start<-attr(regex,"capture.start")[1]
	if(start != -1)
	{
		stop<-start + attr(regex,"capture.length")[1]-1
		return(as.integer(substr(str, start, stop)))
	}else{
		return(NULL)
	}
}

parsepwm<-function(str)
{
	return(as.numeric(strsplit(str, "\t")[[1]]))
}

parseMeme<-function(filename)
{
	con<-file(filename, open="r")
	result<-list()
	while(length(oneLine<-readLines(con, n=1))>0)
	{
		if(grepl("^MOTIF\\.*", oneLine, perl=T))
		{
#			motif<-gsub(pattern="^MOTIF\\s+", replacement="", x=oneLine, perl=T)
			motif<-unlist(strsplit(oneLine, split="\\s", perl=T))[2]
			while( length(oneLine<-readLines(con, n=1))>0 )
			{
				if(grepl("^(letter-probability|log-odds)", oneLine, perl=T))
				{
					numrow<-getcontent(oneLine, "w=\\s*(\\d+)")
					numcol<-getcontent(oneLine, "alength=\\s*(\\d+)")
					pwm<-matrix(nrow=numrow, ncol=numcol)
					irow<-1
					while( length(oneLine<-readLines(con, n=1))>0 )
					{
						if(oneLine == "" | grepl("^URL.*", oneLine, perl=T))
						{
							if(dim(pwm)[1]!= numrow | dim(pwm)[2]!= numcol)
							{
								close(con)
								stop("parse error or file incompleted!")
							}
							result[[motif]]<-pwm
							break
						}
						pwm[irow,]<-parsepwm(oneLine)
						irow<-irow+1
					}
				}
				if(grepl("^URL.*", oneLine, perl=T)) break
			}
		}
	}
	close(con)
	return(result)
}
