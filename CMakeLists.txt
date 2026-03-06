cmake_minimum_required(VERSION 3.15)
project(hello_fortran LANGUAGES Fortran)

set(CMAKE_Fortran_COMPILER gfortran)
set(CMAKE_Fortran_STANDARD 2008)
set(CMAKE_Fortran_STANDARD_REQUIRED ON)

add_executable(hello src/main.f90)
