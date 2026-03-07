
cmake_minimum_required(VERSION 3.15)
project(hello_fortran VERSION 0.1.0 LANGUAGES Fortran)

set(CMAKE_Fortran_COMPILER gfortran)
set(CMAKE_Fortran_STANDARD 2008)
set(CMAKE_Fortran_STANDARD_REQUIRED ON)

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

# Install target
install(TARGETS hello-fortran
	RUNTIME DESTINATION bin)
