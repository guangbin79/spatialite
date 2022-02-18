.PHONY : clean

all : libsqlite3-pcre.a

sqlite3-pcre.o : sqlite3-pcre.c
	${CC} -c sqlite3-pcre.c -o $@ ${CFLAGS}

libsqlite3-pcre.a : sqlite3-pcre.o
	rm -f $@
	ar cr $@ sqlite3-pcre.o
	rm -f sqlite3-pcre.o

clean :
	-rm -f libsqlite3-pcre.a
