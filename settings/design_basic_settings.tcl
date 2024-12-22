# --------------------------------------------------------------------
# --   *****************************
# --   *   Trenz Electronic GmbH   *
# --   *   Beendorfer Straße 23    *
# --   *   32609 Hüllhorst         *
# --   *   Germany                 *
# --   *****************************
# --------------------------------------------------------------------
# --$Author: Dück, Thomas $
# --$Email: t.dueck@trenz-electronic.de $
# --$Create Date: 2019/10/25 $
# --$Modify Date: 2020/03/20 $
# --$Version: 2.0 $
# 		-- 19.x update
#		-- remove variables PARTNUMBER, DO_NOT_CLOSE_SHELL
# --$Version: 1.0 $
# 		-- initial release
# --------------------------------------------------------------------
# Additional description on: https://wiki.trenz-electronic.de/display/PD/Project+Delivery+-+Intel+devices
# --------------------------------------------------------------------
# Important basic settings:
# -------------------------
# --------------------
# Set Quartus Installation path:
#    -The scripts search for Quartus software on this paths (e.g. for Win OS):
#    -Quartus (recommend used for project creation and programming): %QUARTUS_PATH_WIN%\%QUARTUS_VERSION%\
# -Important Note: Check if Quartus default install path use upper or lower case. Don't use spaces in installation path.
QUARTUS_PATH_WIN=C:/intelFPGA_lite
QUARTUS_PATH_LINUX=~/intelFPGA_lite
# -Attention: These scripts and source files support only the predefined Quartus Version and Edition. 
QUARTUS_VERSION=22.1std
QUARTUS_EDITION=Lite
# --------------------
# variables for internal usage --- Do not change values ---
QUARTUS_PROG=0
# --------------------
# --------------------------------------------------------------------

