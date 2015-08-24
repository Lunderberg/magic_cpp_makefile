#include "PrintOnStart.hh"

#include <iostream>

PrintOnStart p("hello, from PrintOnStart.cc");

PrintOnStart::PrintOnStart(const char* msg){
  std::cout << msg << std::endl;
}
