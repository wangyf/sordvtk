#FC = /soft/compilers/gcc/4.8.4/bin/powerpc64-bgq-linux-gfortran 
# FC = ifort
FC = gfortran
# FFLAGS = -O3 -Dr8 -fpp  -real-size 64
FFLAGS = -O3 -Dr8 -cpp -Wl,-no_compact_unwind -fdefault-real-8
OBJECTS = stringmod.o byteswap.o IR_Precision.o Lib_Pack_Data.o Lib_Base64.o Lib_VTK_IO.o sordvtk.o
OBJ2 = IR_Precision.o Lib_Pack_Data.o Lib_Base64.o Lib_VTK_IO.o example2.o
bin = sordvtk_r8

all:$(OBJECTS)
	$(FC) $(FFLAGS) $(OBJECTS) -o $(bin)

example:$(OBJ2)
	$(FC) $(FFLAGS) $(OBJ2) -o example

stringmod.o:stringmod.f90
	$(FC) $(FFLAGS) -c $^

byteswap.o:byteswap.f90
	$(FC) $(FFLAGS) -c $^

IR_Precision.o:IR_Precision.f90
	$(FC) $(FFLAGS) -c $^

Lib_Pack_Data.o:Lib_Pack_Data.f90
	$(FC) $(FFLAGS) -c $^

Lib_Base64.o:Lib_Base64.f90
	$(FC) $(FFLAGS) -c $^

Lib_VTK_IO.o:Lib_VTK_IO.f90
	$(FC) $(FFLAGS) -c $^

sordvtk.o:sordvtk.f90
	$(FC) $(FFLAGS) -c $^

example2.o: example2.f90
	$(FC) $(FFLAGS) -c $^

clean:
	rm *.mod *.o $(bin)
