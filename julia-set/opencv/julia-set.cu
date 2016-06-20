#include <boost/multi_array.hpp>
#include <iostream>
#include <omp.h>
#include <opencv2/opencv.hpp>
#include <complex>
#include "cuComplex.h"

using namespace std;
using namespace cv;

// 2D Matrix typedef for pixel_map and the index
// Comment: likely should move this into a namespace
//  like bcuda::vector and bcuda::matrix or something
typedef boost::multi_array<int, 2> pixel_map;
typedef pixel_map::index pixel_map_index;

// Some operator overloads
__device__ __host__ cuDoubleComplex operator+(const cuDoubleComplex &a,
                                              const cuDoubleComplex &b) {
    return cuCadd(a, b);
}
__device__ __host__ cuDoubleComplex operator*(const cuDoubleComplex &a,
                                              const cuDoubleComplex &b) {
    return cuCmul(a, b);
}
__device__ __host__ double norm(const cuDoubleComplex &a) {
    return a.x * a.x + a.y * a.y;
}

__device__ int julia(const int &dimension, const int &x, const int &y) {
    const double scale = 1.5;
    const double jx = scale * static_cast<double>(dimension / 2 - x) /
        static_cast<double>(dimension / 2);
    const double jy = scale * static_cast<double>(dimension / 2 - y) /
        static_cast<double>(dimension / 2);
    cuDoubleComplex c = make_cuDoubleComplex(-0.8, 0.156);
    cuDoubleComplex a = make_cuDoubleComplex(jx, jy);
    for (size_t i = 0; i < 200; ++i) {
        //a = cuCadd(cuCmul(a, a), c);
        a = a * a + c;
        //if ((a.x * a.x + a.y + a.y) > 1000)
        if (norm(a) > 1000)
            return 0;
    }
    return 1;
}

// kernel to operate on pixel_map
__global__ void julia_set(const int *dimension, int *map) {
    const int x = blockIdx.x;
    const int y = blockIdx.y;
    const int offset = x + y * gridDim.x;
    map[offset] = julia(*dimension, x, y);
}

// The main function, we may parse command line
//  at some point for pixel_map size
int main(int argc, char **argv) {
    // Create the Matrix, likely substitute size from command line
    int size = 3000;
    pixel_map map(boost::extents[size][size]);

    // Zero out the pixel_map
#pragma omp parallel for    
    for (pixel_map_index i = 0; i < size; ++i) {
        for (pixel_map_index j = 0; j < size; ++j) {
            map[i][j] = 0;
        }
    }

    // Get the map to dev_map, and size to dev_size on the GPU
    int *dev_map;
    int *dev_size;
    cudaMalloc((void **) &dev_map, map.num_elements() * sizeof(int));
    cudaMalloc((void **) &dev_size, sizeof(int));
    cudaMemcpy(dev_map, &map[0][0], map.num_elements() * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_size, &size, sizeof(int), cudaMemcpyHostToDevice);
    dim3 grid(size, size);
    julia_set<<<grid, 1>>>(dev_size, dev_map);
    cudaMemcpy(&map[0][0], dev_map, map.num_elements() * sizeof(int), cudaMemcpyDeviceToHost);
    cudaFree(dev_map);
    cudaFree(dev_size);

    /*
    for (size_t i = 0; i < size; ++i) {
        for (size_t j = 0; j < size; ++j) {
            cout << i << ' ' << j << ' ' << test_julia(size, i, j) << '\n';
            map[i][j] = 255 * test_julia(size, i, j);
        }
    }
    */

    // Convert to OpenCV Image
    Mat image(size, size, CV_8UC3, Scalar(0, 0, 0));   
#pragma omp parallel for
    for (size_t i = 0; i < size; ++i) {
        for (size_t j = 0; j < size; ++j) {
            // Get color
            Vec3b color = image.at<Vec3b>(Point(i, j));
            // Mod color
            for (size_t k = 0; k < 3; ++k) {
                color[k] = 255 * map[i][j];
            }
            // Set color
            image.at<Vec3b>(Point(i, j)) = color;
        }
    }
    imwrite("julia-set.png", image);

/* CPU Code    
    // Populate pixel_map
#pragma omp parallel for
    for (pixel_map_index i = 0; i < size; ++i) {
        for (pixel_map_index j = 0; j < size; ++j) {
            map[i][j] = static_cast<complex<double> >(i + j) / static_cast<complex<double> >(2 * size);
        }
    }

    // Convert to OpenCV Image
    Mat image(size, size, CV_8UC3, Scalar(0, 0, 0));   
#pragma omp parallel for
    for (size_t i = 0; i < size; ++i) {
        for (size_t j = 0; j < size; ++j) {
            // Get color
            Vec3b color = image.at<Vec3b>(Point(i, j));
            // Mod color
            for (size_t k = 0; k < 3; ++k) {
                color[k] = static_cast<int>(map[i][j].real() * 255);
            }
            // Set color
            image.at<Vec3b>(Point(i, j)) = color;
        }
    }
    imwrite("julia-set.png", image);
 */
    return 0;
}
