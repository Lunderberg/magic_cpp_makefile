#include <gtest/gtest.h>

#include "A.hh"

TEST(MagicSConstruct, CanRunTests_FromBaseDir){
  EXPECT_EQ(second_func_A(), 42);
}
