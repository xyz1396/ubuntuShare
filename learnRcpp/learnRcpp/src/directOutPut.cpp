#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
void directOutPut(NumericVector v){
  Rcout << "the value of v : " << v << "\n";
  Rcerr << "ERRO \n ";
}
