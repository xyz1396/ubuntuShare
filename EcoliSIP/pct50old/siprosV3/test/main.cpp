#include "isotopologue.h"

void test_constructor()
{
    cout << "test_constructor" << endl;
    vector<double> vM = {200, 250};
    vector<double> vP = {0.5, 0.5};
    IsotopeDistribution a(vM, vP);
    a.print();
    IsotopeDistribution b(10);
    vector<double> vM2 = {300, 400, 500};
    vector<double> vP2 = {0.3, 0.4, 0.3};
    IsotopeDistribution c(vM2, vP2);
    c = a;
    c.print();
    a.print();
    b = a;
    b.print();
}

void test_filter()
{
    Isotopologue mIsotopologue;
    vector<double> vM = {200, 201, 202, 203};
    vector<double> vP = {1e-10, 0.5, 0.4, 0.003};
    IsotopeDistribution a(vM, vP);
    cout << "\n"
         << "test filter" << endl;
    cout << a.aSize << endl;
    a.filterProbCutoff(0.01);
    cout << a.aSize << endl;
    a.normalize();
    a.print();
}

void test_sum()
{
    cout << "\n"
         << "test_sum" << endl;
    Isotopologue mIsotopologue;
    vector<double> vM = {200, 250};
    vector<double> vP = {0.5, 0.5};
    IsotopeDistribution a(vM, vP);
    IsotopeDistribution b(10);
    vector<double> vM2 = {300, 400, 500};
    vector<double> vP2 = {0.3, 0.4, 0.3};
    IsotopeDistribution c(vM2, vP2);
    b = mIsotopologue.sum(a, c);
    b.print();
    b = mIsotopologue.sum(b, c);
    b.print();
}

void test_multiply()
{
    cout << "\n"
         << "test_multiply" << endl;
    Isotopologue mIsotopologue;
    vector<double> vM = {200, 201, 202};
    vector<double> vP = {0.97, 0.02, 0.01};
    IsotopeDistribution a(vM, vP);
    IsotopeDistribution b = mIsotopologue.multiply(a, 3);
    b.print();
    b = mIsotopologue.multiply(a, -3);
    b.print();
}

void test_computeProductIon()
{
    Isotopologue mIsotopologue;
    vector<vector<double>> mvvdYionMass;
    vector<vector<double>> mvvdYionProb;
    vector<vector<double>> mvvdBionMass;
    vector<vector<double>> mvvdBionProb;
    mIsotopologue.computeProductIon("[NtermSKJHGHGHGHGHGHGHGCterm", mvvdYionMass, mvvdYionProb,
                                    mvvdBionMass, mvvdBionProb);
    
}

int main(int argc, char const *argv[])
{
    test_constructor();
    test_filter();
    test_sum();
    test_multiply();
    // test_computeProductIon();
    return 0;
}
