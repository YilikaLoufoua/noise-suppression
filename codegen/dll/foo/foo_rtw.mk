###########################################################################
## Makefile generated for component 'foo'. 
## 
## Makefile     : foo_rtw.mk
## Generated on : Wed Apr 06 00:46:26 2022
## Final product: ./foo.js
## Product type : dynamic-library
## 
###########################################################################

###########################################################################
## MACROS
###########################################################################

# Macro Descriptions:
# PRODUCT_NAME            Name of the system to build
# MAKEFILE                Name of this makefile
# DEF_FILE                Definition file

PRODUCT_NAME              = foo
MAKEFILE                  = foo_rtw.mk
MATLAB_ROOT               = C:/PROGRA~1/MATLAB/R2021b
MATLAB_BIN                = C:/PROGRA~1/MATLAB/R2021b/bin
MATLAB_ARCH_BIN           = $(MATLAB_BIN)/win64
START_DIR                 = C:/Users/yilik/Documents/GitHub/noise-suppression
TGT_FCN_LIB               = ISO_C++11
SOLVER_OBJ                = 
CLASSIC_INTERFACE         = 0
MODEL_HAS_DYNAMICALLY_LOADED_SFCNS = 
RELATIVE_PATH_TO_ANCHOR   = ../../..
DEF_FILE                  = $(PRODUCT_NAME).def
C_STANDARD_OPTS           = 
CPP_STANDARD_OPTS         = 

###########################################################################
## TOOLCHAIN SPECIFICATIONS
###########################################################################

# Toolchain Name:          Emscripten v3.1.8 | gmake (64-bit Windows)
# Supported Version(s):    
# ToolchainInfo Version:   2021b
# Specification Revision:  1.0
# 

#-----------
# MACROS
#-----------

SUPPORTPACKAGEINCLUDE = C:\Users\yilik\AppData\Roaming\MathWorks\MATLAB-Add-Ons\Toolboxes\GenerateJavaScriptUsingMATLABCoder\cpp\include
SUPPORTPACKAGESRC     = C:\Users\yilik\AppData\Roaming\MathWorks\MATLAB-Add-Ons\Toolboxes\GenerateJavaScriptUsingMATLABCoder\cpp\src

TOOLCHAIN_SRCS = 
TOOLCHAIN_INCS = 
TOOLCHAIN_LIBS = 

#------------------------
# BUILD TOOL COMMANDS
#------------------------

# C Compiler: Emscripten C Compiler
CC = emcc

# Linker: Emscripten C Linker
LD = emcc

# C++ Compiler: Emscripten C++ Compiler
CPP = em++

# C++ Linker: Emscripten C++ Linker
CPP_LD = em++

# Archiver: Emscripten C Archiver
AR = emar

# MEX Tool: MEX Tool
MEX_PATH = $(MATLAB_ARCH_BIN)
MEX = "$(MEX_PATH)/mex"

# Download: Download
DOWNLOAD =

# Execute: Execute
EXECUTE = $(PRODUCT)

# Builder: GMAKE Utility
MAKE_PATH = %MATLAB%\bin\win64
MAKE = "$(MAKE_PATH)/gmake"


#-------------------------
# Directives/Utilities
#-------------------------

CDEBUG              = -g
C_OUTPUT_FLAG       = -o 
LDDEBUG             = -g
OUTPUT_FLAG         = -o 
CPPDEBUG            = -g
CPP_OUTPUT_FLAG     = -o 
CPPLDDEBUG          = -g
OUTPUT_FLAG         = -o 
ARDEBUG             =
STATICLIB_OUTPUT_FLAG = -r 
MEX_DEBUG           = -g
RM                  = @del /F
ECHO                = @echo
MV                  = @move
RUN                 =

#--------------------------------------
# "Faster Runs" Build Configuration
#--------------------------------------

ARFLAGS              =
CFLAGS               = -c -Wall \
                       -O3
CPPFLAGS             = -c -Wall -std=c++17 \
                       -O3
