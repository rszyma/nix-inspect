#include <iostream>
#include <nlohmann/json.hpp>
#include <nlohmann/json_fwd.hpp>
#include <ostream>

#include "inspector.hh"

int main() {
  init_nix_inspector();
  std::string expr;
  getline(std::cin, expr);
  auto inspector = NixInspector(expr);
  std::string data;
  while (getline(std::cin, data)) {
    try {
      auto value = inspector.inspect(data);
      nlohmann::json out = {
          {"type", std::to_string(value->type())},
          {"data", inspector.v_repr(*value)}
      };
      std::cout << out << std::endl;
    } catch (const std::exception& ex) {
      // "999" is our own tag for "the worker threw" (bad attr path, eval
      // error, ...). Real type tags are small enum numbers, so it cannot
      // collide with any of them.
      nlohmann::json out = {{"type", "999"}, {"data", ex.what()}};
      std::cout << out << std::endl;
    } catch (...) {
      std::cout << "error" << std::endl;
    }
  }
  return 0;
}
