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

EXECUTE_PROCESS(
       COMMAND uname -r 
       OUTPUT_VARIABLE KERNEL_RELEASE
       OUTPUT_STRIP_TRAILING_WHITESPACE)

SET(BLISS_DRV_DIR /segfs/bliss/source/driver)
IF(KERNEL_RELEASE MATCHES "^2.6")
       SET(ESPIA_DRV_DIR ${BLISS_DRV_DIR}/linux-2.6/compile/redhate5/espia/release)
ELSEIF(KERNEL_RELEASE MATCHES "^3.16")
       SET(ESPIA_DRV_DIR ${BLISS_DRV_DIR}/linux-3.16)
ELSE()
       MESSAGE(FATAL_ERROR "Unsupported kernel release ${KERNEL_RELEASE}")
ENDIF()
SET(ESPIA_DRV_LIB_DIR ${ESPIA_DRV_DIR}/lib/x86_64)
