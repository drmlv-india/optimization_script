#!/bin/bash

#======================================================#
# Script: lattice constant optimization for AgI        #
# Author: Mohan L Verma, Computational Nanomaterial    #  
# Research lab, Department of Applied Physics,         #
# Shri Shanakaracharya Technical Campus-Junwani        # 
# Bhilai(Chhattisgarh)  INDIA                          #
# Feb 24   ver: 2.0    year: 2023                      #
# it is assumed that siesta.exe binary file is linked  #
# bin directory after parallel compilation of siesta   #
#------------------------------------------------------#
# run this script using cammand                        #
#  sh mlv_script_lattice.sh                            #
# this will creat 16 folders with complete siesta run  #
# and give xmgrace plot to find optimum lattice const. #
# give feedback in                                     #
#                  www.drmlv.in/siesta  or             # 
#                  drmohanlv@gmail.com                 #
#===================================================== #
> EvsA.dat 
mkdir latt_const
cd latt_const

mkdir cont   # read the comment at the end of this script.

for i in `seq -w 0.9 0.025 1.4 `  
do


cp -r cont $i
cd $i
cp ../../*.psf .
 


cat > AgImol.fdf <<EOF

SystemName  SilverIodide 
SystemLabel AgImol

NumberOfSpecies 2
NumberOfAtoms   2

%block ChemicalSpeciesLabel
1   47  Ag
2   53   I
%endblock ChemicalSpeciesLabel
 

LatticeConstant $i Ang

%block LatticeVectors 
    3.00000000000000    0.0000000000000000     0.0000000000000000
     0.00000000000000000   3.00000000000000000   0.0000000000000000
     0.00000000000000000    0.0000000000000000    3.000000000
%endblock LatticeVectors

 
==================================================
==================================================
# K-points


#put the value of Km the  optimized kpoints  value obtained from xmgrace plot of 2nd script. 

%block kgrid_Monkhorst_Pack 
Km   0   0   0.0
0   Km   0   0.0
0   0    Km   0.0
%endblock kgrid_Monkhorst_Pack


#%blockSuperCell
# 1   0   0
# 1   1   0
# 0   0   9
#%endblockSuperCell

AtomicCoordinatesFormat NotScaledCartesianAng
%block AtomicCoordinatesAndAtomicSpecies
   -0.23280   -0.12659    0.34162	2
    1.04055    0.56587   -1.52678	1
%endblock AtomicCoordinatesAndAtomicSpecies
 
#%block GeometryConstraints
#position from  1 to  180
#%endblock GeometryConstraints

PAO.BasisSize     DZP
PAO.EnergyShift   0.03 eV
MD.TypeOfRun      CG
MaxSCFIterations  300
SCF.MustConverge   false
MD.NumCGsteps     0
MD.MaxForceTol    0.005  eV/Ang
MeshCutoff       Cm Ry    	#put the value of  optimized mesh cutoff-Cm value obtained from the xmgrace plot of 1st script.  
DM.MixingWeight   0.02
DM.NumberPulay   3
WriteCoorXmol   .true.
WriteMullikenPop    1
XC.functional       LDA
XC.authors          CA
SolutionMethod  diagon
ElectronicTemperature  50 meV
SaveRho        .true.


#UseSaveData     true
#DM.UseSaveDM    true
#MD.UseSaveXV    true
#MD.UseSaveCG    true




EOF

mpirun -np 6 siesta.exe *.fdf | tee  result.out 

etot=`grep 'Total =' result.out | cut -d = -f 2`
echo $i '      ' $etot >> ../EvsA.dat 


 



cd ..
rm -rf cont 
mkdir cont

cp   ./$i/*.DM  cont  # copy these files for continuation of the next step.


 
done
cp EvsA.dat ../

cd ..
xmgrace EvsA.dat &
rm -r -v latt_const


