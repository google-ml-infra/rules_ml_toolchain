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

#include "pybind11/pybind11.h"

std::string get_proto() {
    std::string proto = "syntax = \"proto3\";\n";

    proto.append("package protobuf;\n");
    proto.append("message HelloRequest {\n");
    proto.append("\tstring name = 1;\n");
    proto.append("\tint32 age = 2;\n");
    proto.append("}\n");
    proto.append("message HelloReply {\n");
    proto.append("\tstring message = 1;\n");
    proto.append("};\n");

    return proto;
}

//int hash_code(int a) {
//    int start = 12;
//    return 31 * start + a;
//}

PYBIND11_MODULE(protogen, m) {
    m.doc() = "pybind11 proto generator plugin";
    m.def("get_proto", &get_proto, "Generates content of proto file");
    //m.def("hash_code", &hash_code, "The first function");
}
