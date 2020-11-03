################################################################################################
# Caffe status report function.
# Automatically align right column and selects text based on condition.
# Usage:
#   caffe_status(<text>)
#   caffe_status(<heading> <value1> [<value2> ...])
#   caffe_status(<heading> <condition> THEN <text for TRUE> ELSE <text for FALSE> )
function(caffe_status text)
  set(status_cond)
  set(status_then)
  set(status_else)

  set(status_current_name "cond")
  foreach(arg ${ARGN})
    if(arg STREQUAL "THEN")
      set(status_current_name "then")
    elseif(arg STREQUAL "ELSE")
      set(status_current_name "else")
    else()
      list(APPEND status_${status_current_name} ${arg})
    endif()
  endforeach()

  if(DEFINED status_cond)
    set(status_placeholder_length 23)
    string(RANDOM LENGTH ${status_placeholder_length} ALPHABET " " status_placeholder)
    string(LENGTH "${text}" status_text_length)
    if(status_text_length LESS status_placeholder_length)
      string(SUBSTRING "${text}${status_placeholder}" 0 ${status_placeholder_length} status_text)
    elseif(DEFINED status_then OR DEFINED status_else)
      message(STATUS "${text}")
      set(status_text "${status_placeholder}")
    else()
      set(status_text "${text}")
    endif()

    if(DEFINED status_then OR DEFINED status_else)
      if(${status_cond})
        string(REPLACE ";" " " status_then "${status_then}")
        string(REGEX REPLACE "^[ \t]+" "" status_then "${status_then}")
        message(STATUS "${status_text} ${status_then}")
      else()
        string(REPLACE ";" " " status_else "${status_else}")
        string(REGEX REPLACE "^[ \t]+" "" status_else "${status_else}")
        message(STATUS "${status_text} ${status_else}")
      endif()
    else()
      string(REPLACE ";" " " status_cond "${status_cond}")
      string(REGEX REPLACE "^[ \t]+" "" status_cond "${status_cond}")
      message(STATUS "${status_text} ${status_cond}")
    endif()
  else()
    message(STATUS "${text}")
  endif()
endfunction()


################################################################################################
# Function for fetching Caffe version from git and headers
# Usage:
#   caffe_extract_caffe_version()
function(caffe_extract_caffe_version)
  set(Caffe_GIT_VERSION "unknown")
  find_package(Git)
  if(GIT_FOUND)
    execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags --always --dirty
                    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE
                    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
                    OUTPUT_VARIABLE Caffe_GIT_VERSION
                    RESULT_VARIABLE __git_result)
    if(NOT ${__git_result} EQUAL 0)
      set(Caffe_GIT_VERSION "unknown")
    endif()
  endif()

  set(Caffe_GIT_VERSION ${Caffe_GIT_VERSION} PARENT_SCOPE)
  set(Caffe_VERSION "<TODO> (Caffe doesn't declare its version in headers)" PARENT_SCOPE)

  # caffe_parse_header(${Caffe_INCLUDE_DIR}/caffe/version.hpp Caffe_VERSION_LINES CAFFE_MAJOR CAFFE_MINOR CAFFE_PATCH)
  # set(Caffe_VERSION "${CAFFE_MAJOR}.${CAFFE_MINOR}.${CAFFE_PATCH}" PARENT_SCOPE)

  # or for #define Caffe_VERSION "x.x.x"
  # caffe_parse_header_single_define(Caffe ${Caffe_INCLUDE_DIR}/caffe/version.hpp Caffe_VERSION)
  # set(Caffe_VERSION ${Caffe_VERSION_STRING} PARENT_SCOPE)

endfunction()


################################################################################################
# Prints accumulated caffe configuration summary
# Usage:
#   caffe_print_configuration_summary()

