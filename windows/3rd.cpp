#include "sqlite3.h"
#include "spatialite.h"

int main() {
    spatialite_init_ex(nullptr, nullptr, 0);
    return 0;
}
