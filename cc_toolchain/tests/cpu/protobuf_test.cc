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
#include <cassert>
#include <fstream>
#include "cc_toolchain/tests/cpu/protobuf_hello.pb.h"
#include "gtest/gtest.h"

std::string setAndGetName(std::string name) {
  protobuf::HelloRequest request;
  request.set_name(name);

  // Serialize the message to a string
  std::string output;
  request.SerializeToString(&output);

  // Deserialize the message from the string
  protobuf::HelloRequest deserialized_request;
  deserialized_request.ParseFromString(output);

  return deserialized_request.name();
}

TEST(ProtobufTest, ProtobufTest) {
  EXPECT_EQ("Julius", setAndGetName("Julius"));
}