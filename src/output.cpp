
#include <fstream>
#include <iostream>
#include <vector>
#include <string>
#include <exception>
#include <regex>
#include <algorithm>
#include "Rcpp.h"
#include <ctime>
#include <chrono>
#include <sys/time.h>



//namespace TFCluster{
	using namespace Rcpp;
	// [[Rcpp::export]]
	RcppExport double output_(SEXP resultList_, SEXP memeFile_, SEXP outFile_)
	{
		std::chrono::high_resolution_clock::time_point t1 = std::chrono::high_resolution_clock::now();
		std::string memeFile = Rcpp::as<std::string>(memeFile_);
		std::string outFile = Rcpp::as<std::string>(outFile_);
		Rcpp::List resultList(resultList_);
		Rcpp::CharacterVector id;
		for(size_t i=0; i != resultList.size(); ++i)
		{
			Rcpp::NumericVector tmp = Rcpp::as<Rcpp::NumericVector>(resultList[i]);
			Rcpp::CharacterVector tmpName = tmp.names();
			for(size_t j=0; j != tmpName.size(); ++j)
				id.push_back(tmpName[j]);
		}
			
		std::ifstream input(memeFile, std::ifstream::in);
		if(!input)
		{
			throw std::runtime_error(memeFile + " does not exist!\n");
		}else{
			std::ofstream out(outFile, std::ofstream::app);
			std::string line;
//			std::string pattern = "MEME";
//			std::regex r(pattern);
//			std::smatch res;
			while(std::getline(input, line))
			{
//				if(std::regex_search(line, res, r))
//				{
//					line = line + "\n";
//					out.write(line.c_str(), line.size());
//					out.write("Hi\n", 3);
//				}
//				if(line.substr(0, 5) == "MOTIF") break;
				if(line.substr(0,4) == "MEME" ||
					line.substr(0,8) == "ALPHABET" || line.substr(0,7) == "strands")
				{
					line = line + "\n";
					out.write(line.c_str(), line.size());
				}else if(line.substr(0, 5) == "MOTIF")
				{
					break;
				}
			}
		}
		

		std::ofstream out(outFile, std::ofstream::app);
		for(size_t i = 0; i != id.size(); ++i)
		{
			std::string motifIDPattern = "MOTIF " + Rcpp::as<std::string>(id[i]);
//			std::string motifIDPattern(Rcpp::as<std::string>(id[i]));
//			std::regex r(motifIDPattern, std::regex::icase);
			input.seekg(0);
			std::string line;
			std::smatch res;
			bool find = false;
			while(std::getline(input, line, '\n'))
			{
				line = line + "\n";
				if(line.substr(0, motifIDPattern.size()) == motifIDPattern)
				{
					out.write(line.c_str(), line.size());
					while(std::getline(input, line, '\n'))
					{
						line = line + "\n";
						if(line.substr(0,3) == "URL")
						{
							line = line + "\n";
							out.write(line.c_str(), line.size());
							break;
						}else{
							out.write(line.c_str(), line.size());
						}
					
					}
					find = true;
					break;
				}
			}
			if(!find)
			{
				throw std::runtime_error("Loss motif: " + as<std::string>(id[i]) + "\n" );
			}
		}
		std::chrono::high_resolution_clock::time_point t2 = std::chrono::high_resolution_clock::now();
		double dif = std::chrono::duration_cast<std::chrono::seconds>( t2 - t1 ).count();
		return dif;
	}
//}
