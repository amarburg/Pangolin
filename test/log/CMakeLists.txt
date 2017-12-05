# Find Pangolin (https://github.com/stevenlovegrove/Pangolin)
#find_package(Pangolin 0.4 REQUIRED)

fips_include_directories(../../include
                        ../../src/include
                        ${CMAKE_BINARY_DIR}/src/include
                        ${FIPS_PROJECT_BUILD_DIR}/include/ )

file(GLOB LOG_SOURCES ../../src/log/*.cpp)
file(GLOB UTIL_SOURCES ../../src/utils/*.cpp)

fips_begin_app(testlog cmdline)
  # add_executable(testlog testlog.cpp ${LOG_SOURCES})
  # target_link_libraries(testlog pthread)

  fips_files(testlog.cpp ${LOG_SOURCES} ${UTIL_SOURCES})
fips_end_app()
