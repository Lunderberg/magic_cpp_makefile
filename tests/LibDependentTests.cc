#include <gtest/gtest.h>

#include "LibraryA_func.hh"

TEST(MagicSConstruct, CanRunTests_WithLibs){
  EXPECT_EQ(LibraryA_func(), 7);
}
