cmake_minimum_required (VERSION 3.3.0)

# We need Boost multiarray
find_package(Boost)
if(NOT ${Boost_FOUND})
    message(FATAL_ERROR "boost::multi_array required for these tests!")
endif(NOT ${Boost_FOUND})
include_directories(${Boost_INCLUDE_DIRS})

# OpenMP Tests
find_package(OpenMP)
if(NOT ${OPENMP_FOUND})
    message(WARNING "Couldn't find OpenMP, some functionality likely slower")
else()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
endif()

# Need CUDA
find_package(CUDA)
if(NOT ${CUDA_FOUND})
    message(FATAL_ERROR "Couldn't find CUDA!")
endif()

# Need ImageMagick
find_package(ImageMagick COMPONENTS Magick++)
if(NOT ${ImageMagick_Magick++_FOUND})
    message(FATAL_ERROR "Couldn't find Magick++!")
else()
    include_directories(${ImageMagick_INCLUDE_DIRS})
endif()

# Compile the project
set(project_name julia-set)
cuda_add_executable(${project_name} ${project_name}.cu)
target_link_libraries(${project_name} ${ImageMagick_LIBRARIES})
