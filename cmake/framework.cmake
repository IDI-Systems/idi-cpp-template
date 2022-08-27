macro(idi_cmake_hook_abs hook_path)
    include(${hook_path} OPTIONAL)
endmacro()

macro(idi_cmake_hook hook_name)
    idi_cmake_hook_abs(${PROJECT_SOURCE_DIR}/cmake-hooks/${hook_name}.cmake)
endmacro()

macro(idi_init)
    include(${PROJECT_SOURCE_DIR}/cmake/version.cmake)
    idi_cmake_hook(pre-init)

    cmake_policy(SET CMP0079 NEW)

    string(TOUPPER ${CMAKE_SOURCE_DIR} CMAKE_SOURCE_DIR_UPPER)
    string(TOUPPER ${PROJECT_SOURCE_DIR} PROJECT_SOURCE_DIR_UPPER)

    if(CMAKE_SOURCE_DIR_UPPER STREQUAL PROJECT_SOURCE_DIR_UPPER)
        set(IDI_IS_SUBDIRECTORY false)
    else()
        message(STATUS "Project ${IDI_PROJECT_NAME} has been added by another project via add_subdirectory, include paths will be relative to ${IDI_PROJECT_NAME}/")
        set(IDI_IS_SUBDIRECTORY true)
    endif()

    if(IDI_IS_SHARED AND (NOT IDI_IS_LIBRARY))
        message(FATAL_ERROR "IDI_IS_SHARED is set to TRUE but IDI_IS_LIBRARY is set to FALSE in platform configuration, please set IDI_IS_LIBRARY to true if you wish to build a shared library.")
    endif()

    idi_cmake_hook(pre-options)

    # backwards compat with old configuration for naming
    set(IDI_IS_DYNAMIC ${IDI_IS_SHARED})
    string(TOUPPER ${IDI_PROJECT_NAME} IDI_PREFIX_UPPER)
    set(IDI_PREFIX ${IDI_PREFIX_UPPER})

    set("${IDI_PREFIX}_BUILD_DEMOS" 1 CACHE BOOL "Build demo applications if applicable.")
    set("${IDI_PREFIX}_BUILD_TESTS" 1 CACHE BOOL "Build unit tests.")
    set("${IDI_PREFIX}_USE_GIT_VERSIONING" 1 CACHE BOOL "Check git for version information related to hashes and branches.")
    set("${IDI_PREFIX}_USE_BUILD_TIMESTAMPS" 0 CACHE BOOL "Set the current time for the build as build info. Disabled by default as it can increase build time during development.")
    set("${IDI_PREFIX}_DO_TEMPLATE_COMPONENT_TEST" 0 CACHE BOOL "Generate unit test template component and build unit tests for template.")
    set("${IDI_PREFIX}_FORCE_PIC" 0 CACHE BOOL "Force the use of Position Independent Code (PIC). This is useful if this library is a static library being included in a shared library.")
    set("${IDI_PREFIX}_CI_GIT_BRANCH_NAME" "" CACHE STRING "The branch name of the git repo. If not set it will be interogated from Git itself, but could result in a value of HEAD.")

    include(${PROJECT_SOURCE_DIR}/platform-compile-options.cmake)

    idi_cmake_hook(post-options)

    set("IDI_BUILD_DEMOS" "${${IDI_PREFIX}_BUILD_DEMOS}")
    set("IDI_BUILD_TESTS" "${${IDI_PREFIX}_BUILD_TESTS}")
    set("IDI_USE_GIT_VERSIONING" "${${IDI_PREFIX}_USE_GIT_VERSIONING}")
    set("IDI_USE_BUILD_TIMESTAMPS" "${${IDI_PREFIX}_USE_BUILD_TIMESTAMPS}")
    set("IDI_DO_TEMPLATE_COMPONENT_TEST" "${${IDI_PREFIX}_DO_TEMPLATE_COMPONENT_TEST}")
    set("IDI_CI_GIT_BRANCH_NAME" "${${IDI_PREFIX}_CI_GIT_BRANCH_NAME}")
    set("IDI_FORCE_PIC" "${${IDI_PREFIX}_FORCE_PIC}")

    set(__idi_vendor_namespace ${IDI_VENDOR_NAMESPACE})
    set(__idi_app_namespace ${IDI_APP_NAMESPACE})
    set(__idi_project_name ${IDI_PROJECT_NAME})

    if(NOT IDI_IS_SUBDIRECTORY)
        set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
        set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
    endif()

    message(STATUS "[${IDI_PROJECT_NAME}] IDI CPP CMake Framework: v${IDI_CPP_FRAMEWORK_VERSION_MAJOR}.${IDI_CPP_FRAMEWORK_VERSION_MINOR}.${IDI_CPP_FRAMEWORK_VERSION_HOTFIX}")
    message(STATUS "[${IDI_PROJECT_NAME}] Load status IDI_IS_SUBDIRECTORY: ${IDI_IS_SUBDIRECTORY}")
    message(STATUS "[${IDI_PROJECT_NAME}] Config IDI_IS_LIBRARY: ${IDI_IS_LIBRARY}")
    message(STATUS "[${IDI_PROJECT_NAME}] Config IDI_IS_SHARED: ${IDI_IS_SHARED}")
    message(STATUS "[${IDI_PROJECT_NAME}] Compiler IDI_MSVC_PRIVATE_COMPILE_OPTIONS: ${IDI_MSVC_PRIVATE_COMPILE_OPTIONS}")
    message(STATUS "[${IDI_PROJECT_NAME}] Compiler IDI_MSVC_PRIVATE_COMPILE_DEFINITIONS: ${IDI_MSVC_PRIVATE_COMPILE_DEFINITIONS}")
    message(STATUS "[${IDI_PROJECT_NAME}] Compiler IDI_GNU_PRIVATE_COMPILE_OPTIONS: ${IDI_GNU_PRIVATE_COMPILE_OPTIONS}")
    message(STATUS "[${IDI_PROJECT_NAME}] Compiler IDI_PRIVATE_COMPILE_FEATURES: ${IDI_PRIVATE_COMPILE_FEATURES}")

    include(CTest)
    include("${CMAKE_CURRENT_LIST_DIR}/cmake/component.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/cmake/new-component.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/cmake/code-coverage.cmake")

    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/reports)

    # Define a nice short hand for 3rd party external library folders
    set(IDI_EXTERNAL_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/lib")

    # Add the main source folder.
    idi_cmake_hook(pre-source)
    add_subdirectory("src")
    idi_cmake_hook(post-source)

    # Catch is included by default as a submodule
    if(NOT TARGET Catch2)
        add_subdirectory(lib/Catch2)
    endif()

    if(IDI_BUILD_DEMOS)
        add_subdirectory("demo")
    endif()

    include("${CMAKE_CURRENT_LIST_DIR}/lib/libraries.cmake")
endmacro()

macro(idi_src)
    include(CMakePrintHelpers)
    add_code_coverage_all_targets(EXCLUDE tests/* lib/*)
    #####################################################################
    # CORE LIBRARY                                                      #
    #####################################################################

    if(IDI_IS_LIBRARY)
        set(IDI_MAIN_TARGET "${IDI_PROJECT_NAME}")
        set(IDI_CORE "${IDI_MAIN_TARGET}")
        if(IDI_IS_SHARED)
            add_library("${IDI_MAIN_TARGET}" SHARED "")
        endif()
    endif()

    if (NOT IDI_IS_LIBRARY)
        set(IDI_MAIN_TARGET "${IDI_PROJECT_NAME}")
        set(IDI_CORE "${IDI_PROJECT_NAME}_core")
        target_code_coverage("${IDI_CORE}" ALL)
    endif()

    if (NOT IDI_IS_SHARED)
        add_library("${IDI_CORE}" STATIC "")
    endif()

    set(IDI_CORE ${IDI_CORE} PARENT_SCOPE)
    idi_target_compile_settings("${IDI_CORE}")
    set_target_properties("${IDI_CORE}" PROPERTIES LINKER_LANGUAGE CXX)

    #####################################################################
    # CORE COMPONENTS                                                   #
    #####################################################################

    # List core components below via add_subdirectory
    idi_cmake_hook(pre-components-list)
    include("${CMAKE_CURRENT_LIST_DIR}/components.cmake")
    idi_cmake_hook(post-components-list)

    if(DO_TEMPLATE_COMPONENT_TEST)
        add_subdirectory("unit_test_component")
    endif()

    #####################################################################
    # MAIN TARGET                                                       #
    #####################################################################
    if((IDI_IS_LIBRARY AND IDI_IS_SHARED) OR (NOT IDI_IS_LIBRARY))
        if(IDI_IS_SHARED)
            set_target_properties("${IDI_MAIN_TARGET}" PROPERTIES CXX_VISIBILITY_PRESET hidden)
            set_target_properties("${IDI_MAIN_TARGET}" PROPERTIES C_VISIBILITY_PRESET hidden)

            target_sources(
                "${IDI_MAIN_TARGET}"
                PRIVATE
                # EDIT LIST FILES BELOW HERE
                "${CMAKE_CURRENT_LIST_DIR}/main/dll_main.cpp"
            )
            install(TARGETS "${IDI_MAIN_TARGET}"
                    LIBRARY FILE_SET HEADERS DESTINATION includes/${IDI_MAIN_TARGET}/public)
        else()
            add_executable("${IDI_MAIN_TARGET}" "")
            target_sources(
                "${IDI_MAIN_TARGET}"
                PRIVATE
                # EDIT LIST FILES BELOW HERE
                "${CMAKE_CURRENT_LIST_DIR}/main/main.cpp"
            )
            target_link_libraries("${IDI_MAIN_TARGET}" "${IDI_CORE}")
            idi_target_compile_settings("${IDI_MAIN_TARGET}")
            set_target_properties("${IDI_MAIN_TARGET}" PROPERTIES LINKER_LANGUAGE CXX)
            install(TARGETS "${IDI_MAIN_TARGET}"
                RUNTIME)
        endif()
        add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/main")
        get_target_property(IDI_MAIN_TARGET_SOURCES "${IDI_MAIN_TARGET}" SOURCES)
            source_group(TREE ${CMAKE_CURRENT_LIST_DIR}
        FILES ${IDI_MAIN_TARGET_SOURCES})
        target_code_coverage("${IDI_MAIN_TARGET}" ALL OBJECTS "${IDI_CORE}")
    else()
        install(TARGETS "${IDI_CORE}"
            ARCHIVE)
    endif()

endmacro()

macro(idi_main)
    include("${CMAKE_CURRENT_LIST_DIR}/objects.cmake")
    target_include_directories("${IDI_MAIN_TARGET}" PRIVATE "${CMAKE_CURRENT_LIST_DIR}")
    include("${CMAKE_CURRENT_LIST_DIR}/tests/tests.cmake")
endmacro()

macro(idi_configure_common_includes)
    set(IDI_PROJECT_NAME_STR ${IDI_PROJECT_NAME})

    configure_file(${PROJECT_SOURCE_DIR}/idi_version.h ${CMAKE_CURRENT_LIST_DIR}/__idi_version.out.h)
    message( STATUS "Configured CI Branch Name: ${IDI_CI_GIT_BRANCH_NAME}")
    add_custom_target("${IDI_PROJECT_NAME}GetBuildInfo" COMMAND ${CMAKE_COMMAND}
        -Dlocal_dir="${CMAKE_CURRENT_LIST_DIR}"
        -Doutput_dir="${CMAKE_CURRENT_LIST_DIR}"
        -Duse_git_versioning="${IDI_USE_GIT_VERSIONING}"
        -Duse_build_timestamps="${IDI_USE_BUILD_TIMESTAMPS}"
        -Dgit_branch_name="${IDI_CI_GIT_BRANCH_NAME}"
        -P "${PROJECT_SOURCE_DIR}/cmake/build-info.cmake"
        )

    add_dependencies("${IDI_PROJECT_NAME}_common" "${IDI_PROJECT_NAME}GetBuildInfo")
endmacro()