CPP_LDFLAGS          = -s DEMANGLE_SUPPORT=1
CPP_SHAREDLIB_LDFLAGS  =
DOWNLOAD_FLAGS       =
EXECUTE_FLAGS        =
LDFLAGS              = -s DEMANGLE_SUPPORT=1
MEX_CPPFLAGS         =
MEX_CPPLDFLAGS       =
MEX_CFLAGS           =
MEX_LDFLAGS          =
MAKE_FLAGS           = -j32 -f $(MAKEFILE)
SHAREDLIB_LDFLAGS    =



###########################################################################
## OUTPUT INFO
###########################################################################

PRODUCT = ./foo.js
PRODUCT_TYPE = "dynamic-library"
BUILD_TYPE = "Dynamic Library"

###########################################################################
## INCLUDE PATHS
###########################################################################

INCLUDES_BUILDINFO = -I$(START_DIR)/codegen/dll/foo -I$(START_DIR) -I$(MATLAB_ROOT)/extern/include

INCLUDES = $(INCLUDES_BUILDINFO)

###########################################################################
## DEFINES
###########################################################################

DEFINES_ = -DBUILDING_FOO
DEFINES_CUSTOM = 
DEFINES_STANDARD = -DMODEL=foo

DEFINES = $(DEFINES_) $(DEFINES_CUSTOM) $(DEFINES_STANDARD)

###########################################################################
## SOURCE FILES
###########################################################################

SRCS = $(START_DIR)/codegen/dll/foo/foo_data.cpp $(START_DIR)/codegen/dll/foo/foo_initialize.cpp $(START_DIR)/codegen/dll/foo/foo_terminate.cpp $(START_DIR)/codegen/dll/foo/foo.cpp

ALL_SRCS = $(SRCS)

###########################################################################
## OBJECTS
###########################################################################

OBJS = foo_data.o foo_initialize.o foo_terminate.o foo.o

ALL_OBJS = $(OBJS)

###########################################################################
## PREBUILT OBJECT FILES
###########################################################################

PREBUILT_OBJS = 

###########################################################################
## LIBRARIES
###########################################################################

LIBS = 

###########################################################################
## SYSTEM LIBRARIES
###########################################################################

SYSTEM_LIBS = 

###########################################################################
## ADDITIONAL TOOLCHAIN FLAGS
###########################################################################

#---------------
# C Compiler
#---------------

CFLAGS_BASIC = $(DEFINES) $(INCLUDES)

CFLAGS += $(CFLAGS_BASIC)

#-----------------
# C++ Compiler
#-----------------

CPPFLAGS_BASIC = $(DEFINES) $(INCLUDES)

CPPFLAGS += $(CPPFLAGS_BASIC)

#---------------
# C++ Linker
#---------------

CPP_LDFLAGS_ = -s ALLOW_MEMORY_GROWTH=1 -s EXPORTED_FUNCTIONS='["_foo_initialize","_foo","_foo_terminate","_malloc","_free"]' -s EXPORTED_RUNTIME_METHODS='["ccall","cwrap"]'

CPP_LDFLAGS += $(CPP_LDFLAGS_)

#------------------------------
# C++ Shared Library Linker
#------------------------------

CPP_SHAREDLIB_LDFLAGS_ = -s ALLOW_MEMORY_GROWTH=1 -s EXPORTED_FUNCTIONS='["_foo_initialize","_foo","_foo_terminate","_malloc","_free"]' -s EXPORTED_RUNTIME_METHODS='["ccall","cwrap"]'

CPP_SHAREDLIB_LDFLAGS += $(CPP_SHAREDLIB_LDFLAGS_)

#-----------
# Linker
#-----------

LDFLAGS_ = -s ALLOW_MEMORY_GROWTH=1 -s EXPORTED_FUNCTIONS='["_foo_initialize","_foo","_foo_terminate","_malloc","_free"]' -s EXPORTED_RUNTIME_METHODS='["ccall","cwrap"]'

LDFLAGS += $(LDFLAGS_)

#--------------------------
# Shared Library Linker
#--------------------------

SHAREDLIB_LDFLAGS_ = -s ALLOW_MEMORY_GROWTH=1 -s EXPORTED_FUNCTIONS='["_foo_initialize","_foo","_foo_terminate","_malloc","_free"]' -s EXPORTED_RUNTIME_METHODS='["ccall","cwrap"]'

