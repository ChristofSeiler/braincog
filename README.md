# R package `braincog`

## Installation

Before we can install `braincog` we have to install `SimpleITK`, an R wrapper for [ITK](https://itk.org/). ITK provides the latest and robust medical image processing tools for `N`-dimensional images. This can take a few hours because the entire source code need to be compiled from scratch. To speed up you can use multiple cores like this: 

```
devtools::install_github("SimpleITK/SimpleITKRInstaller", args=c('--configure-vars="MAKEJ=4"'))
```

For this to work we also need `cmake` installed and in your system path. On mac we can download frome here. After we succesfully installed `cmake` we need to make it available from the command line:

```
sudo "/Applications/CMake.app/Contents/bin/cmake-gui" --install
```

Now we are ready to install the package `braincog`:

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
```
