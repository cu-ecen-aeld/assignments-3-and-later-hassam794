# SRC = writer.c
# FILE= writer

# #create object file by replacing .c of source files with .o
# OBJS = $(SRC:.c=.o)
# CFLAGS= -c -Wall
# CC=gcc
# #optional crosscompile
# CROSS_COMPILE?= 

# .PHONY: default

# default: all

# all: $(OBJS)
# 	$(CROSS_COMPILE)$(CC) $(OBJS) -o $(FILE)


# %.o: %.c
# 	$(CROSS_COMPILE)$(CC) $(CFLAGS) $< -o $@ 


# clean:
# 	rm -rf *.o $(FILE)


SRC = writer.c
FILE = writer

# Create object file by replacing .c of source files with .o
OBJS = $(SRC:.c=.o)
CFLAGS = -Wall

# Allow Buildroot to set CC and CROSS_COMPILE
CC ?= $(CROSS_COMPILE)gcc

.PHONY: default clean

default: all

all: $(OBJS)
	$(CC) $(OBJS) -o $(FILE)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@ 

clean:
	rm -rf *.o $(FILE)
