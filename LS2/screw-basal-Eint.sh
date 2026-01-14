#! /bin/bash
# 2023.2.27 #

# 2023.8.23 modify F=dE/dx -> F=dE/dsqrt(x^2+y^2) #

# 2023.11.7 F=dE/dsqrt(x^2+y^2) -> F=dE/dx #

# 2024.1.13 修改了下面array1,2,3的取向，现在是按溶质在hcp晶体里面的取向写的

# screw dislocation; basal plane

###############################
### Step 1: input parameter ###
###############################

# initial parameter #
echo -e "\n### Start ###\n"
read -p "## input e11 e22 e33 : " e11 e22 e33                    #eij is strain elastic dipole
echo -e "\n## e11 e22 e33 :"
echo -e "$e11  $e22  $e33 \n"

######################################################
### Step 2: input dislocation coordinate direction ###
######################################################
## for screw dislocation, X:need calculate, Y:glide plane normal direction, Z:dislocation line direction ##

x1=1
x2=-1
x3=0

y1=0
y2=0
y3=1

z1=1
z2=1
z3=0
echo -e "$x1 $x2 $x3\n"
echo -e "$y1 $y2 $y3\n"
echo -e "$z1 $z2 $z3\n\n"
echo -e "\n#######################################################################\n"

###############################
### Step3: calculate cosine ###
###############################

# define defect coordinate direction,no modify #
array1=(1 0 0)
array2=(1 2 0)
array3=(0 0 1)

# cosine matrix #
a11=$(echo "$x1 $x2 $x3"| awk '{printf ("%.8f\n",($1*1+$2*0+$3*0)/sqrt(1)/sqrt((($1*$1+$2*$2+$3*$3))))}')
a12=$(echo "$x1 $x2 $x3"| awk '{printf ("%.8f\n",($1*1+$2*2+$3*0)/sqrt(5)/sqrt((($1*$1+$2*$2+$3*$3))))}')
a13=$(echo "$x1 $x2 $x3"| awk '{printf ("%.8f\n",($1*0+$2*0+$3*1)/sqrt(1)/sqrt((($1*$1+$2*$2+$3*$3))))}')
a21=$(echo "$y1 $y2 $y3"| awk '{printf ("%.8f\n",($1*1+$2*0+$3*0)/sqrt(1)/sqrt((($1*$1+$2*$2+$3*$3))))}')
a22=$(echo "$y1 $y2 $y3"| awk '{printf ("%.8f\n",($1*1+$2*2+$3*0)/sqrt(5)/sqrt((($1*$1+$2*$2+$3*$3))))}')
a23=$(echo "$y1 $y2 $y3"| awk '{printf ("%.8f\n",($1*0+$2*0+$3*1)/sqrt(1)/sqrt((($1*$1+$2*$2+$3*$3))))}')
a31=$(echo "$z1 $z2 $z3"| awk '{printf ("%.8f\n",($1*1+$2*0+$3*0)/sqrt(1)/sqrt((($1*$1+$2*$2+$3*$3))))}')
a32=$(echo "$z1 $z2 $z3"| awk '{printf ("%.8f\n",($1*1+$2*2+$3*0)/sqrt(5)/sqrt((($1*$1+$2*$2+$3*$3))))}')
a33=$(echo "$z1 $z2 $z3"| awk '{printf ("%.8f\n",($1*0+$2*0+$3*1)/sqrt(1)/sqrt((($1*$1+$2*$2+$3*$3))))}')

echo -e "## cosine matrix ##\n"
echo $a11 $a12 $a13
echo $a21 $a22 $a23
echo $a31 $a32 $a33
echo -e "\n#######################################################################\n"

###################################
### Step4: calculate new dipole ###
###################################
## eij'=aik*ajl*ekl, but just ekk!=0, so eij'=aik*ajk*ekk ##
## Here, eij' will be replaced by Sij, or program error reporting! ##

