#include <boost/multi_array.hpp>
#include <omp.h>
#include <opencv2/opencv.hpp>

// 2D Matrix typedef for pixel_map and the index
// Comment: likely should move this into a namespace
//  like bcuda::vector and bcuda::matrix or something
typedef boost::multi_array<double, 2> pixel_map;
typedef pixel_map::index pixel_map_index;

using namespace std;
using namespace cv;

// The main function, we may parse command line
//  at some point for pixel_map size
int main(int argc, char **argv) {
    // Create the Matrix, likely substitute size from command line
    int size = 3000;
    pixel_map map(boost::extents[size][size]);

    // Populate pixel_map
#pragma omp parallel for
    for (pixel_map_index i = 0; i < size; ++i) {
        for (pixel_map_index j = 0; j < size; ++j) {
            map[i][j] = static_cast<double>(i + j) / static_cast<double>(2 * size);
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
                color[k] = static_cast<int>(map[i][j] * 255);
            }
            // Set color
            image.at<Vec3b>(Point(i, j)) = color;
        }
    }
    imwrite("julia-set.png", image);
    return 0;
}
