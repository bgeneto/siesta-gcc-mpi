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

SIESTA_ARCH = x86_64_MPI

CC = mpicc
FPP = $(FC) -E -P -x c
FC = mpif90
FC_SERIAL = gfortran

# MPI setup
MPI_INTERFACE = libmpi_f90.a
MPI_INCLUDE = .

FFLAGS = -O2 -fPIC -ftree-vectorize

AR = ar
RANLIB = ranlib

SYS = nag

SP_KIND = 4
DP_KIND = 8
KINDS = $(SP_KIND) $(DP_KIND)

LDFLAGS =
INCFLAGS=

# cleared: we are using our own openblas implementation of lapack
#COMP_LIBS =

FPPFLAGS = $(DEFS_PREFIX)-DFC_HAVE_ABORT
# MPI requirement:
FPPFLAGS += -DMPI

LIBS =

# flook
INCFLAGS += -I/opt/siesta/siesta-4.1-b3/Docs/build/flook/0.7.0/include
LDFLAGS += -L/opt/siesta/siesta-4.1-b3/Docs/build/flook/0.7.0/lib -Wl,-rpath=/opt/siesta/siesta-4.1-b3/Docs/build/flook/0.7.0/lib
LIBS += -lflookall -ldl
COMP_LIBS += libfdict.a
FPPFLAGS += -DSIESTA__FLOOK

# netcdf
INCFLAGS += -I/opt/siesta/siesta-4.1-b3/Docs/build/netcdf/4.4.1.1/include
LDFLAGS += -L/opt/siesta/siesta-4.1-b3/Docs/build/zlib/1.2.11/lib -Wl,-rpath=/opt/siesta/siesta-4.1-b3/Docs/build/zlib/1.2.11/lib
LDFLAGS += -L/opt/siesta/siesta-4.1-b3/Docs/build/hdf5/1.8.18/lib -Wl,-rpath=/opt/siesta/siesta-4.1-b3/Docs/build/hdf5/1.8.18/lib
LDFLAGS += -L/opt/siesta/siesta-4.1-b3/Docs/build/netcdf/4.4.1.1/lib -Wl,-rpath=/opt/siesta/siesta-4.1-b3/Docs/build/netcdf/4.4.1.1/lib
LIBS += -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz
COMP_LIBS += libncdf.a libfdict.a
FPPFLAGS += -DCDF -DNCDF -DNCDF_4

# openblas
LIBS += -L/opt/openblas/lib -lopenblas

# ScaLAPACK (required only for MPI build)
LIBS += -L/opt/scalapack/lib -lscalapack

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
