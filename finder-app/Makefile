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


# Check if CROSS_COMPILE is set, otherwise use gcc
CROSS_COMPILE ?= aarch64-none-linux-gnu-

#$(info STAGE1 CROSS_COMPILE = $(CROSS_COMPILE))

CC := $(shell if which ${CROSS_COMPILE} > /dev/null 2>&1; then echo "${CROSS_COMPILE}"; else echo "${CROSS_COMPILE}gcc"; fi )

#$(info STAGE2 CC = $(CC))
# Compiler flags and other variables
CFLAGS := -Wall -O2
SRC := writer.c
TARGET := writer.o

# Target rule
all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(TARGET)

.PHONY: all clean
