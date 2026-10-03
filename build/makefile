ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
SRC  := $(ROOT)/src
DIST := $(ROOT)/build/dist
BIN  := $(DIST)/brainrot

.PHONY: all clean

all: $(BIN)

$(BIN): $(SRC)/brainrot.l $(SRC)/brainrot.y
	mkdir -p $(DIST)
	flex -o $(DIST)/brainrot.lexer.c $(SRC)/brainrot.l
	bison -d --defines=$(DIST)/brainrot.tokens.h -o $(DIST)/brainrot.c $(SRC)/brainrot.y
	g++ -std=c++11 -static -static-libstdc++ -static-libgcc -I$(DIST) $(DIST)/brainrot.c -o $(BIN)
	rm -f $(DIST)/brainrot.lexer.c $(DIST)/brainrot.tokens.h $(DIST)/brainrot.c $(DIST)/brainrot.h

clean:
	rm -rf $(DIST)
