#include <Rcpp.h>
using namespace Rcpp;
// [[Rcpp::plugins("cpp14")]]

// [[Rcpp::export]]
auto autoVariableTypeAssign(){
  NumericVector v = {1.0, 2.0, 3.0};
  return(v);
}



