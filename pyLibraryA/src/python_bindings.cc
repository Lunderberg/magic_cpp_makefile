#include "LibraryA_func.hh"

#include "pybind11/pybind11.h"

namespace py = pybind11;

PYBIND11_PLUGIN(LibraryA) {
  py::module m("LibraryA", "Description");

  m.def("LibraryA_func",LibraryA_func);

  return m.ptr();
}
