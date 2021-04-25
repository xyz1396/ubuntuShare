#include <Rcpp.h>
using namespace Rcpp;
// [[Rcpp::export]]
void rcpp_rcout(NumericVector v){
  // printing value of vector
  Rcout << "The value of v : " << v << "\n";
  
  // printing error message
  Rcerr << "Error message\n";
}
