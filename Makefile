SHELL = /bin/sh

OCAMLBUILD = ocamlbuild
DOCKER = docker
SCP = scp

srcdir = src
builddir = _build/$(srcdir)

# OCamlbuild variables
NEXT = native
BEXT = byte
DEBUGFLAG = -g
OCAMLCFLAGS = -cflags $(DEBUGFLAG),-annot,-bin-annot,-w,+a
OCAMLLFLAGS = -lflag $(DEBUGFLAG)
OCAMLLIBS = -lib unix

EV3_IMG = ev3
ROBOT_HOME = /home/robot
ROBOT = robot@ev3dev.local

# Target basenames
TARGETS = test
# Native targets
NTARGETS = $(addsuffix .$(NEXT),$(TARGETS))
# Bytecode targets
BTARGETS = $(addsuffix .$(BEXT),$(TARGETS))

build = $(OCAMLBUILD) -no-links $(OCAMLCFLAGS) $(OCAMLLFLAGS) $(OCAMLLIBS)
clean = $(OCAMLBUILD) -clean
export-to-robot = $(SCP) $(addprefix $(builddir)/,$(1)) $(ROBOT):$(ROBOT_HOME)

.SUFFIXES:
.PHONY: all $(TARGETS) $(NTARGETS) $(BTARGETS) export-native	\
	export-byte ev3 clean

all: $(TARGETS)

# Generate suitable executable for the robot using Docker.
$(TARGETS): ev3
	$(DOCKER) run --rm -v $$PWD:$(ROBOT_HOME) $(EV3_IMG) $(MAKE) $@.$(NEXT)

$(NTARGETS) $(BTARGETS):
	$(build) $(srcdir)/$@

# Export native executables to the robot via SSH.
export-native: $(TARGETS)
	$(call export-to-robot,$(NTARGETS))

# Export bytecode executables to the robot via SSH.
export-byte: $(BTARGETS)
	$(call export-to-robot,$^)

# Generate Docker image to compile OCaml code for the robot.
ev3:
	$(DOCKER) build -t $(EV3_IMG) .

clean:
	$(clean)
