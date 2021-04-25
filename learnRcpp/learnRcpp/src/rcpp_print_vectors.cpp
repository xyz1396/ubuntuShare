#include <Rcpp.h>
using namespace Rcpp;
// [[Rcpp::plugins("cpp11")]]

//Create a Vector object equivalent to
// v <- rep(0, 3)
NumericVector v1 (3);

// v <- rep(1.2, 3)
// NumericVector不加小数点编译报错 IntegerVector不用加小数点
NumericVector v2 (3,1.2);

// v <- c(1,2,3) 
// C++11 Initializer list
NumericVector v3 = {1,2,3}; 

// v <- c(1,2,3)
NumericVector v4 = NumericVector::create(1,2,3);

// v <- c(x=1, y=2, z=3)
NumericVector v5 =
  NumericVector::create(Named("x",1), Named("y")=2 , _["z"]=3);

// [[Rcpp::export]]
void rcpp_print_vectors(){
  Rcout << "v1=" << v1 << "\n"
        << "v2=" << v2 << "\n" 
        << "v3=" << v3 << "\n"
        << "v4=" << v4 << "\n"
        << "v5=" << v5 << "\n";
}