//#include "first_library.h"
#include "second_library.h"

#include <iostream>
#include <fstream>
#include <string>

#include "gmock/gmock.h"
#include "gtest/gtest.h"

#ifdef _WIN32
#include <io.h>
#include <windows.h>

std::string get_current_dir() {
  char buffer[MAX_PATH];
  // GetCurrentDirectory returns the length of the string copied
  DWORD length = GetCurrentDirectoryA(MAX_PATH, buffer);

  if (length == 0) {
    return "Error retrieving directory";
  }
  return std::string(buffer);
}

void listFiles(std::string path) {
  struct _finddata_t fileinfo;
  // We add *.* to the path to look for all files
  intptr_t handle = _findfirst((path + "\\*.*").c_str(), &fileinfo);

  if (handle != -1) {
    do {
      std::cout << fileinfo.name <<  (fileinfo.attrib & _A_SUBDIR ? " [DIR]" : "") << std::endl;
    } while (_findnext(handle, &fileinfo) == 0);

    _findclose(handle);
  } else {
    std::cerr << "Could not open directory." << std::endl;
  }
}
#endif

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

#ifdef _WIN32
  std::cout << "Current directory: " << get_current_dir() << std::endl;
  std::string path = ".";
  std::cout << "List directory " << path << std::endl;
  listFiles(path);

  path += "/..";
  std::cout << "List directory " << path << std::endl;
  listFiles(path);

  path += "/..";
  std::cout << "List directory " << path << std::endl;
  listFiles(path);

  path += "/..";
  std::cout << "List directory " << path << std::endl;
  listFiles(path);

  path += "/..";
  std::cout << "List directory " << path << std::endl;
  listFiles(path);

  path += "/..";
  std::cout << "List directory " << path << std::endl;
  listFiles(path);

  path += "/..";
  std::cout << "List directory " << path << std::endl;
  listFiles(path);
#endif

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

