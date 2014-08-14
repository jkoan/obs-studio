project(text-freetype2)

find_package(Freetype QUIET)
if(NOT LIBFREETYPE_FOUND)
	message(STATUS "Freetype library not found, Freetype text plugin disabled")
	return()
endif()

find_library(COCOA Cocoa)

include_directories(${LIBFREETYPE_INCLUDE_DIRS}
	${COCOA})
add_definitions(${LIBFREETYPE_DEFINITIONS})

set(text-freetype2_SOURCES
	find-font-cocoa.m
	find-font.h
	obs-convenience.c
	text-functionality.c
	text-freetype2.c
	obs-convenience.h
	text-freetype2.h)

set_source_files_properties(find-font-cocoa.m
	PROPERTIES LANGUAGE C)

add_library(text-freetype2 MODULE
	${text-freetype2_SOURCES})
target_link_libraries(text-freetype2
	libobs
	${LIBFREETYPE_LIBRARIES}
	${COCOA})

install_obs_plugin(text-freetype2)
install_obs_plugin_data(text-freetype2 data)