SHAREDLIB_LDFLAGS += $(SHAREDLIB_LDFLAGS_)

###########################################################################
## INLINED COMMANDS
###########################################################################

###########################################################################
## PHONY TARGETS
###########################################################################

.PHONY : all build clean info prebuild download execute


all : build
	@echo "### Successfully generated all binary outputs."


build : prebuild $(PRODUCT)


prebuild : 


download : $(PRODUCT)


execute : download


###########################################################################
## FINAL TARGET
###########################################################################

#----------------------------------------
# Create a dynamic library
#----------------------------------------

$(PRODUCT) : $(OBJS) $(PREBUILT_OBJS)
	@echo "### Creating dynamic library "$(PRODUCT)" ..."
	$(CPP_LD) $(CPP_SHAREDLIB_LDFLAGS) -o $(PRODUCT) $(OBJS) $(SYSTEM_LIBS) $(TOOLCHAIN_LIBS)
	@echo "### Created: $(PRODUCT)"


###########################################################################
## INTERMEDIATE TARGETS
###########################################################################

#---------------------
# SOURCE-TO-OBJECT
#---------------------

%.o : %.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : %.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/codegen/dll/foo/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/codegen/dll/foo/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


foo_data.o : $(START_DIR)/codegen/dll/foo/foo_data.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


foo_initialize.o : $(START_DIR)/codegen/dll/foo/foo_initialize.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


foo_terminate.o : $(START_DIR)/codegen/dll/foo/foo_terminate.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


foo.o : $(START_DIR)/codegen/dll/foo/foo.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


###########################################################################
## DEPENDENCIES
###########################################################################

$(ALL_OBJS) : rtw_proj.tmw $(MAKEFILE)


###########################################################################
## MISCELLANEOUS TARGETS
###########################################################################

info : 
	@echo "### PRODUCT = $(PRODUCT)"
	@echo "### PRODUCT_TYPE = $(PRODUCT_TYPE)"
	@echo "### BUILD_TYPE = $(BUILD_TYPE)"
	@echo "### INCLUDES = $(INCLUDES)"
	@echo "### DEFINES = $(DEFINES)"
	@echo "### ALL_SRCS = $(ALL_SRCS)"
	@echo "### ALL_OBJS = $(ALL_OBJS)"
	@echo "### LIBS = $(LIBS)"
	@echo "### MODELREF_LIBS = $(MODELREF_LIBS)"
	@echo "### SYSTEM_LIBS = $(SYSTEM_LIBS)"
	@echo "### TOOLCHAIN_LIBS = $(TOOLCHAIN_LIBS)"
	@echo "### CFLAGS = $(CFLAGS)"
	@echo "### LDFLAGS = $(LDFLAGS)"
	@echo "### SHAREDLIB_LDFLAGS = $(SHAREDLIB_LDFLAGS)"
	@echo "### CPPFLAGS = $(CPPFLAGS)"
	@echo "### CPP_LDFLAGS = $(CPP_LDFLAGS)"
	@echo "### CPP_SHAREDLIB_LDFLAGS = $(CPP_SHAREDLIB_LDFLAGS)"
	@echo "### ARFLAGS = $(ARFLAGS)"
	@echo "### MEX_CFLAGS = $(MEX_CFLAGS)"
	@echo "### MEX_CPPFLAGS = $(MEX_CPPFLAGS)"
	@echo "### MEX_LDFLAGS = $(MEX_LDFLAGS)"
	@echo "### MEX_CPPLDFLAGS = $(MEX_CPPLDFLAGS)"
	@echo "### DOWNLOAD_FLAGS = $(DOWNLOAD_FLAGS)"
	@echo "### EXECUTE_FLAGS = $(EXECUTE_FLAGS)"
	@echo "### MAKE_FLAGS = $(MAKE_FLAGS)"


clean : 
	$(ECHO) "### Deleting all derived files..."
	$(RM) $(subst /,\,$(PRODUCT))
	$(RM) $(subst /,\,$(ALL_OBJS))
	$(ECHO) "### Deleted all derived files."


