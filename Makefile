MAKEFLAGS 				+= --warn-undefined-variables
SHELL 						:= /bin/bash
.SHELLFLAGS 			:= -eu -o pipefail -c
.DEFAULT_GOAL			:= all
.DELETE_ON_ERROR:
.SUFFIXES:

##################################################
# Compiler settings
##################################################

# Set compiler to g++
CXX								:= g++

# Compiler flags
CXXFLAGS					:= -g -Wall -std=c++11

##################################################
# Directory macros
##################################################

INCDIR						:= include/
SRCDIR						:= src/
TESTDIR						:= test/

# Where compiled objects are stored
BINDIR						:= bin/
OBJDIR						:= build/
GENDIR						:=

##################################################
# Required object dependencies
##################################################

# Update this line with list of objects to be compiled
_OBJECTS					:=
OBJECTS						:= $(patsubst %,$(OBJDIR)/%,$(_OBJECTS))

##################################################
# Linker
##################################################

LDFLAGS						:= -Wl,-rpath='$$ORIGIN/lib/' -Wl,-rpath='$$ORIGIN/../lib/' -Wl,-rpath='$(CURDIR)/lib/' -L$(CURDIR)/lib/ -Llib/ -L/usr/local/lib/
LDLIBS						:= 

# Tensorflow
LDLIBS 						+=	-ltensorflow_cc -ltensorflow_framework
# OpenCV
LDLIBS 						+= `pkg-config --libs opencv`

##################################################
# Header files
##################################################

INCLUDE						:= $(patsubst %,-I%,$(INCDIR))

# OpenCV
INCLUDE						+= `pkg-config --cflags opencv`
# Nsync
INCLUDE						+=  -Iinclude/nsync/

##################################################
# Make rules
##################################################

.PHONY: all
all: $(OBJECTS)
	@echo "----- Compiling main -----"
	@mkdir -p $(OBJDIR)
	@mkdir -p $(BINDIR)
	$(CXX) $(CXXFLAGS) $(INCLUDE) $(LDFLAGS) $(SRCDIR)test.cpp $(LDLIBS) -o $(BINDIR)main

$(OBJDIR)%.o: $(SRCDIR)%.cpp
	@echo "----- Compiling object file:" $@ "from" $< "-----"
	@mkdir -p $(OBJDIR)
	$(CXX) -c -o $@ $< $(CXXFLAGS)

.PHONY: clean
clean:
	@echo "----- Cleaning object files -----"
	rm -rf $(OBJDIR)*.o

.PHONY: clean-bin
clean-bin:
	@echo "----- Cleaning binaries -----"
	rm -rf $(BINDIR)/*
