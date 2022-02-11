cmake_minimum_required(VERSION 3.4.1)
project("3rd")

include_directories("./build/x86_64/include")

set(CMAKE_CXX_STANDARD_LIBRARIES "-static-libgcc -static-libstdc++ -Wl,-Bstatic -lstdc++ -lpthread -Wl,-Bdynamic ${CMAKE_CXX_STANDARD_LIBRARIES}")

link_directories("${CMAKE_FIND_ROOT_PATH_MODE_LIBRARY}/")

add_library(3rd SHARED 3rd.cpp)

target_link_libraries(3rd libspatialite.a librttopo.a libgeos_c.a libgeos.a libproj.a libsqlite3.a libcharset.a libiconv.a libminizip.a libz.a)
