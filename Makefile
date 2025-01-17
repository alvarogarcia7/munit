# Using µnit is very simple; just include the header and add the C
# file to your sources.  That said, here is a simple Makefile to build
# the example.

CSTD:=99
OPENMP:=n
ASAN:=n
UBSAN:=n
EXTENSION:=
TEST_ENV:=
CFLAGS:=
AGGRESSIVE_WARNINGS=n

ifeq ($(CC),pgcc)
        CFLAGS+=-c$(CSTD)
else
        CFLAGS+=-std=c$(CSTD)
endif

ifeq ($(OPENMP),y)
        ifeq ($(CC),pgcc)
                CFLAGS+=-mp
        else
                CFLAGS+=-fopenmp
        endif
endif

ifneq ($(SANITIZER),)
        CFLAGS+=-fsanitize=$(SANITIZER)
endif

ifneq ($(CC),pgcc)
        ifeq ($(EXTRA_WARNINGS),y)
                CFLAGS+=-Wall -Wextra -Werror
        endif

        ifeq ($(ASAN),y)
                CFLAGS+=-fsanitize=address
        endif

        ifeq ($(UBSAN),y)
                CFLAGS+=-fsanitize=undefined
        endif
endif

example$(EXTENSION): munit.h munit.c example.c
	$(CC) $(CFLAGS) -o $@ munit.c example.c

test_setup$(EXTENSION): munit.h munit.c test_setup.c
	$(CC) $(CFLAGS) -o $@ munit.c test_setup.c

test:
	$(TEST_ENV) ./example$(EXTENSION)

clean:
	rm -f example$(EXTENSION)

all: example$(EXTENSION)

demo_actual.log:
	rm -f demo_actual.log && touch demo_actual.log
	bash ./demo.sh 2>&1 | tee -a demo_actual.log
	diff -q demo_actual.log demo_expected.log
.PHONY: demo_actual.log
