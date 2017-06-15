# CMakeLists.txt for Espia

SET(espia_srcs src/Espia.cpp  src/FoclaHwInterface.cpp
	 src/EspiaAcq.cpp src/EspiaBufferMgr.cpp
	 src/EspiaDev.cpp src/EspiaFocla.cpp
	 src/EspiaSerialLine.cpp)

FILE(STRINGS "VERSION" espia_vers)
ADD_LIBRARY(limaespia SHARED ${espia_srcs})

TARGET_INCLUDE_DIRECTORIES(limaespia PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include")

EXECUTE_PROCESS(
	COMMAND uname -r 
	OUTPUT_VARIABLE KERNEL_RELEASE
	OUTPUT_STRIP_TRAILING_WHITESPACE)

SET(BLISS_DRV_DIR /segfs/bliss/source/driver)
MESSAGE(${KERNEL_RELEASE})
IF(KERNEL_RELEASE MATCHES "^2.6")
	SET(ESPIA_DRV_DIR ${BLISS_DRV_DIR}/linux-2.6/compile/redhate5/espia/release)
ELSEIF(KERNEL_RELEASE MATCHES "^3.16")
	SET(ESPIA_DRV_DIR ${BLISS_DRV_DIR}/linux-3.16)
ELSE()
	MESSAGE(FATAL_ERROR "Unsupported kernel release ${KERNEL_RELEASE}")
ENDIF()
SET(ESPIA_DRV_LIB_DIR ${ESPIA_DRV_DIR}/lib/x86_64)

#set paths for espia driver lib and include files
TARGET_INCLUDE_DIRECTORIES(limaespia PUBLIC "${ESPIA_DRV_DIR}/src")

LINK_DIRECTORIES(${ESPIA_DRV_LIB_DIR})
FIND_LIBRARY(ESPIA_DRV_LIB espia ${ESPIA_DRV_LIB_DIR})

TARGET_LINK_LIBRARIES(limaespia limacore)
TARGET_LINK_LIBRARIES(limaespia ${ESPIA_DRV_LIB})


SET_TARGET_PROPERTIES(limaespia PROPERTIES VERSION ${espia_vers} SOVERSION "1")

INSTALL(TARGETS limaespia LIBRARY DESTINATION lib)

IF(COMPILE_SIP)
    SET(NAME "espia")
    SET(INCLUDES)
    FILE(GLOB sipfiles RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/sip" "${CMAKE_CURRENT_SOURCE_DIR}/sip/*.sip")
    FOREACH(sipfile ${sipfiles})
        SET(INCLUDES 
"${INCLUDES} 
%Include ${sipfile}"
)
    ENDFOREACH()

    IF(SIP_VERSION_STR VERSION_LESS "4.12")
    	CONFIGURE_FILE(${CMAKE_SOURCE_DIR}/sip/limamodules_before_4_12.sip.in sip/limaespia.sip)
    ELSE()
    	CONFIGURE_FILE(${CMAKE_SOURCE_DIR}/sip/limamodules.sip.in sip/limaespia.sip)
    ENDIF()

    SET(SIP_CONCAT_PARTS 1)
    SET(SIP_INCLUDES ${SIP_INCLUDES}
        "${CMAKE_SOURCE_DIR}/third-party/Processlib/sip"
        "${CMAKE_BINARY_DIR}/sip/core"
        "${CMAKE_SOURCE_DIR}/third-party/Processlib/tasks/sip"
        "${CMAKE_SOURCE_DIR}/common/sip"
        "${CMAKE_SOURCE_DIR}/hardware/sip"
        "${CMAKE_SOURCE_DIR}/control/sip"
        "${CMAKE_SOURCE_DIR}/control/software_operation/sip"
        "${CMAKE_CURRENT_SOURCE_DIR}/sip")
    set(SIP_DISABLE_FEATURES WITH_CONFIG)
    SET_SOURCE_FILES_PROPERTIES(${CMAKE_CURRENT_BINARY_DIR}/sip/limaespia.sip PROPERTIES OBJECT_DEPENDS ${sipfiles})
    set(SIP_CHECK_EXC ON)
    ADD_SIP_PYTHON_MODULE(limaespia ${CMAKE_CURRENT_BINARY_DIR}/sip/limaespia.sip)
    TARGET_INCLUDE_DIRECTORIES(python_module_limaespia PRIVATE
                               ${PYTHON_INCLUDE_DIRS}
                               "${CMAKE_SOURCE_DIR}/sip"
                               "${CMAKE_SOURCE_DIR}/sip/core")
    TARGET_LINK_LIBRARIES(python_module_limaespia limaespia)

    INSTALL(FILES python/__init__.py DESTINATION "${PYTHON_SITE_PACKAGES_DIR}/Lima/Espia")
ENDIF()
