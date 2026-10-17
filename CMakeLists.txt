
cmake_minimum_required(VERSION 3.15)
project(hello_fortran VERSION 0.1.0 LANGUAGES Fortran)

# Fortran compiler selection
if(DEFINED FORTRAN_COMPILER)
    message(STATUS "Using Fortran compiler: ${FORTRAN_COMPILER}")
    set(CMAKE_Fortran_COMPILER ${FORTRAN_COMPILER})
else()
    # Default to ifort if available
    find_program(IFORT_EXE ifort)
    find_program(GFORTRAN_EXE gfortran)
    if(IFORT_EXE)
        set(CMAKE_Fortran_COMPILER ifort)
        message(STATUS "Using default: ifort")
    elseif(GFORTRAN_EXE)
        set(CMAKE_Fortran_COMPILER gfortran)
        message(STATUS "Using default: gfortran")
    else()
        message(FATAL_ERROR "No Fortran compiler found (ifort or gfortran)")
    endif()
endif()

set(CMAKE_Fortran_STANDARD 2008)
set(CMAKE_Fortran_STANDARD_REQUIRED ON)

# Static runtime so the exe runs without the oneAPI environment
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

# Derive a single project version string
set(PROJECT_VERSION_STR "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
set(PROJECT_VERSION "${PROJECT_VERSION_STR}")

# Try to get current git commit (short); fall back to 'unknown'
execute_process(COMMAND git rev-parse --short HEAD
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
	OUTPUT_VARIABLE GIT_COMMIT
	OUTPUT_STRIP_TRAILING_WHITESPACE
	ERROR_QUIET)
if(NOT GIT_COMMIT)
	set(GIT_COMMIT "unknown")
endif()

# Build date in UTC (ISO 8601)
execute_process(COMMAND date -u +%Y-%m-%dT%H:%M:%SZ
	OUTPUT_VARIABLE BUILD_DATE
	OUTPUT_STRIP_TRAILING_WHITESPACE
	ERROR_QUIET)
if(NOT BUILD_DATE)
	set(BUILD_DATE "unknown")
endif()

# Configure version.f90 from version.in
set(VERSION_IN ${CMAKE_SOURCE_DIR}/version.in)
set(VERSION_F90 ${CMAKE_BINARY_DIR}/version.f90)
configure_file(${VERSION_IN} ${VERSION_F90} @ONLY)

file(GLOB_RECURSE SRC_SOURCES CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/src/*.f90")
list(APPEND SRC_SOURCES ${VERSION_F90})
add_executable(hello-fortran ${SRC_SOURCES})

# Set output directory to project root
set_target_properties(hello-fortran PROPERTIES
	RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}")

# Install target
install(TARGETS hello-fortran
	RUNTIME DESTINATION bin)
