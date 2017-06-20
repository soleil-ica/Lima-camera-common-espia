############################################################################
# This file is part of LImA, a Library for Image Acquisition
#
# Copyright (C) : 2009-2017
# European Synchrotron Radiation Facility
# BP 220, Grenoble 38043
# FRANCE
#
# This is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.
############################################################################

SET(espia_srcs src/Espia.cpp  src/FoclaHwInterface.cpp
	 src/EspiaAcq.cpp src/EspiaBufferMgr.cpp
	 src/EspiaDev.cpp src/EspiaFocla.cpp
	 src/EspiaSerialLine.cpp)

FILE(STRINGS "VERSION" espia_vers)
ADD_LIBRARY(limaespia SHARED ${espia_srcs})

TARGET_INCLUDE_DIRECTORIES(limaespia PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include")

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})
include(FindEspiaDrv)

#set paths for espia driver lib and include files
TARGET_INCLUDE_DIRECTORIES(limaespia PUBLIC "${ESPIA_DRV_INCLUDE_DIR}")

TARGET_LINK_LIBRARIES(limaespia limacore)
TARGET_LINK_LIBRARIES(limaespia ${ESPIA_DRV_LIB})


SET_TARGET_PROPERTIES(limaespia PROPERTIES VERSION ${espia_vers} SOVERSION "1")

INSTALL(TARGETS limaespia LIBRARY DESTINATION lib)

IF(COMPILE_SIP)
    SET(NAME "espia")
    SET(INCLUDES)
    FILE(GLOB sipfiles 
	      RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/sip"
	      "${CMAKE_CURRENT_SOURCE_DIR}/sip/*.sip")
    FOREACH(sipfile ${sipfiles})
        SET(INCLUDES 
"${INCLUDES} 
%Include ${sipfile}"
)
    ENDFOREACH()

    SET(IMPORTS
"%Import limacore.sip"
)

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
    SET_SOURCE_FILES_PROPERTIES("${CMAKE_CURRENT_BINARY_DIR}/sip/limaespia.sip" PROPERTIES OBJECT_DEPENDS ${sipfiles})
    set(SIP_DISABLE_FEATURES WITH_CONFIG)
    set(SIP_CHECK_EXC ON)
    ADD_SIP_PYTHON_MODULE(limaespia ${CMAKE_CURRENT_BINARY_DIR}/sip/limaespia.sip)
    TARGET_INCLUDE_DIRECTORIES(python_module_limaespia PRIVATE
                               ${PYTHON_INCLUDE_DIRS}
                               "${CMAKE_SOURCE_DIR}/sip"
                               "${CMAKE_SOURCE_DIR}/sip/core")
    TARGET_LINK_LIBRARIES(python_module_limaespia limaespia)

    INSTALL(FILES python/__init__.py DESTINATION "${PYTHON_SITE_PACKAGES_DIR}/Lima/Espia")
ENDIF()
