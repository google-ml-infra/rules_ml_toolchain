//#include "first_library.h"
#include "second_library.h"

#include <iostream>
#include <filesystem>
#include <experimental/filesystem>
#include <fstream>
#include <string>

#include "gmock/gmock.h"
#include "gtest/gtest.h"

namespace fs = std::experimental::filesystem;

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

  std::cout << "List directories" << std::endl;
  std::string path = ".";
  try {
    for (const auto& entry : fs::directory_iterator(path)) {
      std::cout << entry.path().filename() << std::endl;
    }
  } catch (const fs::filesystem_error& e) {
    std::cerr << "Error: " << e.what() << std::endl;
  }

  std::cout << "9: binary resource size" << std::endl;
#ifdef _WIN32
  EXPECT_TRUE(!read_file("py/rules_pywrap/tests/data/data_binary.exe").empty());
#else
  EXPECT_TRUE(!read_file("py/rules_pywrap/tests/data/data_binary").empty());
#endif // _WIN32
  std::cout << "10: py/rules_pywrap/tests/data/static_resource" << std::endl;
  EXPECT_EQ(read_file("py/rules_pywrap/tests/data/static_resource.txt"),
            "A static resource file under data dir");
  std::cout << "11: py/rules_pywrap/tests/static_resource.txt" << std::endl;
  EXPECT_EQ(read_file("py/rules_pywrap/tests/static_resource.txt"),
            "A static resource file under pybind dir");
}