function(caffe_print_configuration_summary)
  caffe_extract_caffe_version()
  set(Caffe_VERSION ${Caffe_VERSION} PARENT_SCOPE)

  caffe_merge_flag_lists(__flags_rel CMAKE_CXX_FLAGS_RELEASE CMAKE_CXX_FLAGS)
  caffe_merge_flag_lists(__flags_deb CMAKE_CXX_FLAGS_DEBUG   CMAKE_CXX_FLAGS)

  caffe_status("")
  caffe_status("******************* Caffe Configuration Summary *******************")
  caffe_status("General:")
  caffe_status("  Version           :   ${CAFFE_TARGET_VERSION}")
  caffe_status("  Git               :   ${Caffe_GIT_VERSION}")
  caffe_status("  System            :   ${CMAKE_SYSTEM_NAME}")
  caffe_status("  C++ compiler      :   ${CMAKE_CXX_COMPILER}")
  caffe_status("  Release CXX flags :   ${__flags_rel}")
  caffe_status("  Debug CXX flags   :   ${__flags_deb}")
  caffe_status("  Build type        :   ${CMAKE_BUILD_TYPE}")
  caffe_status("")
  caffe_status("  BUILD_SHARED_LIBS :   ${BUILD_SHARED_LIBS}")
  caffe_status("  BUILD_python      :   ${BUILD_python}")
  caffe_status("  BUILD_matlab      :   ${BUILD_matlab}")
  caffe_status("  BUILD_docs        :   ${BUILD_docs}")
  caffe_status("  CPU_ONLY          :   ${CPU_ONLY}")
  caffe_status("  USE_OPENCV        :   ${USE_OPENCV}")
  caffe_status("  USE_LEVELDB       :   ${USE_LEVELDB}")
  caffe_status("  USE_LMDB          :   ${USE_LMDB}")
  caffe_status("  USE_MATIO         :   ${USE_MATIO}")
  caffe_status("  USE_NCCL          :   ${USE_NCCL}")
  caffe_status("  ALLOW_LMDB_NOLOCK :   ${ALLOW_LMDB_NOLOCK}")
  # This code is taken from https://github.com/sh1r0/caffe-android-lib
  caffe_status("  USE_HDF5          :   ${USE_HDF5}")
  caffe_status("")
  caffe_status("Dependencies:")
  caffe_status("  BLAS              : " APPLE THEN "Yes (vecLib)" ELSE "Yes (${BLAS})")
  caffe_status("  Boost             :   Yes (ver. ${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION})")
  caffe_status("  glog              :   Yes")
  caffe_status("  gflags            :   Yes")
  caffe_status("  protobuf          : " PROTOBUF_FOUND THEN "Yes (ver. ${PROTOBUF_VERSION})" ELSE "No" )
  if(USE_LMDB)
    caffe_status("  lmdb              : " LMDB_FOUND THEN "Yes (ver. ${LMDB_VERSION})" ELSE "No")
  endif()
  if(USE_LEVELDB)
    caffe_status("  LevelDB           : " LEVELDB_FOUND THEN  "Yes (ver. ${LEVELDB_VERSION})" ELSE "No")
    caffe_status("  Snappy            : " SNAPPY_FOUND THEN "Yes (ver. ${Snappy_VERSION})" ELSE "No" )
  endif()
  if(USE_MATIO)
    caffe_status("  matio             : " MATIO_FOUND THEN "Yes (ver. ${MATIO_VERSION})" ELSE "No")
  endif()
  if(USE_OPENCV)
    caffe_status("  OpenCV            :   Yes (ver. ${OpenCV_VERSION})")
  endif()
  caffe_status("  CUDA              : " HAVE_CUDA THEN "Yes (ver. ${CUDA_VERSION})" ELSE "No" )
  caffe_status("")
  if(HAVE_CUDA)
    caffe_status("NVIDIA CUDA:")
    caffe_status("  Target GPU(s)     :   ${CUDA_ARCH_NAME}" )
    caffe_status("  GPU arch(s)       :   ${NVCC_FLAGS_EXTRA_readable}")
    if(USE_CUDNN)
      caffe_status("  cuDNN             : " HAVE_CUDNN THEN "Yes (ver. ${CUDNN_VERSION})" ELSE "Not found")
    else()
      caffe_status("  cuDNN             :   Disabled")
    endif()
    caffe_status("")
  endif()
  if(HAVE_PYTHON)
    caffe_status("Python:")
    caffe_status("  Interpreter       :" PYTHON_EXECUTABLE THEN "${PYTHON_EXECUTABLE} (ver. ${PYTHON_VERSION_STRING})" ELSE "No")
    caffe_status("  Libraries         :" PYTHONLIBS_FOUND  THEN "${PYTHON_LIBRARIES} (ver ${PYTHONLIBS_VERSION_STRING})" ELSE "No")
    caffe_status("  NumPy             :" NUMPY_FOUND  THEN "${NUMPY_INCLUDE_DIR} (ver ${NUMPY_VERSION})" ELSE "No")
    caffe_status("")
  endif()
  if(BUILD_matlab)
    caffe_status("Matlab:")
    caffe_status("  Matlab            :" HAVE_MATLAB THEN "Yes (${Matlab_mex}, ${Matlab_mexext}" ELSE "No")
    caffe_status("  Octave            :" Octave_compiler THEN  "Yes (${Octave_compiler})" ELSE "No")
    if(HAVE_MATLAB AND Octave_compiler)
      caffe_status("  Build mex using   :   ${Matlab_build_mex_using}")
    endif()
    caffe_status("")
  endif()
  if(BUILD_docs)
    caffe_status("Documentaion:")
    caffe_status("  Doxygen           :" DOXYGEN_FOUND THEN "${DOXYGEN_EXECUTABLE} (${DOXYGEN_VERSION})" ELSE "No")
    caffe_status("  config_file       :   ${DOXYGEN_config_file}")

    caffe_status("")
  endif()
  caffe_status("Install:")
  caffe_status("  Install path      :   ${CMAKE_INSTALL_PREFIX}")
  caffe_status("")
endfunction()
