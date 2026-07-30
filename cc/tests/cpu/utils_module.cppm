module;

#include <string>
#include <vector>

#include "absl/algorithm/algorithm.h"
#include "absl/strings/str_split.h"
#include "absl/container/flat_hash_map.h"

export module UtilsModule;

export int add(int a, int b) {
    return a + b;
}

export std::string concat_strings(const std::string &a, const std::string &b) {
    return a + b;
}

export std::vector<std::string> split_string(std::string str, char delimiter) {
    std::vector<std::string> splitted = absl::StrSplit(str, delimiter);
    return splitted;
}

export void sort(std::vector<int>& nums) {
    absl::c_sort(nums);
}

export template <typename MapType>
const std::string& value_at(const MapType& map, int key) {
    return map.at(key);
}
