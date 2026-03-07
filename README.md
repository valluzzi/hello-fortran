# hello-fortran
Hello world written in fortran

## Build and install

Build using the provided script (recommended):

```bash
./compile.sh
```

Or with CMake directly:

```bash
mkdir -p build
cmake -S . -B build
cmake --build build --config Release
```

Run the program:

```bash
./build/hello-fortran
```

To install locally into a directory `local_install`:

```bash
cmake --install build --prefix ./local_install
./local_install/bin/hello-fortran
```

To install system-wide (may require privileges):

```bash
cmake --install build --prefix /usr/local
```
