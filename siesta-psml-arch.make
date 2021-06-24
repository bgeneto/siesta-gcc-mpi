#
SIESTA_ARCH=Master-template

# Machine specific settings might be:
#
# 1. Inherited from environmental variables
#    (paths, libraries, etc)
# 2. Set from a 'fortran.mk' file that is
#    included below (compiler names, flags, etc) (Uncomment first)

#--------------------------------------------------------
# Use these symbols to request particular features
# To turn on, set '=1'.
#--------------
# These are mandatory for PSML and MaX Versions,
# but they should be turned off for 4.1
WITH_PSML=1
WITH_GRIDXC=1
#-------------

WITH_EXTERNAL_ELPA=0
WITH_ELSI=0
WITH_FLOOK=0
WITH_MPI=1
WITH_NETCDF=0
WITH_SEPARATE_NETCDF_FORTRAN=0
WITH_NCDF=0
WITH_NCDF_PARALLEL=0
WITH_LEGACY_GRIDXC_INSTALL=0
WITH_GRID_SP=0

#===========================================================
# Make sure you have the appropriate library symbols
# (Either explicitly here, or through shell variables, perhaps
#  set by a module system)
# Define also compiler names and flags
#--------------------------------------------------------
XMLF90_ROOT=/opt/xmlf90
PSML_ROOT=/opt/libpsml
GRIDXC_ROOT=/opt/libgridxc
#ELSI_ROOT=
#ELPA_ROOT=
#ELPA_INCLUDE_DIRECTORY=
#FLOOK_ROOT=
#--------------------------------------------------------
#NETCDF_ROOT=$(NETCDF_HOME)
#NETCDF_FORTRAN_ROOT=$(NETCDF_HOME)
#HDF5_LIBS=-L/apps/HDF5/1.8.20/GCC/OPENMPI/lib -lhdf5_hl -lhdf5 -lcurl -lz
LDFLAGS += -L/opt/scalapack/lib -Wl,-rpath=/opt/scalapack/lib
SCALAPACK_LIBS=-lscalapack
LDFLAGS += -L/opt/openblas/lib -Wl,-rpath=/opt/openblas/lib
LAPACK_LIBS=-lopenblas_nonthreaded
#LAPACK_LIBS=-llapack -lblas
#FFTW_ROOT=/apps/FFTW/3.3.8/GCC/OPENMPI/
# Needed for PEXSI (ELSI) support
#LIBS_CPLUS=-lstdc++ -lmpi_cxx
#--------------------------------------------------------

FC_PARALLEL=mpif90
FC_SERIAL=gfortran
FPP = $(FC_SERIAL) -E -P -x c
FFLAGS = -O2 -fallow-argument-mismatch 
FFLAGS_DEBUG= -g -O0
RANLIB=echo

# Alternatively, prepare a fortran.mk file with compiler definitions,
# put it in this same directory, and uncomment the two lines below
#
#SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
#include $(SELF_DIR)fortran.mk
#===========================================================

# Possible section on specific recipes for troublesome files, using
# a lower optimization level.
#
#atom.o: atom.F
#	$(FC) -c $(FFLAGS_DEBUG) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_fixed_F) $< 
#state_analysis.o: 
#create_Sparsity_SC.o:

# Note that simply using target-specific variables, such as:
#atom.o: FFLAGS=$(FFLAGS_DEBUG)
# would compile *all* dependencies of atom.o with that setting...

#----------------------------------------------------------------
# In case your compiler does not understand the special meaning of 
# the .F and .F90 extensions ("files in need of preprocessing"), you
# will need to use an explicit preprocessing step.
#WITH_EXPLICIT_FPP = 1

# Explicit Fortran preprocessor. Typically this is sufficient to be the
# compiler with options '-E -P -x c'.
#FPP = $(FC) -E -P -x c

# This enables specific preprocessing options for certain source files.
#FPPFLAGS_fixed_f = -qsuffix=cpp=F -qfixed
#FPPFLAGS_free_f90 = -qsuffix=cpp=F90 -qfree=F90

# Some compilers (notably IBM's) are not happy with the standard syntax for
# definition of preprocessor symbols (-DSOME_SYMBOL), and thy need a prefix
# (i.e. -WF,-DSOME_SYMBOL). This is used in some utility makefiles. Typically
# this need not be defined.
#DEFS_PREFIX = -WF,

