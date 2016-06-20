CUDA Examples
=============

Cuda examples (contrived or found in books) using boost::multiarray and C++11
when possible. Should be a cmake file in each subdirectory for building.  I
will provide a reference for all examples in books. I will likely start
wrapping functionality into a more useful header file.

Notes
=====

* CUDA 7.5 does not play nice with gcc 6! I am using Arch Linux with cuda 7.5
  and gcc 5.4 with no issues currently (I will update to cuda 8 and gcc 6 when
possible)
* Why boost::multi_array? Well, it is a c++ container which supports
  N-dimensional tensors (with slicing) and plays nicely with other libraries
(see
[barrymoo/multi-array-testing](https://github.com/barrymoo/multi-array-testing))

Projects
========

* `julia-set` from "CUDA BY EXAMPLE: An Introduction to General-Purpose GPU
   Programming" by Jason Sanders and Edward Kandrot
    - Uses `boost::multi_array`, CUDA, and OpenCV (or ImageMagick, slower) to
      construct julia sets
    - Currently prints a black and white very simple Julia Set (took me a bit
      to get everything working together and playing nicely)
    - If you have all of this installed, should be as simple as:
```
cd julia-set/opencv
mkdir build
cd build
cmake -DCMAKE_C_COMPILER=gcc-5 -DCMAKE_CXX_COMPILER=g++-5 ..
make
export OMP_NUM_THREADS=<cpu threads>
./julia-set
```
