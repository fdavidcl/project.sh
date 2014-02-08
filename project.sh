#!/bin/bash

# project.sh
# Date: 21/11/2011
# Author: David Charte
# Version: 2.1
# Description: Creates directory hierarchies for C++ projects,
#              and manages Makefiles.
# License: WTFPL (Do What The Fuck You Want To Public License)
# Thanks to Iván Calle for beta-testing!

[[ $# -gt 0 ]] && {
    NM="$1"
	PR_DIR="$2./$NM"
} || {
	PR_DIR="./"
	NM="`pwd | rev | cut -d"/" -f1 | rev`"
   echo "Using current directory... (project $NM)."
}

[[ -d $PR_DIR ]] && {
   [[ -f $PR_DIR/Makefile ]] || {
      echo "Directory $PR_DIR exists and it's not a project. Aborting."
      exit 1;
   } && {
      printf "Existing project in $PR_DIR. Updating...\n"
      
      LAST=`pwd`
      cd $PR_DIR/src/
      LSRC=`ls -1 *.cpp | rev | cut -d'.' -f2- | rev`
      cd $LAST
      MF="$PR_DIR/Makefile"
      
	   printf 'BIN=./bin\nDOC=./doc\nINCLUDE=./include\nLIB=./lib\nOBJ=./obj\nSRC=./src\n\n' > $MF &&
	   printf 'all:' >> $MF &&
	   for F in $LSRC; do
	      printf ' $(OBJ)/'"$F.o" >> $MF 
	   done
	   printf "\n" >> $MF
      echo "	g++ -o \$(BIN)/$NM $^" >> $MF &&
	   for F in $LSRC; do 
         echo '$(OBJ)/'"$F"'.o: $(SRC)/'"$F"'.cpp'" `[[ -f $PR_DIR/include/$F.h ]] && echo '$(INCLUDE)/'$F'.h'`" >> $MF &&
         echo '	g++ -o $(OBJ)/'"$F"'.o -c $< -I$(INCLUDE)' >> $MF
      done
      echo 'clean:' >> $MF &&
      echo '	rm $(OBJ)/*.o' >> $MF &&
      echo 'doc:' >> $MF &&
      echo '	doxygen $(DOC)/doxys/Doxyfile' >> $MF &&
      echo '.PHONY: all clean doc' >> $MF &&
      printf " [ OK ] Makefile updated\n"
   }
} || {
  	printf "Creating new project $NM...\n"

   mkdir $PR_DIR && printf "  [ OK ]  Project directory created\n"

   mkdir $PR_DIR/bin $PR_DIR/doc $PR_DIR/include $PR_DIR/lib $PR_DIR/obj $PR_DIR/src &&
   printf "  [ OK ]  Directory hierarchy created\n"

   # Creamos los archivos por defecto
   touch $PR_DIR/src/main.cpp &&
   printf "\n\nint main(int argc, char *argv[]){\n\t\n}" > $PR_DIR/src/main.cpp &&
   printf "  [ OK ]  New main.cpp file created\n"

   # Creamos el Makefile por defecto
   MF="$PR_DIR/Makefile" &&
   touch $MF

   printf 'BIN=./bin\nDOC=./doc\nINCLUDE=./include\nLIB=./lib\nOBJ=./obj\nSRC=./src\n\n' > $MF &&
   echo 'all: $(OBJ)/main.o' >> $MF &&
   echo "	g++ -o \$(BIN)/$NM $^" >> $MF &&
   echo '$(OBJ)/main.o: $(SRC)/main.cpp' >> $MF &&
   echo '	g++ -o $(OBJ)/main.o -c $^ -I$(INCLUDE)' >> $MF &&
   echo 'clean:' >> $MF &&
   echo '	rm $(OBJ)/*.o' >> $MF &&
   echo 'doc:' >> $MF &&
   echo '	doxygen $(DOC)/doxys/Doxyfile' >> $MF &&
   echo '.PHONY: all clean doc' >> $MF &&
   printf "  [ OK ]  New Makefile created\n"
}
