//#include "first_library.h"
#include "second_library.h"

#include <iostream>
#include <fstream>
#include <string>

#include "gmock/gmock.h"
#include "gtest/gtest.h"

std::string read_file(const std::string& filename) {
  std::ifstream file(filename);
  std::stringstream buffer;
  buffer << file.rdbuf();
  return buffer.str();
}

TEST(CommonLibraryTest, CommonLibraryTest) {
//  std::cout << "1: first_func" << std::endl;
//  EXPECT_EQ(first_func(1), 2);
  std::cout << "2: second_func" << std::endl;
  EXPECT_EQ(second_func(1), 1);
//  std::cout << "4: first_func" << std::endl;
//  EXPECT_EQ(first_func(1), 4);
  std::cout << "5: second_func" << std::endl;
  EXPECT_EQ(second_func(1), 2);
  std::cout << "7: second_global_func" << std::endl;
  EXPECT_EQ(second_global_func(), 1);
  std::cout << "8: second_global_func" << std::endl;
  EXPECT_EQ(second_global_func(), 1);

  std::cout << "9: binary resource size" << std::endl;
#ifdef _WIN32
  EXPECT_TRUE(!read_file("data/data_binary.exe").empty());
#else
  EXPECT_TRUE(!read_file("data/data_binary").empty());
#endif // _WIN32
  std::cout << "10: data/static_resource" << std::endl;
  EXPECT_EQ(read_file("data/static_resource.txt"),
            "A static resource file under data dir");
  std::cout << "11: pybind/static_resource.txt" << std::endl;
  EXPECT_EQ(read_file("pybind/static_resource.txt"),
            "A static resource file under pybind dir");
}

