#
# add test with sh script
#

function(proj_add_test_script_sh SH_NAME BIN_USE)
  if(UNIX)
    get_filename_component(testname ${SH_NAME} NAME_WE)

    set(TEST_OK 1)
    if(ARGV2)
      set(TEST_OK 0)
      set(GRID_FULLNAME ${PROJECT_SOURCE_DIR}/data/${ARGV2})
      if(EXISTS ${GRID_FULLNAME})
        set(TEST_OK 1)
      endif()
    endif()

    if(CMAKE_VERSION VERSION_LESS 2.8.4)
      set(TEST_OK 0)
      message(STATUS "test with bash script need a cmake version >= 2.8.4")
    endif()

    if(${TEST_OK})
      add_test(NAME "${testname}"
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/data
        COMMAND bash ${PROJECT_SOURCE_DIR}/test/cli/${SH_NAME}
        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${${BIN_USE}}
      )
    set_tests_properties( ${testname}
        PROPERTIES ENVIRONMENT "PROJ_LIB=${PROJECT_BINARY_DIR}/data")
    endif()

  endif()
endfunction()


function(proj_add_gie_test TESTNAME TESTCASE)

    set(GIE_BIN $<TARGET_FILE_NAME:gie>)
    set(TESTFILE ${CMAKE_SOURCE_DIR}/test/${TESTCASE})
    add_test(NAME ${TESTNAME}
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/test
      COMMAND ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${GIE_BIN}
      ${TESTFILE}
    )
    set_tests_properties( ${TESTNAME}
        PROPERTIES ENVIRONMENT "PROJ_LIB=${PROJECT_BINARY_DIR}/data")


endfunction()
