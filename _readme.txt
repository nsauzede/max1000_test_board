Project Description
==========================================================================
Important notes:
 1.Please do not use space character on path name.
 2.(Win OS)Please use short path name on Windows OS. This OS allows only 256 characters in normal path. 
 3.(Linux OS) Use bash as shell (change for example with: sudo dpkg-reconfigure dash)
 4.(Linux OS) Add access rights to bash files (change for example with: chmod 777 <filename>)
==========================================================================
1. Create project and open documentation links:
  On Windows OS: run "create_project_win.cmd" and follow instructions 
  On Linux OS: run "_create_project_linux.sh"  and follow instructions 
==============================
2. Create Quartus Project and modify design basic settings manually:
  1.Modify basic settings:
  =====
  Edit "./settings/design_basic_settings.tcl" with text editor:
    Set your Quartus installation path for 
      Quartus Prime 22.4 Pro:                               |  Quartus Prime 22.1 Lite: 
        QUARTUS_PATH_WIN=C:/intelFPGA_pro (Win OS)          |    QUARTUS_PATH_WIN=C:/intelFPGA_lite (Win OS)
        QUARTUS_PATH_LINUX=~/intelFPGA_pro (Linux OS)       |    QUARTUS_PATH_LINUX=~/intelFPGA_lite (Linux OS)
        QUARTUS_VERSION=22.4                                |    QUARTUS_VERSION=22.1std
        QUARTUS_EDITION=Pro                                 |    QUARTUS_EDITION=Lite

      In this example the Intel software will be searched in 
        C:/intelFPGA_pro/22.4/ for quartus (Win OS)
        C:/intelFPGA_pro/22.4/nios2eds/ for software (Win OS)
  =====
  2.Run "create_project_win.cmd" on Win OS or "create_project_linux.sh" on Linux OS
==============================
Basic documentations:
  =====
  Project Delivery - Intel devices:
  	-> https://wiki.trenz-electronic.de/display/PD/Project+Delivery+-+Intel+devices/
  ==
  Trenz Electronic product description:
  	-> https://wiki.trenz-electronic.de/display/PD/Products/
  ==
  Additional Information are available on the reference desgin description page:
  	-> https://wiki.trenz-electronic.de/display/PD/<Series Name>+Reference+Designs
==============================
