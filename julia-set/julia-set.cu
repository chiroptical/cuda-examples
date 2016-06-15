#include <boost/multi_array.hpp>
#include <omp.h>
#include <Magick++.h>

// 2D Matrix typedef for pixel_map and the index
// Comment: likely should move this into a namespace
//  like bcuda::vector and bcuda::matrix or something
typedef boost::multi_array<double, 2> pixel_map;
typedef pixel_map::index pixel_map_index;

using namespace std;
using namespace Magick;

// The main function, we may parse command line
//  at some point for pixel_map size
int main(int argc, char **argv) {
    InitializeMagick(*argv);

    // Create the Image, likely substitute size
    int size = 3000;
    Geometry geometry(size, size);
    ColorRGB background(1.0, 1.0, 1.0);
  	Image image(geometry, background); 

    // Initialize color variable
    ColorRGB color;
    double value;
#pragma omp parallel for private(color, value)
    for (size_t i = 0; i < size; ++i) {
        for (size_t j = 0; j < size; ++j) {
            value = static_cast<double>(i + j) / static_cast<double>(2 * size);
            color.red(value);
            color.green(value);
            color.blue(value);
// Needs critical here, image is tender
#pragma omp critical
{
            image.pixelColor(i, j, color); 
}
        }
    }

  	image.write("julia-set.png"); 
    return 0;
}
