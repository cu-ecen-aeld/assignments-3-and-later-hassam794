SRC = writer.c
FILE= writer

#create object file by replacing .c of source files with .o
OBJS = $(SRC:.c=.o)
CFLAGS= -c -Wall
CC=gcc
#optional crosscompile
CROSS_COMPILE?= 

.PHONY: default

default: all

all: $(OBJS)
	$(CROSS_COMPILE)$(CC) $(OBJS) -o $(FILE)


%.o: %.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $< -o $@ 


clean:
	rm -rf *.o $(FILE)
