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
```

3. Configure build and disable some feature that we don't need to speed-up compilaton time:

```
ccmake ../SimpleITK/SuperBuild
```

Then press `c`. If it complains about about Java just press OK and continue. Then toggle `OFF` the following flags: 

* `BUILD_EXAMPLES`
* `BUILD_TESTING`
*  `WRAP_PYTHON`
*  `WRAP_RUBY`
*  `WRAP_TCL`

Just keep `WRAP_R` toggled `ON`. Then press `c` followed by `g`.

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
# store brain data in an n x p_b matrix
morphometry = ...
# store cognition data in an n x p_c matrix
cognition = ...
res = braincog(morphometry = morphometry, 
               cognition = cognition)
summary(res)
plot(res)
```
