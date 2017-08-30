# R package `braincog`

Note that installing `SimpleITK` will take a couple of hours. To speed up you can use multiple cores like this: 

```
devtools::install_github("SimpleITK/SimpleITKRInstaller", args=c('--configure-vars="MAKEJ=6"'))
```

For this to work you also need `cmake` installed and in your system path. On mac you can download frome here. After you succesfully installed `cmake` you need to add it you your system path.

```
sudo "/Applications/CMake.app/Contents/bin/cmake-gui" --install
```
