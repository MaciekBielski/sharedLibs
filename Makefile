# Author: Maciej Bielski
#

CC=gcc
FLAGS= -fPIC -g -Wall 
INC= -I./include
SRCDIR= src
OBJDIR= build
RELDIR= release
DEVDIR= dev
SRCS=$(wildcard $(SRCDIR)/*.c)
OBJS=$(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(SRCS))
LIBNAME= qooqoo
VERNB= 2
RELNB= 0
TARGET= lib${LIBNAME}.so.${VERNB}
COMP_NAME= lib${LIBNAME}.so

vpath %.h include
.PHONY: library release clean_release clean_v1 ultraclean test_build clean_build

library: ${OBJDIR}/${TARGET}

# building the library
${OBJDIR}/${TARGET}: ${OBJS} 
	${CC} -shared -Wl,-soname,${TARGET} -o ${OBJDIR}/${TARGET}.${RELNB} $^
	@echo [+] library: ${TARGET} built!

${OBJDIR}/%.o: ${SRCDIR}/%.c | ${OBJDIR}
	${CC} ${INC} ${FLAGS} -o $@ -c $<

${OBJDIR}:
	mkdir -p ${OBJDIR}

# releasing
release:
	mkdir -p ${RELDIR}
	cp ${OBJDIR}/${TARGET}.${RELNB} ${RELDIR}/${TARGET}.${RELNB}
	cd ${RELDIR} && ln -sf ${TARGET}.${RELNB} ${COMP_NAME}
	sudo ldconfig -v -n ${RELDIR}

# testing
test_build: ${OBJDIR}/${TARGET}.${RELNB}
	cd ${OBJDIR} && ln -sf ${TARGET}.${RELNB} ${COMP_NAME}
	sudo ldconfig -v -n ${OBJDIR}

client_test: ${DEVDIR}/client_test.c
	${CC} ${INC} -g -o ${DEVDIR}/$@ $< -L${OBJDIR} -l${LIBNAME} -Wl,-rpath,${OBJDIR}

run_test:
	${DEVDIR}/client_test

# release client_v1
client_v1: ${DEVDIR}/client_v1.c
	${CC} ${INC} -g -o ${DEVDIR}/$@ $< -L${RELDIR} -l${LIBNAME}

run_v1:
	/lib64/ld-linux-x86-64.so.2 --library-path ${RELDIR} ${DEVDIR}/client_v1

# release client_v2
client_v2: ${DEVDIR}/client_v2.c
	${CC} ${INC} -g -o ${DEVDIR}/$@ $< -L${RELDIR} -l${LIBNAME}

run_v2:
	/lib64/ld-linux-x86-64.so.2 --library-path ${RELDIR} ${DEVDIR}/client_v2

# clean-up
clean_build:
	-rm -rf ${OBJDIR}

clean_release:
	-rm -rf ${RELDIR}

clean_v1:
	-rm -rf ${DEVDIR}/client_v1

clean_v2:
	-rm -rf ${DEVDIR}/client_v2

clean_test:
	-rm -rf ${DEVDIR}/client_test

ultraclean: clean_release clean_v1 clean_v2 clean_build clean_test

