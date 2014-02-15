#!/bin/bash

# project.sh
# Date: 21/11/2011
# Author: David Charte
# Version: 2.5
# Description: Creates directory hierarchies for C++ projects,
#              and manages Makefiles.
# License: WTFPL (Do What The Fuck You Want To Public License)
# Thanks to Iván Calle for beta-testing!


#---------------------------------------------------------------#
# DEFAULT VARIABLES: Change these to whatever you like          #
#---------------------------------------------------------------#

# Will use this compiler for Makefiles. Default: "g++"
COMPILER="g++"

# Content for the defailt main.cpp file. Default: "\n\nint main(int argc, char *argv[]){\n\t\n}"
DEFAULT_MAIN="\n\nint main(int argc, char *argv[]){\n\t\n}"

# Makefile name. Default: "Makefile"
MAKEFILE_NAME="Makefile"


#---------------------------------------------------------------#
# SCRIPT: Creates new directories and files if necessary,       #
#         writes makefile                                       #
#---------------------------------------------------------------#

# Finds directory and name for the project
[[ $# -gt 0 ]] && {
	# Project with name and optional directory
	NM="$1"
	[[ $# -gt 1 ]] && PR_DIR="$2/./$NM" || PR_DIR="./$NM"
} || {
	# If no arguments are given, we'll use the current directory as a project
	NM="`pwd | rev | cut -d"/" -f1 | rev`"
	PR_DIR="./"
	echo "Using current directory... (project $NM)."
}

MF="$PR_DIR/$MAKEFILE_NAME"

# Prepares directories and files before writing Makefile
[[ -d $PR_DIR ]] && {
	[[ -f $PR_DIR/Makefile ]] && {
		echo "Existing project in $PR_DIR. Updating..."
	} || {
		[[ -d $PR_DIR/src/ ]] && {
			echo "Existing project in $PR_DIR. Creating new Makefile..."
		} || {
			echo "Existing directory $PR_DIR is not a project (directory src/ is necessary). Aborting..."
			exit 1
		}
	}
} || {
	echo "Creating new project $NM..."

	mkdir $PR_DIR && {
		echo "  [ OK ]  Project directory created"
	} || {
		echo "  [ ERROR ] Couldn't create project directory"
		exit 2
	}

	mkdir $PR_DIR/bin $PR_DIR/doc $PR_DIR/include $PR_DIR/lib $PR_DIR/obj $PR_DIR/src && {
		echo "  [ OK ]  Directory hierarchy created"
	} || {
		echo "  [ ERROR ] Couldn't create directory hierarchy"
		exit 2 
	}

	# Creates default files
	touch $PR_DIR/src/main.cpp && printf $DEFAULT_MAIN > $PR_DIR/src/main.cpp && {
		echo "  [ OK ]  New main.cpp file created" 
	} || { 
		echo "  [ ERROR ] Couldn't create main.cpp file"
		exit 2 
	}
	
	# Creates default Makefile
	touch $MF && {
		echo "  [ OK ]  New Makefile created" 
	} || {
		echo "  [ ERROR ] Couldn't create new Makefile"
		exit 2
	}
}

# Lists .cpp or .h files
LAST=`pwd`
cd $PR_DIR/src/
LSRC=`ls -1 *.cpp | rev | cut -d'.' -f2- | rev`
cd $LAST

# Writes/updates Makefile
printf "GXX=$COMPILER\nBIN=./bin\nDOC=./doc\nINCLUDE=./include\nLIB=./lib\nOBJ=./obj\nSRC=./src\n\n" > $MF &&
printf 'all:' >> $MF &&
for F in $LSRC; do
	printf ' $(OBJ)/'"$F.o" >> $MF 
done
printf "\n" >> $MF
echo '   $(GXX) -o $(BIN)/'"$NM"' $^' >> $MF &&
for F in $LSRC; do 
	echo '$(OBJ)/'"$F"'.o: $(SRC)/'"$F"'.cpp'" `[[ -f $PR_DIR/include/$F.h ]] && echo '$(INCLUDE)/'$F'.h'`" >> $MF &&
	echo '   $(GXX) -o $(OBJ)/'"$F"'.o -c $< -I$(INCLUDE)' >> $MF
done
echo 'clean:' >> $MF &&
echo '   rm $(OBJ)/*.o' >> $MF &&
echo 'doc:' >> $MF &&
echo '   doxygen $(DOC)/doxys/Doxyfile' >> $MF &&
echo '.PHONY: all clean doc' >> $MF &&
echo "  [ OK ]  Makefile updated"
