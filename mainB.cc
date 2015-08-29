#include <iostream>

#include "A.hh"
#include "B.hh"

#include "ThingFromB.hh"

int main(){
  std::cout << "hi from mainB" << std::endl;
  func_A();
  func_B();

  libB_func(42);
}
