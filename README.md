# R package `braincog`

Before we can install `braincog` we have to install `SimpleITK`, an R wrapper for [ITK](https://itk.org/). ITK provides the latest and robust medical image processing tools for `d`-dimensional images. 

## Easy Installation on macOS Sierra

Pre-compiled on macOS Sierra 10.12.6. To install `SimpleITK` package:

```
curl -O https://github.com/ChristofSeiler/SimpleITK_Binaries/raw/master/SimpleITK.zip
unzip SimpleITK.zip
R CMD INSTALL SimpleITK
```

## Installation on Other Systems

This can take a few minutes because we need to compile it from scratch. Here a step-by-step guide for Mac:

1. Install command line developer tools:

```
xcode-select --install
```

2. For this to work we also need `cmake` installed and in your system path. On mac we can download frome here. After we succesfully installed `cmake` we need to make it available from the command line:

```
sudo "/Applications/CMake.app/Contents/bin/cmake-gui" --install
```

3. Now we follow the steps from the `SimpleITK` building [documentation](https://simpleitk.readthedocs.io/en/master/Documentation/docs/source/building.html):

```
git clone https://itk.org/SimpleITK.git
mkdir SimpleITK-build
cd SimpleITK-build
```

4. Configure build and disable some feature that we don't need to speed-up compilaton time:

```
cmake \
-D BUILD_EXAMPLES=OFF \
-D BUILD_TESTING=OFF \
-D WRAP_PYTHON=OFF \
-D WRAP_RUBY=OFF \
-D WRAP_TCL=OFF \
-D WRAP_R=ON \
../SimpleITK/SuperBuild
```

5. Compile (the number indicates how many cores we want to use):

```
make -j4
```

6. Now it's compiled and we can install it in `R`:

```
cd SimpleITK-build/Wrapping/R/Packaging
R CMD INSTALL SimpleITK
```

7. Finally, we are ready to install the package `braincog`:

``` r
install.packages("devtools")
devtools::install_github("ChristofSeiler/braincog")
```

## Getting Started

``` r
library("braincog")
# store brain data in an n x num_voxels matrix
morphometry = ...
# store cognition data in an n x num_tests matrix
cognition = ...
res = braincog(morphometry = morphometry, 
               cognition = cognition)
summary(res)
plot(res)
```