#--------------------------------------------------------
# Nothing should need to be changed below
#--------------------------------------------------------

FC_ASIS=$(FC_SERIAL)

# These are for initialization of variables added to below
FPPFLAGS= $(DEFS_PREFIX)-DF2003 
LIBS=
COMP_LIBS=

# ---- ELPA configuration -----------
#
# An external ELPA library can be used through the native interface (-DSIESTA__ELPA) and
# through the ELSI interface. Due to namespace collisions, the *same* external library
# must be used.

ifeq ($(WITH_EXTERNAL_ELPA),1)
   ifndef ELPA_ROOT	
     $(error you need to define ELPA_ROOT in your arch.make)
   endif
   ifndef ELPA_INCLUDE_DIRECTORY
     # It cannot be generated directly from ELPA_ROOT...
     $(error you need to define ELPA_INCLUDE_DIRECTORY in your arch.make)
   endif

   FPPFLAGS_ELPA=$(DEFS_PREFIX)-DSIESTA__ELPA
   ELPA_INCFLAGS= -I$(ELPA_INCLUDE_DIRECTORY)
   INCFLAGS += $(ELPA_INCFLAGS)
   FPPFLAGS += $(FPPFLAGS_ELPA)
   ELPA_LIB = -L$(ELPA_ROOT)/lib -lelpa
   LIBS +=$(ELPA_LIB) 
endif
# ---- ELPA configuration -----------

# ---- ELSI configuration -----------

ifeq ($(WITH_ELSI),1)
 ifndef ELSI_ROOT
   $(error you need to define ELSI_ROOT in your arch.make)
 endif
 #  Add the second symbol for MAGMA and EigenExa support
 FPPFLAGS_ELSI=$(DEFS_PREFIX)-DSIESTA__ELSI # -DSIESTA__ELSI_2_4_SOLVERS

 ELSI_INCFLAGS = -I$(ELSI_ROOT)/include

 ifeq ($(WITH_EXTERNAL_ELPA),1)
   ELSI_ELPA_ROOT=$(ELPA_ROOT)
   $(echo Make sure that ELSI is compiled with external ELPA...)
   # Explicit checks?
 else
   ELSI_ELPA_ROOT=$(ELSI_ROOT)
 endif
 # This assumes that ELSI has been compiled with PEXSI
 ELSI_LIB = -L$(ELSI_ROOT)/lib -lelsi \
               -lfortjson -lOMM -lMatrixSwitch \
               -lNTPoly \
                -lpexsi -lsuperlu_dist \
               -lptscotchparmetis -lptscotch -lptscotcherr \
               -lscotchmetis -lscotch -lscotcherr \
               -L$(ELSI_ELPA_ROOT)/lib -lelpa

 INCFLAGS += $(ELSI_INCFLAGS)
 FPPFLAGS += $(FPPFLAGS_ELSI)
 LIBS += $(ELSI_LIB) $(LIBS_CPLUS)
endif


ifeq ($(WITH_NETCDF),1)
 ifndef NETCDF_ROOT
   $(error you need to define NETCDF_ROOT in your arch.make)
 endif

# If NetCDF is enabled, for completeness in some installations,
# we might need to deal separately with the install prefixes of NetCDF and
# NetCDF-Fortran. By default both are the same

 ifeq ($(WITH_SEPARATE_NETCDF_FORTRAN),1)
   ifndef NETCDF_FORTRAN_ROOT
     $(error you need to define NETCDF_FORTRAN_ROOT in your arch.make)
   endif
   NETCDF_INCFLAGS = -I$(NETCDF_ROOT)/include -I$(NETCDF_FORTRAN_ROOT)/include
   NETCDF_LIBS = -L$(NETCDF_FORTRAN_ROOT)/lib -lnetcdff -L$(NETCDF_ROOT)/lib -lnetcdf
 else
   NETCDF_INCFLAGS = -I$(NETCDF_ROOT)/include
   NETCDF_LIBS = -L$(NETCDF_ROOT)/lib -lnetcdff
 endif
 NETCDF_LIBS += $(HDF5_LIBS)
 FPPFLAGS_CDF = $(DEFS_PREFIX)-DCDF
 FPPFLAGS += $(FPPFLAGS_CDF) 
 INCFLAGS += $(NETCDF_INCFLAGS)
 LIBS += $(NETCDF_LIBS)
