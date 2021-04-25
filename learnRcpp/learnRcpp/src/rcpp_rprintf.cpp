#include <Rcpp.h>
using namespace Rcpp;
// [[Rcpp::export]]
void rcpp_rprintf(NumericVector v){
  // printing values of all the elements of Rcpp vector  
  for(int i=0; i<v.length(); ++i){
    Rprintf("the value of v[%i] : %.2f \n", i, v[i]);
  }
}
