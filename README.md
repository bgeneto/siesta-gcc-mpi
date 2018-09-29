# Purpose 

This document contains step-by-step instructions to proceed with a successfull installation of the SIESTA (Spanish Initiative for Electronic Simulations with Thousands of Atoms) software on Linux (tested with Ubuntu 18.04) using the GCC and OpenMPI tools. 

## Install prerequisite softwares

```
sudo apt install make g++ gfortran openmpi-common openmpi-bin \
  libopenmpi-dev libblacs-mpi-dev libreadline-dev -y
```

## Create siesta install directory

*Note: In what follows, we assume that your user has write permission to the siesta install directory (that's why we use chown/chmod below) and its in sudoers file!*

```
SIESTA_DIR=/opt/siesta
sudo mkdir $SIESTA_DIR
sudo chown -R root:sudo $SIESTA_DIR
sudo chmod -R 775 $SIESTA_DIR
```

## Download and extract siesta from sources

```
cd $SIESTA_DIR
wget https://launchpad.net/siesta/4.1/4.1-b3/+download/siesta-4.1-b3.tar.gz
tar xzf ./siesta-4.1-b3.tar.gz && rm ./siesta-4.1-b3.tar.gz
```

## Install siesta library dependencies

First let's `make` runs in parallel by default to speedup things a little... 

```
alias make='make -j'
```

Now download and install flook:

```
cd ./siesta-4.1-b3/Docs
wget https://github.com/ElectronicStructureLibrary/flook/releases/download/v0.7.0/flook-0.7.0.tar.gz
(./install_flook.bash 2>&1) | tee install_flook.log
```

Install netcdf dependency:

```
wget https://zlib.net/zlib-1.2.11.tar.gz
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.18/src/hdf5-1.8.18.tar.bz2
wget -O netcdf-c-4.4.1.1.tar.gz https://github.com/Unidata/netcdf-c/archive/v4.4.1.1.tar.gz
wget -O netcdf-fortran-4.4.4.tar.gz https://github.com/Unidata/netcdf-fortran/archive/v4.4.4.tar.gz
(./install_netcdf4.bash 2>&1) | tee install_netcdf4.log
```

## Install single-threaded openblas library from sources:

*Note: apt installs a threaded version of openblas by default, I think this is not suitable for this MPI build of siesta.*

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

