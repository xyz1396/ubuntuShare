#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
double forCycleInRStyle(NumericVector v){
  double sum = 0;
  for(auto x : v){
    sum += x;
  }
  return(sum);
}