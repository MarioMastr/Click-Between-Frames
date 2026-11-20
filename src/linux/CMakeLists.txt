cmake_minimum_required(VERSION 3.21)

project(ClickBetweenFrames VERSION 1.0.0)

add_library(linux-input SHARED
	${CMAKE_CURRENT_SOURCE_DIR}/linux-input.cpp
)
target_link_libraries(linux-input evdev)

set_target_properties(linux-input PROPERTIES PREFIX "")

install(TARGETS linux-input DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/../../resources)
