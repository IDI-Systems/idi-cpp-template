/**
 * @author Cliff Foster (Nou) <cliff@idi-systems.com>
 * 
 * @copyright Copyright (c) 2019 International Development & Integration Systems LLC
 * 
 */
#include <iostream>
#include <version.h>

int main() {
    std::cout << "v" << idi_common_get_version_major() << "." <<
        idi_common_get_version_minor() << "." <<
        idi_common_get_version_patch();
    return 0;
}