MODULES = cell_mat.c
HEADERS = cell_mat.h

CFLAGS = -g -Wall

all: libnk-solve.so

libnk-solve.so: $(MODULES) $(HEADERS)
	gcc $(CFLAGS) -shared `pkg-config --cflags glib-2.0` -o $@ $(MODULES) `pkg-config --libs glib-2.0`

test:
	runprove t/*.t
