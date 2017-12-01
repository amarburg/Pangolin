## Allows g3log/generated_definitions.hpp to be found
message( STATUS "Looking for Pangolin config files in ${FIPS_PROJECT_BUILD_DIR}/include/")

fips_include_directories( ${FIPS_PROJECT_BUILD_DIR}/include/ )
