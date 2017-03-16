############################################################################
# This file is part of LImA, a Library for Image Acquisition
#
# Copyright (C) : 2009-2011
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
LIMA_DIR := $(shell pwd)/../../../..

include $(LIMA_DIR)/config.inc
include $(LIMA_DIR)/control/control.inc

include ../include/espia.inc

focla-objs = ../src/Espia.o

SRCS = testfocla.cpp testfoclahwinterface.cpp

LDFLAGS = -pthread -L$(ESPIA_DRV_LIB) \
	  -L$(LIMA_DIR)/third-party/Processlib/build \
	  -L$(LIMA_DIR)/build
LDLIBS = -lespia -llimacore -lprocesslib

HWINTER_LDFLAGS = $(LDFLAGS) 
HWINTER_LDLIBS = $(LDLIBS)

ifneq ($(COMPILE_CBF_SAVING), 0)
HWINTER_LDFLAGS += -L$(LIMA_DIR)/third-party/CBFLib/lib
HWINTER_LDLIBS += -lcbf
endif

ifneq ($(COMPILE_CONFIG), 0)
LDFLAGS += -L$(LIMA_DIR)/third-party/libconfig/lib/.libs
LDLIBS += -lconfig++
endif

CXXFLAGS = -I../include $(CT_CXXFLAGS) -I$(ESPIA_DRV_INCL)

all: testfocla testfoclahwinterface

testfocla:	testfocla.o $(focla-objs)
	$(CXX) $(LDFLAGS) -o $@ $+ $(LDLIBS)

testfoclahwinterface:	testfoclahwinterface.o $(focla-objs)
	$(CXX) $(HWINTER_LDFLAGS) -o $@ $+ $(HWINTER_LDLIBS)

clean:
	rm -f *.o testfocla testfoclahwinterface
%.o : %.cpp
	$(COMPILE.cpp) -MD $(CXXFLAGS) -o $@ $<
	@cp $*.d $*.P; \
	sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	-e '/^$$/ d' -e 's/$$/ :/' < $*.d >> $*.P; \
	rm -f $*.d

-include $(SRCS:.cpp=.P)
