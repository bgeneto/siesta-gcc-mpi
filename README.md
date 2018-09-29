Instructions to install Siesta 4.1-b3 with gnu compilers and openmpi in Linux (tested on Ubuntu 18.04)
------------------------------------------------------------------------------------------


1. Install prerequisites like gfortran, mpi and openblas:

$ sudo apt install make g++ gfortran openmpi-common openmpi-bin libopenmpi-dev \
    libblacs-mpi-dev libnetcdf-dev netcdf-bin libnetcdff-dev libscalapack-mpi-dev \
    libblas-dev liblapack-dev liblapacke-dev libopenblas-* bc at task-spooler -y

2. Create install directory

$ sudo mkdir -p /opt/siesta && cd /opt/siesta

3. Download siesta 4.1-b3

$ sudo wget https://launchpad.net/siesta/4.1/4.1-b3/+download/siesta-4.1-b3.tar.gz

4. Extract siesta-4.1-b3.tar.gz

$ sudo tar xzf ./siesta-4.1-b3.tar.gz
  sudo rm ./siesta-4.1-b3.tar.gz

5. Install flook dependencys:

$ cd ./siesta-4.1-b3/Docs
  sudo wget https://github.com/ElectronicStructureLibrary/flook/releases/download/v0.7.0/flook-0.7.0.tar.gz
  sudo apt-get install libreadline-dev -y
  sudo ./install_flook.bash

6. Take note of arch.make settings

After successfull compilation, take note of the following lines (for example):
Please add the following to the BOTTOM of your arch.make file

INCFLAGS += -I/opt/siesta/siesta-4.1-b3/Docs/build/flook/0.7.0/include
LDFLAGS += -L/opt/siesta/siesta-4.1-b3/Docs/build/flook/0.7.0/lib -Wl,-rpath=/opt/siesta/siesta-4.1-b3/Docs/build/flook/0.7.0/lib
LIBS += -lflookall -ldl
COMP_LIBS += libfdict.a
FPPFLAGS += -DSIESTA__FLOOK

7. Install netcdf dependency:

$ sudo wget https://zlib.net/zlib-1.2.11.tar.gz
  sudo wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.18/src/hdf5-1.8.18.tar.bz2
  sudo wget -O netcdf-c-4.4.1.1.tar.gz https://github.com/Unidata/netcdf-c/archive/v4.4.1.1.tar.gz
  sudo wget -O netcdf-fortran-4.4.4.tar.gz https://github.com/Unidata/netcdf-fortran/archive/v4.4.4.tar.gz
  sudo ./install_netcdf4.bash

8. Take note of arch.make settings again:

After successfull build it outputs lines like this:

INCFLAGS += -I/opt/siesta/siesta-4.1-b3/Docs/build/netcdf/4.4.1.1/include
LDFLAGS += -L/opt/siesta/siesta-4.1-b3/Docs/build/zlib/1.2.11/lib -Wl,-rpath=/opt/siesta/siesta-4.1-b3/Docs/build/zlib/1.2.11/lib
LDFLAGS += -L/opt/siesta/siesta-4.1-b3/Docs/build/hdf5/1.8.18/lib -Wl,-rpath=/opt/siesta/siesta-4.1-b3/Docs/build/hdf5/1.8.18/lib
LDFLAGS += -L/opt/siesta/siesta-4.1-b3/Docs/build/netcdf/4.4.1.1/lib -Wl,-rpath=/opt/siesta/siesta-4.1-b3/Docs/build/netcdf/4.4.1.1/lib
LIBS += -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz
COMP_LIBS += libncdf.a libfdict.a
FPPFLAGS += -DCDF -DNCDF -DNCDF_4

9. Install single-threaded optimized openblas library from sources:
(note that apt installs threaded version by default, not suitable to MPI)

$ sudo mkdir -p /opt/openblas && cd /opt/openblas
$ sudo wget -O OpenBLAS.tar.gz https://ufpr.dl.sourceforge.net/project/openblas/v0.3.3/OpenBLAS%200.3.3%20version.tar.gz
$ sudo tar xzf OpenBLAS.tar.gz
$ sudo rm OpenBLAS.tar.gz
$ cd "$(find . -name xianyi-OpenBLAS*)"

Now build the single threaded library:

$ sudo make -j DYNAMIC_ARCH=0 CC=gcc FC=gfortran HOSTCC=gcc BINARY=64 INTERFACE=64 \
  NO_AFFINITY=1 NO_WARMUP=1 USE_OPENMP=0 USE_THREAD=0

$ sudo make PREFIX=/opt/openblas install

Check if your LD_LIBRARY_PATH is set correctly (e.g. in /etc/bash.bashrc):

\# use our custom single-threaded openblas
export INCLUDE_PATH=/opt/openblas/include:$INCLUDE_PATH
export LD_LIBRARY_PATH=/opt/openblas/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=/opt/openblas/lib:$LIBRARY_PATH

10. Copy your custom arch.make

First create a custom target arch directory:

$ sudo mkdir /opt/siesta/siesta-4.1-b3/ObjMPI && cd /opt/siesta/siesta-4.1-b3/ObjMPI
$ wget github file

11. Finally build siesta

$ cd /opt/siesta/siesta-4.1-b3/ObjMPI
$ sudo sh ../Src/obj_setup.sh
$ sudo make OBJDIR=ObjMPI

