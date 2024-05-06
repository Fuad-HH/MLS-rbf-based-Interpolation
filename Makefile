Home=/gpfs/u/home/PCPE/PCPEpdlb
KOKKOS_PATH = ${HOME}/scratch/Kokkos/kokkos
KOKKOS_DEVICES = "Cuda"
EXE_NAME = "MPI_IO_kokkos"

SRC = $(wildcard *.cpp)

default: build
	echo "Start Build"

CXX = mpicxx

ifneq (,$(findstring Cuda,$(KOKKOS_DEVICES)))
EXE = ${EXE_NAME}.cuda
KOKKOS_ARCH = "Volta70"
KOKKOS_CUDA_OPTIONS = "enable_lambda,rdc"
else
EXE = ${EXE_NAME}.host
KOKKOS_ARCH = "BDW"
endif

CXXFLAGS = -O3
LINK = ${CXX}
LINKFLAGS =

DEPFLAGS = -M

OBJ = $(SRC:.cpp=.o)
LIB =

include $(KOKKOS_PATH)/Makefile.kokkos

build: $(EXE)

$(EXE): $(OBJ) $(KOKKOS_LINK_DEPENDS)
	$(LINK) $(KOKKOS_LDFLAGS) $(LINKFLAGS) $(EXTRA_PATH) $(OBJ) $(KOKKOS_LIBS) $(LIB) -o $(EXE)

clean: kokkos-clean
	rm -f *.o *.cuda *.host *.tmp core.* *.out *.err 

# Compilation rules

%.o:%.cpp $(KOKKOS_CPP_DEPENDS)
	$(CXX) $(KOKKOS_CPPFLAGS) $(KOKKOS_CXXFLAGS) $(CXXFLAGS) $(EXTRA_INC) -c $<

test: $(EXE)
	./$(EXE)
