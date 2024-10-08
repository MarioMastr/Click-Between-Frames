cmake_minimum_required(VERSION 3.21)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_OSX_ARCHITECTURES "arm64")
set(GEODE_BINDINGS_REPO_PATH "/Users/ashrafmohamed/Documents/Geode/bindings")
set(CMAKE_CXX_VISIBILITY_PRESET hidden)

project(ClickBetweenFrames VERSION 1.0.0)

if(APPLE)
    set(INPUT_SRC "src/input.mm")
elseif(WIN32)
    set(INPUT_SRC "src/input.cpp")
endif()

add_library(${PROJECT_NAME} SHARED
    "src/main.cpp"
    ${INPUT_SRC}
)

if (APPLE)
target_link_libraries(${PROJECT_NAME} "-framework AppKit")
endif()

if (NOT DEFINED ENV{GEODE_SDK})
    message(FATAL_ERROR "Unable to find Geode SDK! Please define GEODE_SDK environment variable to point to Geode")
else()
    message(STATUS "Found Geode: $ENV{GEODE_SDK}")
endif()

add_subdirectory($ENV{GEODE_SDK} ${CMAKE_CURRENT_BINARY_DIR}/geode)

setup_geode_mod(${PROJECT_NAME})
