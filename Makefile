SHELL = /bin/sh

OCAMLBUILD = ocamlbuild
DOCKER = docker
SCP = scp

srcdir = src
builddir = _build/$(srcdir)

# OCamlbuild variables
DEBUGFLAG = -g
OCAMLCFLAGS = -cflags $(DEBUGFLAG),-annot,-bin-annot,-w,+a
OCAMLLFLAGS = -lflag $(DEBUGFLAG)
OCAMLLIBS = -lib unix

EV3_IMG = ev3
ROBOT_HOME = /home/robot
ROBOT = robot@ev3dev.local

# Target basename
TARGET = test
# Native target
NTARGET = $(TARGET).native
# Bytecode target
BTARGET = $(TARGET).byte

build = $(OCAMLBUILD) -no-links $(OCAMLCFLAGS) $(OCAMLLFLAGS) $(OCAMLLIBS)
clean = $(OCAMLBUILD) -clean

.SUFFIXES:
.SUFFIXES: .native .byte
.PHONY: all $(TARGET) export-native export-byte ev3 clean

all: $(TARGET)

# Generate suitable executable for the robot using Docker.
$(TARGET):
	$(DOCKER) run --rm -v $$PWD:$(ROBOT_HOME) $(EV3_IMG) $(MAKE) $(NTARGET)

%.native %.byte:
	$(build) $(srcdir)/$@

# Export native executable to the robot via SSH.
export-native: $(TARGET)
	$(SCP) $(builddir)/$(NTARGET) $(ROBOT):$(ROBOT_HOME)

# Export bytecode executable to the robot via SSH.
export-byte: $(BTARGET)
	$(SCP) $(builddir)/$< $(ROBOT):$(ROBOT_HOME)

# Generate Docker image to compile OCaml code for the robot.
ev3:
	$(DOCKER) build -t $(EV3_IMG) .

clean:
	$(clean)