S11=$(echo "$e11 $e22 $e33 $a11 $a12 $a13"| awk '{printf ("%.8f\n",$4*$4*$1+$5*$5*$2+$6*$6*$3)}')
S12=$(echo "$e11 $e22 $e33 $a11 $a12 $a13 $a21 $a22 $a23"| awk '{printf ("%.8f\n",$4*$7*$1+$5*$8*$2+$6*$9*$3)}')
S13=$(echo "$e11 $e22 $e33 $a11 $a12 $a13 $a31 $a32 $a33"| awk '{printf ("%.8f\n",$4*$7*$1+$5*$8*$2+$6*$9*$3)}')

S21=$(echo "$e11 $e22 $e33 $a21 $a22 $a23 $a11 $a12 $a13"| awk '{printf ("%.8f\n",$4*$7*$1+$5*$8*$2+$6*$9*$3)}')
S22=$(echo "$e11 $e22 $e33 $a21 $a22 $a23"| awk '{printf ("%.8f\n",$4*$4*$1+$5*$5*$2+$6*$6*$3)}')
S23=$(echo "$e11 $e22 $e33 $a21 $a22 $a23 $a31 $a32 $a33"| awk '{printf ("%.8f\n",$4*$7*$1+$5*$8*$2+$6*$9*$3)}')

S31=$(echo "$e11 $e22 $e33 $a31 $a32 $a33 $a11 $a12 $a13"| awk '{printf ("%.8f\n",$4*$7*$1+$5*$8*$2+$6*$9*$3)}')
S32=$(echo "$e11 $e22 $e33 $a31 $a32 $a33 $a21 $a22 $a23"| awk '{printf ("%.8f\n",$4*$7*$1+$5*$8*$2+$6*$9*$3)}')
S33=$(echo "$e11 $e22 $e33 $a31 $a32 $a33"| awk '{printf ("%.8f\n",$4*$4*$1+$5*$5*$2+$6*$6*$3)}')

echo -e "## new dipole tensor ##\n"
echo $S11 $S12 $S13
echo $S21 $S22 $S23
echo $S31 $S32 $S33
echo -e "\n#######################################################################\n"

############################################
### Step 5: calculate interaction energy ###
############################################

# bulk's parameter #
#V is the solute volume; G is shear modulus; u is Poisson's ratio; b is Burgers vector
V=17.33925
G=51.91316
u=0.29949
b=2.93562
echo -e "V=$V G=$G u=$u b=$b\n"

# interaction energy (eV)#
echo -e "\n## screw dislocation ##"
echo -e "Eint=-$V/160.2*$G/2/pi*$b*2/(x*x+y*y)*(-y*($S13)+x*($S23))\n"
echo -e "Eint=-$V/160.2*$G/2/pi*$b/y*(-2*sin(x)*($S13)+2*cos(x)*($S23))\n"                                                 # y=r
echo -e "F=dE/dsqrt(x^2+y^2)=-$V/160.2*$G/pi*$b*(($S23)*(x*x+y*y)-2*(-($S13)*y+($S23)*x)*x)/(x*x+y*y)/(x*x+y*y)"
echo -e "\n"

echo "screw basal force 1b (meV)"
y=2.93562
echo -e "F=dE/dsqrt(x^2+y^2)=-1000*$V/160.2*$G/pi*$b*(($S23)*(x*x+($y)*($y))-2*(-($S13)*($y)+($S23)*x)*x)/(x*x+($y)*($y))/(x*x+($y)*($y))\n"

echo "screw basal force 2b (meV)"
y=5.87124
echo -e "F=dE/dsqrt(x^2+y^2)=-1000*$V/160.2*$G/pi*$b*(($S23)*(x*x+($y)*($y))-2*(-($S13)*($y)+($S23)*x)*x)/(x*x+($y)*($y))/(x*x+($y)*($y))\n"

echo "screw basal force 0b (meV)"
y=0
echo -e "F=dE/dsqrt(x^2+y^2)=-1000*$V/160.2*$G/pi*$b*(($S23)*(x*x+($y)*($y))-2*(-($S13)*($y)+($S23)*x)*x)/(x*x+($y)*($y))/(x*x+($y)*($y))\n"

echo -e "\n### End ###\n"