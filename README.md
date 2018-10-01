## 0. Purpose 

This document contains step-by-step instructions to proceed with a (hopefully) successful installation of the SIESTA (Spanish Initiative for Electronic Simulations with Thousands of Atoms) software on Linux (tested with Ubuntu 18.04) using the GCC and OpenMPI tools for parallelism. 

To achieve a parallel build of SIESTA you should ﬁrst determine which type of parallelism you need. It is advised to use MPI for calculations with a moderate number of cores. For hundreds of threads, hybrid parallelism using both MPI and OpenMP may be required.

## 1. Install prerequisite software

*Note: We assume you are running all the commands below as an ordinary user (non-root), so we use `sudo` when required. That's because `mpirun` does NOT like to be executed as root.*

```
sudo apt install make g++ gfortran openmpi-common openmpi-bin \
  libopenmpi-dev libblacs-mpi-dev libreadline-dev m4 -y
```

## 2. Create required installation folders

```
SIESTA_DIR=/opt/siesta
OPENBLAS_DIR=/opt/openblas
SCALAPACK_DIR=/opt/scalapack 

mkdir $SIESTA_DIR $OPENBLAS_DIR $SCALAPACK_DIR
```

## 3. Install prerequisite libraries 

In order to run siesta in parallel using MPI you need non-threaded blas and lapack libraries along with a standard scalapack library.

#### 3.1. Install single-threaded openblas library from source

*Note: apt installs a threaded version of openblas by default, I think this is not suitable for this MPI build of siesta.*

```
cd $OPENBLAS_DIR
wget -O OpenBLAS.tar.gz https://ufpr.dl.sourceforge.net/project/openblas/v0.3.3/OpenBLAS%200.3.3%20version.tar.gz
tar xzf OpenBLAS.tar.gz && rm OpenBLAS.tar.gz
cd "$(find . -name xianyi-OpenBLAS*)"
make DYNAMIC_ARCH=0 CC=gcc FC=gfortran HOSTCC=gcc BINARY=64 INTERFACE=64 \
  NO_AFFINITY=1 NO_WARMUP=1 USE_OPENMP=0 USE_THREAD=0
make PREFIX=$OPENBLAS_DIR install  
```

#### 3.2. Install scalapack from source

```
cd $SCALAPACK_DIR
wget http://www.netlib.org/scalapack/scalapack_installer.tgz
tar xzf ./scalapack_installer.tgz && cd ./scalapack_installer
./setup.py --prefix $SCALAPACK_DIR --blaslib=$OPENBLAS_DIR/lib/libopenblas.a \
  --lapacklib=$OPENBLAS_DIR/lib/libopenblas.a --mpibindir=/usr/bin \
  --mpiincdir=/usr/lib/x86_64-linux-gnu/openmpi/include
```

*Note: Answer 'b' if asked: 'Which BLAS library do you want to use ?'*


## 4. Install siesta from source

```
cd $SIESTA_DIR
wget https://launchpad.net/siesta/4.1/4.1-b3/+download/siesta-4.1-b3.tar.gz
tar xzf ./siesta-4.1-b3.tar.gz && rm ./siesta-4.1-b3.tar.gz
```

#### 4.1. Install siesta library dependencies from source

Install the fortran-lua-hook library (flook) is **optional** (but fast and easy):

```
cd $SIESTA_DIR/siesta-4.1-b3/Docs
wget https://github.com/ElectronicStructureLibrary/flook/releases/download/v0.7.0/flook-0.7.0.tar.gz
(./install_flook.bash 2>&1) | tee install_flook.log
```

Install netcdf dependency is required (and slow, be patient):

```
cd $SIESTA_DIR/siesta-4.1-b3/Docs
wget https://zlib.net/zlib-1.2.11.tar.gz
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.18/src/hdf5-1.8.18.tar.bz2
wget -O netcdf-c-4.4.1.1.tar.gz https://github.com/Unidata/netcdf-c/archive/v4.4.1.1.tar.gz
wget -O netcdf-fortran-4.4.4.tar.gz https://github.com/Unidata/netcdf-fortran/archive/v4.4.4.tar.gz
(./install_netcdf4.bash 2>&1) | tee install_netcdf4.log
```

If anything goes wrong in this step you can check the `install_netcdf4.log` log file.

#### 4.2. Create your custom 'arch.make' file for GCC + MPI build 

First create a custom target arch directory:

```
cd $SIESTA_DIR/siesta-4.1-b3/Obj
wget -O arch.make https://raw.githubusercontent.com/bgeneto/siesta4.1-gnu-openmpi/master/gnu-openmpi-arch.make
```

#### 4.3. Build siesta executable 

```
cd $SIESTA_DIR/siesta-4.1-b3/Obj
sh ../Src/obj_setup.sh
make OBJDIR=Obj
```

## 5. Test siesta

Choose some random test job to run, e.g.:

```
cd $SIESTA_DIR/siesta-4.1-b3/Tests/h2o_dos/
make
```

We should see the following message:
```
===> SIESTA finished successfully
```

