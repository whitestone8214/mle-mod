#!/bin/bash


# C compiler
CC="gcc"

# "given": Just use the given one (Default, recommended)
# "static": Use termbox.h inside the termbox/. Source code available from: https://github.com/termbox/termbox2
# "dynamic": Use libtermbox.so installed on system by yourself. Source code available from: https://github.com/whitestone8214/termbox2-mod
WHICH_TERMBOX="given"

# https://github.com/troydhanson/uthash
# Set it empty if you have installed it on system
INCLUDE_UTHASH=

# Set it 1 if you want to use user-written script and have installed Lua 5.4
USE_USERSCRIPT=


if (test "$WHICH_TERMBOX" = "static"); then
	rm -rf termbox || exit 1
	git clone https://github.com/termbox/termbox2 termbox || exit 1
	INCLUDE_TERMBOX="-Itermbox"
elif (test "$WHICH_TERMBOX" = "dynamic"); then
	LINK_TERMBOX="-ltermbox"
else
	USE_GIVEN_TERMBOX="-DUSE_GIVEN_TERMBOX=1"
fi

SOURCES=(buffer bview cmd cursor editor main mark utf8 util)
if (test "$USE_USERSCRIPT" = "1"); then
	SOURCES+=(uscript)
	_USE_USERSCRIPT="-DUSE_USERSCRIPT=1"
	LINK_LUA="-llua5.4"
fi

rm -f *.o mle || exit 1
for x in ${SOURCES[@]}; do
	echo ":: Compile ${x}.c -> ${x}.o"
	${CC} -O3 -fPIC -c -D_GNU_SOURCE -DPCRE2_CODE_UNIT_WIDTH=8 ${USE_GIVEN_TERMBOX} ${_USE_USERSCRIPT} -I. ${INCLUDE_TERMBOX} ${INCLUDE_UTHASH} -lm -L/lib -lpcre2-8 ${x}.c || exit 1
done
echo ":: Link *.o -> mle"
${CC} -o mle ${LINK_TERMBOX} -lpcre2-8 ${LINK_LUA} -lm *.o || exit 1
