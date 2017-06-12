# CMakeLists.txt for Espia

SET(CMAKE_SHARED_LINKER_FLAGS "-Wl,--add-needed")


SET(espia_srcs src/Espia.cpp  src/FoclaHwInterface.cpp
	 src/EspiaAcq.cpp src/EspiaBufferMgr.cpp
	 src/EspiaDev.cpp src/EspiaFocla.cpp
	 src/EspiaSerialLine.cpp)

FILE(STRINGS "VERSION" espia_vers)
ADD_LIBRARY(limaespia SHARED ${espia_vers})

TARGET_INCLUDE_DIRECTORIES(limaespia PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include")

#FIND_LIBRARY(ESPIA_LIB nom_espia_lib ${})

TARGET_LINK_LIBRARIES(limaespia limacore)


SET_TARGET_PROPERTIES(limaespia PROPERTIES VERSION ${espia_vers} SOVERSION "1")

INSTALL(TARGETS limaespia LIBRARY DESTINATION lib)

IF(COMPILE_SIP)
    SET(NAME "espia")
    SET(INCLUDES)
    FILE(GLOB sipfiles RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/sip" "${CMAKE_CURRENT_SOURCE_DIR}/sip/*.sip")
    FOREACH(sipfile ${sipfiles})
        SET(INCLUDES 
        "${INCLUDES} 
        %Include ${sipfile}")
    ENDFOREACH()

    CONFIGURE_FILE(${CMAKE_SOURCE_DIR}/sip/limamodules.sip.in sip/limaespia.sip)
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
    set(SIP_CHECK_EXC ON)
    ADD_SIP_PYTHON_MODULE(limaespia ${CMAKE_CURRENT_BINARY_DIR}/sip/limaespia.sip)
    TARGET_INCLUDE_DIRECTORIES(python_module_limaespia PRIVATE
                               ${PYTHON_INCLUDE_DIRS}
                               "${CMAKE_SOURCE_DIR}/sip"
                               "${CMAKE_SOURCE_DIR}/sip/core")
    TARGET_LINK_LIBRARIES(python_module_limaespia limaespia)

    INSTALL(FILES python/__init__.py DESTINATION "${PYTHON_SITE_PACKAGES_DIR}/Lima/Common/Espia")
ENDIF()
