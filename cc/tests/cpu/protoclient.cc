/* Copyright 2025 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
============================================================================== */

#include <iostream>
#include "pybind11/pybind11.h"
#include "cc/tests/cpu/my.pb.h"

std::string echo_name(std::string words) {
    if(words.empty()) {
      words = "Unknown";
    }

    protobuf::HelloRequest request;
    request.set_name(words);

    // Serialize the message to a string
    std::string output;
    request.SerializeToString(&output);

    // Deserialize the message from the string
    protobuf::HelloRequest deserialized_request;
    deserialized_request.ParseFromString(output);

    //std::cout << "Say, " << deserialized_request.name() << "!" << std::endl;
    return deserialized_request.name();
}

std::string say_hello(std::string name) {
    return "Hello, " + echo_name(name);
}

PYBIND11_MODULE(protoclient, m) {
    m.def("say_hello", &say_hello, "Adds 'Hello' before your name");
}
