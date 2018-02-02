CXX := g++
ACT := . venv/bin/activate

ATEN_ROOT := build/stage
INCPATH := -I$(ATEN_ROOT)/include -I. -I$(CONDA_PREFIX)/include
LIBPATH := -L$(ATEN_ROOT)/lib -L$(CONDA_PREFIX)/lib
LIBS := -lATen
H5_LIB := -lhdf5 -lhdf5_cpp
RUNTIME_LIB := $(ATEN_ROOT)/lib:$(CONDA_PREFIX)/lib

MAKE_PID := $(shell echo $$PPID)
JOB_FLAG := $(filter -j%, $(subst -j ,-j,$(shell ps T | grep "^\s*$(MAKE_PID).*$(MAKE)")))
JOBS     := $(subst -j,,$(JOB_FLAG))
ifndef JOBS
JOBS=1
endif

.PHONY: all clean

all: $(ATEN_ROOT)/lib/libATen.so

Miniconda3-latest-Linux-x86_64.sh:
	wget https://repo.continuum.io/miniconda/$@

venv: Miniconda3-latest-Linux-x86_64.sh
	sh $< -b -p $(PWD)/$@
	$(ACT) && conda config --set always_yes yes
	$(ACT) && conda update conda
	$(ACT) && conda insfo -a

install-aten-deps: venv
	$(ACT) && conda config --set always_yes yes
	$(ACT) && conda update conda
	$(ACT) && conda info -a
	$(ACT) && conda uninstall libgcc; echo ok
	$(ACT) && conda install numpy pyyaml mkl setuptools cmake cffi
	# optional
	$(ACT) && conda install -c soumith magma-cuda90

install-hdf5-deps:
	$(ACT) && conda install hdf5==1.8.17

update-aten:
	git submodule foreach git pull origin master

$(ATEN_ROOT)/lib/libATen.so: venv # install-aten-deps
	mkdir -p $(ATEN_ROOT)/../
	$(ACT) && cd $(ATEN_ROOT)/../; \
	  CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" cmake ../ATen -DCMAKE_INSTALL_PREFIX=`pwd`/../$(ATEN_ROOT) -DCMAKE_CXX_FLAGS:="-D__STDC_FORMAT_MACROS=1" ; \
	make install -j$(JOBS)
