#
# Copyright (C) 1996-2016 The SIESTA group
#  This file is distributed under the terms of the
#  GNU General Public License: see COPYING in the top directory
#  or http://www.gnu.org/copyleft/gpl.txt.
# See Docs/Contributors.txt for a list of contributors.
#
#-------------------------------------------------------------------
# arch.make file for gfortran compiler.
# To use this arch.make file you should rename it to
# arch.make
# or make a sym-link.
# For an explanation of the flags see DOCUMENTED-TEMPLATE.make

.SUFFIXES:
.SUFFIXES: .f .F .o .c .a .f90 .F90

SIESTA_ARCH = x86_64_OMP

INSDIR = /opt

CC = gcc
FPP = $(FC) -E -P -x c
FC = gfortran
FC_SERIAL = gfortran

FFLAGS = -O3 -fexpensive-optimizations -ftree-vectorize -fprefetch-loop-arrays -march=native -fPIC -fopenmp

AR = ar
RANLIB = ranlib

SYS = nag

SP_KIND = 4
DP_KIND = 8
KINDS = $(SP_KIND) $(DP_KIND)

LDFLAGS =
INCFLAGS=
COMP_LIBS =
LIBS =

FPPFLAGS = $(DEFS_PREFIX)-DFC_HAVE_ABORT

# netcdf
INCFLAGS += -I$(INSDIR)/siesta/siesta-4.1-b4/Docs/build/netcdf/4.6.1/include
LDFLAGS += -L$(INSDIR)/siesta/siesta-4.1-b4/Docs/build/zlib/1.2.11/lib -Wl,-rpath=$(INSDIR)/siesta/siesta-4.1-b4/Docs/build/zlib/1.2.11/lib
LDFLAGS += -L$(INSDIR)/siesta/siesta-4.1-b4/Docs/build/hdf5/1.8.21/lib -Wl,-rpath=$(INSDIR)/siesta/siesta-4.1-b4/Docs/build/hdf5/1.8.21/lib
LDFLAGS += -L$(INSDIR)/siesta/siesta-4.1-b4/Docs/build/netcdf/4.6.1/lib -Wl,-rpath=$(INSDIR)/siesta/siesta-4.1-b4/Docs/build/netcdf/4.6.1/lib
LIBS += -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz
COMP_LIBS += libncdf.a libfdict.a
FPPFLAGS += -DCDF -DNCDF -DNCDF_4

# openblas compiled with:
#export COMMON_OPT="-O3 -fexpensive-optimizations -ftree-vectorize -fprefetch-loop-arrays -march=native"
#export CFLAGS="-O3 -fexpensive-optimizations -ftree-vectorize -fprefetch-loop-arrays -march=native"
#export FCOMMON_OPT="-O3 -fexpensive-optimizations -ftree-vectorize -fprefetch-loop-arrays -march=native"
#export FCFLAGS="-O3 -fexpensive-optimizations -ftree-vectorize -fprefetch-loop-arrays -march=native"
#make -j DYNAMIC_ARCH=0 CC=gcc FC=gfortran HOSTCC=gcc BINARY=64 INTERFACE=64 BUILD_RELAPACK=1 \
#  NO_AFFINITY=1 NO_WARMUP=1 USE_OPENMP=0 USE_THREAD=1 NUM_THREADS=32 LIBNAMESUFFIX=openmp
  
LDFLAGS += -L$(INSDIR)/openblas/lib -Wl,-rpath=$(INSDIR)/openblas/lib
LIBS += -lgomp -lopenblas_openmp

# Dependency rules ---------

FFLAGS_DEBUG = -g -O1

# The atom.f code is very vulnerable. Particularly the Intel compiler
# will make an erroneous compilation of atom.f with high optimization
# levels.
atom.o: atom.F
        $(FC) -c $(FFLAGS_DEBUG) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_fixed_F) $<
.c.o:
        $(CC) -c $(CFLAGS) $(INCFLAGS) $(CPPFLAGS) $<
.F.o:
        $(FC) -c $(FFLAGS) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_fixed_F) $<
.F90.o:
        $(FC) -c $(FFLAGS) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_free_F90) $<
.f.o:
        $(FC) -c $(FFLAGS) $(INCFLAGS) $(FCFLAGS_fixed_f) $<
.f90.o:
        $(FC) -c $(FFLAGS) $(INCFLAGS) $(FCFLAGS_free_f90) $<
