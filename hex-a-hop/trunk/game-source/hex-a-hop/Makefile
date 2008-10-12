# Makefile for Hex-a-hop, Copyright Oliver Pearce 2004
NAME		= Hex-a-hop
VERSION		= 1.0.0
CC		= gcc
CXXFLAGS		+= -D_VERSION=\"$(VERSION)\" -g
GCC =g++
CXXSOURCES	= gfx.cpp hex_puzzzle.cpp
#INCLUDES	= 


#############################################################

OBJS=$(CXXSOURCES:.cpp=.o)

%.o	: %.cpp
	$(GCC) $(CXXFLAGS)  `sdl-config --cflags`  -c -o $@ $<
	
$(NAME) : $(OBJS)
		$(GCC) $(CXXFLAGS) $(OBJS)  `sdl-config --libs` -lm  \
		-o $(NAME)

clean :
	rm -f *~ $(OBJS) $(NAME)
