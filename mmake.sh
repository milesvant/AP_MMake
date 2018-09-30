#!/bin/bash

# Creates a Makefile from .c and .h files found in the
# current directory, according to the standards of
# COMS 3157

# author: milesvant



# echos the local header files included in given c file
function rDepends () {
	returnValue=$(grep -s -i "#include \"" $1)
	echo $returnValue
}

# removes quotation marks and extensions from filenames
function cleanHeader () {
	header=$(echo $1 | cut -f 2 -d ' ')
	header=$(echo $header | cut -f 2 -d '"')
	header=$(echo $header | cut -f 1 -d '.')
	echo $header	
}

# delete the previous Makefile, if one exists
rm -f Makefile*

# adds the compiler choice and flags in the COMS 3157 template
echo -e "CC = gcc\n" >> Makefile
echo -e -n "CFLAGS = -Wall -g\nLDFLAGS = -g\n\n" >> Makefile

# determines the file in the current directory which contains
# the main funciton. Note: the script does not work if there
# are multiple files with main functions, or non .c files with
# the string "int main()" in them, or if main takes arguments
MAINFILE=$(grep -l -e "int main()" *)
name=$(echo $MAINFILE | cut -f 1 -d '.')
echo -e -n "$name: " >> Makefile

# adds in the names of the object files needed to link main
for INCLUSION in $(rDepends $MAINFILE)
do
	if [ $INCLUSION != "#include" ]; then
		myheader=$(cleanHeader $INCLUSION)
		echo -e -n "$myheader.o " >> Makefile
	fi
done

echo -e -n "\n\n$name.o: " >> Makefile

# adds in the names of the header files needed for the 
# compilation of the object file with the main() function
for INCLUSION in $(rDepends $MAINFILE); do
	if [ $INCLUSION != "#include" ]; then
		myheader=$(cleanHeader $INCLUSION)
		echo -e -n "$myheader.h " >> Makefile
	fi
done

echo -e "\n" >> Makefile

# adds in the names of the header files needed for the
# compilation of each non-main object file
for INCLUSION in $(rDepends $MAINFILE)
do
	if [ $INCLUSION != "#include" ]; then
		myheader=$(cleanHeader $INCLUSION)
		echo -e -n "$myheader.o: " >> Makefile
		for SUBINCLUSION in $(rDepends "$myheader.c")
		do
			if [ $SUBINCLUSION != "#include" ]; then
				mysubheader=$(cleanHeader $SUBINCLUSION)
				echo -e -n "$mysubheader.h " >> Makefile
			fi
		done
		echo -e -n "\n\n" >> Makefile
	fi
done


# adds in the phony commands clean and all
echo -e ".PHONY: clean\nclean:\n\trm -f *.o a.out core $name\n\n.PHONY: all\nall: clean $name" >> Makefile

# flags
while getopts ":rac" opt; do
	case $opt in
		r)
			make
			;;
		a)
			make all
			;;
		c)
			make clean
			;;
	esac
done
