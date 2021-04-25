#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector rccpLambda(NumericVector v){
  double A =2.0;
  NumericVector res =sapply(v, [&](double x){return A*x;});
  return res ;
}