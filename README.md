CUDA Examples
=============

Cuda examples (contrived or found in books) converted to boost::multiarray and
C++ when possible. Should be a cmake file in each subdirectory for building.
I will provide a reference for all examples in books. I will likely start wrapping
functionality into a more useful header file.

Notes
=====

CUDA 7.5 does not play nice with gcc 6! I am using Arch Linux with cuda 7.5
and gcc 5.4 with no issues currently.

Projects
========

* `julia-set` from "CUDA BY EXAMPLE: An Introduction to General-Purpose GPU
   Programming" by Jason Sanders and Edward Kandrot
    - Uses `boost::multi_array`, CUDA, and ImageMagick to construct julia sets
    - If you have all of this installed, should be as simple as:
```
cd julia-set
mkdir build
cd build
cmake -DCMAKE_C_COMPILER=gcc-5 -DCMAKE_CXX_COMPILER=g++-5 ..
make
export OMP_NUM_THREADS=<cpu threads>
./julia-set
```