endif

ifeq ($(WITH_NCDF),1)
 ifneq ($(WITH_NETCDF),1)
   $(error For NCDF you need to define also WITH_NETCDF=1 in your arch.make)
 endif
 FPPFLAGS += $(DEFS_PREFIX)-DNCDF $(DEFS_PREFIX)-DNCDF_4
 ifeq ($(WITH_NCDF_PARALLEL),1)
   FPPFLAGS += $(DEFS_PREFIX)-DNCDF_PARALLEL
 endif
 COMP_LIBS += libncdf.a libfdict.a
endif

ifeq ($(WITH_FLOOK),1)
 ifndef FLOOK_ROOT
   $(error you need to define FLOOK_ROOT in your arch.make)
 endif
 FLOOK_INCFLAGS=-I$(FLOOK_ROOT)/include
 INCFLAGS += $(FLOOK_INCFLAGS)
 FLOOK_LIBS= -L$(FLOOK_ROOT)/lib -lflookall -ldl
 FPPFLAGS_FLOOK = $(DEFS_PREFIX)-DSIESTA__FLOOK
 FPPFLAGS += $(FPPFLAGS_FLOOK) 
 LIBS += $(FLOOK_LIBS)
 COMP_LIBS += libfdict.a
endif

ifeq ($(WITH_MPI),1)
 FC=$(FC_PARALLEL)
 MPI_INTERFACE=libmpi_f90.a
 MPI_INCLUDE=.      # Note . for no-op
 FPPFLAGS_MPI = $(DEFS_PREFIX)-DMPI $(DEFS_PREFIX)-DMPI_TIMING
 LIBS += $(SCALAPACK_LIBS)
 LIBS += $(LAPACK_LIBS)
 FPPFLAGS += $(FPPFLAGS_MPI) 
else
 FC = $(FC_SERIAL)
 LIBS += $(LAPACK_LIBS)
endif

# ------------- libGridXC configuration -----------

ifeq ($(WITH_GRID_SP),1)
  GRIDXC_CONFIG_PREFIX=sp
  FPPFLAGS_GRID= $(DEFS_PREFIX)-DGRID_SP
else
  GRIDXC_CONFIG_PREFIX=dp
endif
ifeq ($(WITH_MPI),1)
  GRIDXC_CONFIG_PREFIX:=$(GRIDXC_CONFIG_PREFIX)_mpi
endif
FPPFLAGS += $(FPPFLAGS_GRID) 
# -------------------------------------------------


SYS=nag

# These lines make use of a custom mechanism to generate library lists and
# include-file management. The mechanism is not implemented in all libraries.
#---------------------------------------------
ifeq ($(WITH_PSML),1)
 include $(XMLF90_ROOT)/share/org.siesta-project/xmlf90.mk
 include $(PSML_ROOT)/share/org.siesta-project/psml.mk
endif

# A legacy libGridXC installation will have dual 'serial' and 'mpi' subdirectories,
# whereas a modern one, generated with the 'multiconfig' option,  will have split
# include directories but a flat lib directory. The details are still handled by
# appropriate .mk files in the installation directories.
#
# The multiconfig option appeared in 0.9.X, but the legacy compilation option is
# still allowed. For single-precision support with the 'legacy' option, you need to
# make sure that your installation is 'single'...
#
ifeq ($(WITH_GRIDXC),1)
  ifeq ($(WITH_LEGACY_GRIDXC_INSTALL),1)
    include $(GRIDXC_ROOT)/gridxc.mk
  else
    include $(GRIDXC_ROOT)/share/org.siesta-project/gridxc_$(GRIDXC_CONFIG_PREFIX).mk
  endif
endif

# Define default compilation methods
.c.o:
	$(CC) -c $(CFLAGS) $(INCFLAGS) $(CPPFLAGS) $< 
.F.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_fixed_F)  $< 
.F90.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_free_F90) $< 
.f.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FFLAGS_fixed_f)  $<
.f90.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FFLAGS_free_f90)  $<
