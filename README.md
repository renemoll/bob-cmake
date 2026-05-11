# bob-cmake

Accompanying project for [bob](https://github.com/renemoll/bob).

## Intention

This project provides (common) CMake logic for building C++ projects for both embedded and PC targets.

Status:
 - Program language support for C and C++;
 - Compiler support: GCC and Clang;
 - Target support: PC, ARM Cortex-M4/7.
 - Supports for building with sanitizers and code coverage generation.


## Development

This project uses `cmake-lint` for linting, run:

```bash
cmake-lint */*.cmake *.cmake
```
