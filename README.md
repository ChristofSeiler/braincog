# R package `braincog`

## Installation

Before we can install `braincog` we have to install `SimpleITK`, an R wrapper for [ITK](https://itk.org/). ITK provides the latest and robust medical image processing tools for `d`-dimensional images. This can take a few minutes because we need to compile it from scratch. Here a step-by-step guide:

1. For this to work we also need `cmake` installed and in your system path. On mac we can download frome here. After we succesfully installed `cmake` we need to make it available from the command line:

```
sudo "/Applications/CMake.app/Contents/bin/cmake-gui" --install
```

2. Now we follow the steps from the ITK [wiki](https://itk.org/Wiki/SimpleITK/GettingStarted):

```
git clone https://itk.org/SimpleITK.git
mkdir SimpleITK-build
cd SimpleITK-build
cmake ../SimpleITK/SuperBuild
cd SimpleITK-build/Wrapping/R/Packaging
R CMD INSTALL SimpleITK
```

3. Finally, we are ready to install the package `braincog`:

``` r
install.packages("devtools")
devtools::install_github("ChristofSeiler/braincog")
```

## Getting Started

``` r
library("braincog")
# store brain data in an n x p_b matrix
morphometry = ...
# store cognition data in an n x p_c matrix
cognition = ...
res = braincog(morphometry = morphometry, 
               cognition = cognition)
summary(res)
plot(res)
```
