# TFCluster

This library was used for eliminating redundant motif.

This version was optimized by using Rcpp and was desinged for user friendly.

## Usage ##

There's only one function for user to fulfill his/her goal:
```
main(yourMemeFile, yourTomtomFile [,yourResultFile="result.meme"] [,Numclusters=300] [,cuttreeThreshold="75%"] [,BackgroundAFreq=0.25]
			[,BackgroundTFreq=0.25] [,BackgroundCFreq=0.25] [,BackgroundGFreq=0.25])
```
e.g.
```
TFCluster::main("all.meme","tomtom.txt")
```
## Test
for testing the package, just run:
```
testit()
```
