# Minimum CMake version required
cmake_minimum_required(VERSION 3.10)

# Project name and version
project(STL_CONTAINERS VERSION 1.0)

# Specify the C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Compiler flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror -Wextra -g")

# Include directories
include_directories(
    ${PROJECT_SOURCE_DIR}/array
    ${PROJECT_SOURCE_DIR}/list
    ${PROJECT_SOURCE_DIR}/map
    ${PROJECT_SOURCE_DIR}/queue
    ${PROJECT_SOURCE_DIR}/RBTRee
    ${PROJECT_SOURCE_DIR}/set
    ${PROJECT_SOURCE_DIR}/stack
    ${PROJECT_SOURCE_DIR}/vector
)

# Add the main library
add_library(s21_containers INTERFACE)
target_include_directories(s21_containers INTERFACE
    ${PROJECT_SOURCE_DIR}
)

# Check if Google Test is installed
find_package(GTest QUIET)

if (GTest_FOUND)
    message(STATUS "Google Test found in the system")
else()
    message(STATUS "Google Test not found, using the external version")
    add_subdirectory(external/googletest)
    set(GTest_LIBS gtest gtest_main)
endif()

# Enable code coverage
if(CMAKE_BUILD_TYPE STREQUAL "Coverage")
    message(STATUS "Building with code coverage support")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --coverage")
endif()

# Add the tests executable
add_executable(run_tests
    tests/test_array.cpp
    tests/test_list.cpp
    tests/test_map.cpp
    tests/test_queue.cpp
    tests/test_set.cpp
    tests/test_stack.cpp
    tests/test_vector_capacity.cpp
    tests/test_vector_init.cpp
    tests/test_vector_insert_many.cpp
    tests/test_vector_modifiers.cpp
)

# Link libraries
if (GTest_FOUND)
    target_link_libraries(run_tests PRIVATE s21_containers GTest::GTest GTest::Main)
else()
    target_link_libraries(run_tests PRIVATE s21_containers ${GTest_LIBS})
endif()

# Enable testing
enable_testing()
add_test(NAME run_tests COMMAND run_tests)

# Custom target to run tests and generate code coverage report
find_program(LCOV_PATH lcov)
find_program(GENHTML_PATH genhtml)
if(LCOV_PATH AND GENHTML_PATH)
    add_custom_target(coverage
        COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
        COMMAND ${LCOV_PATH} --capture --directory . --output-file coverage.info
        COMMAND ${LCOV_PATH} --remove coverage.info '/usr/*' '*/external/*' --output-file coverage.info
        COMMAND ${GENHTML_PATH} coverage.info --output-directory coverage_report
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Running tests and generating code coverage report"
    )
else()
    message(STATUS "lcov or genhtml not found, coverage target will not be available")
endif()
