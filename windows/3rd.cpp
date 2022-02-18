#include "sqlite3.h"
#include "spatialite.h"
#include "sqlite3-pcre.h"

int main() {
    spatialite_init_ex(nullptr, nullptr, 0);
    sqlite3_pcre_init(nullptr, nullptr);
    return 0;
}
