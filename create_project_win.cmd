@REM # --------------------------------------------------------------------
@REM # --   *****************************
@REM # --   *   Trenz Electronic GmbH   *
@REM # --   *   Beendorfer Straße 23    *
@REM # --   *   32609 Hüllhorst         *
@REM # --   *   Germany                 *
@REM # --   *****************************
@REM # --------------------------------------------------------------------
@REM # --$Autor: Dück, Thomas $
@REM # --$Email: t.dueck@trenz-electronic.de $
@REM # --$Create Date: 2020/01/28 $
@REM # --$Modify Date: 2023/01/31 $
@REM # --$Version: 1.4 $
@REM #		-- update to Quartus version 22.x
@REM #		-- added 'Standard Edition' to selection
@REM # --$Version: 1.3 $
@REM #		-- run scripts with qprogrammer with restrictions
@REM # --$Version: 1.2 $
@REM #		-- update to Quartus version 21.x
@REM # --$Version: 1.1 $
@REM #		-- check Quartus installation path and version
@REM #		-- modify desgin_basic_settings.tcl
@REM # --$Version: 1.0 $
@REM # 		-- initial release
@REM # --------------------------------------------------------------------
@REM # --------------------------------------------------------------------

@REM set local environment
setlocal
@echo ----------------------- Set design paths ---------------------------
@REM get paths
@set batchfile_name=%~n0
@set batchfile_drive=%~d0
@set batchfile_path=%~dp0
@REM change drive
@%batchfile_drive%
@REM change path to batchfile folder
@cd %batchfile_path%
@echo -- Run Design with: %batchfile_name%
@echo -- Use Design Path: %batchfile_path%
@echo --------------------------------------------------------------------
@set cmd_folder=%batchfile_path%console\base_cmd\

@echo --------------------- Load basic design settings --------------------
@for /f "eol=# delims=" %%a in (./settings/design_basic_settings.tcl) do @set %%a
@set new_path=%QUARTUS_PATH_WIN%
@set new_version=%QUARTUS_VERSION%
@set new_edition=%QUARTUS_EDITION%
@set new_linux_path=%QUARTUS_PATH_LINUX%
@echo --------------------------------------------------------------------

@echo ----------------------- Create log folder --------------------------
@REM log folder
@set log_folder=%batchfile_path%log
@echo %log_folder%
@if not exist %log_folder% ( mkdir %log_folder% )
@echo --------------------------------------------------------------------

@echo ------------------- Check quartus environment ----------------------
@REM # check Intel environment
:CHECK_QUARTUS_ENV
@if exist %QUARTUS_PATH_WIN% (
  if not exist %QUARTUS_PATH_WIN%/%QUARTUS_VERSION% (
	@echo Quartus Version '%QUARTUS_VERSION% %QUARTUS_EDITION%' not found in quartus installation path '%QUARTUS_PATH_WIN%'.
    @GOTO ASK_BASIC_SETTINGS_PATH
  )
  @echo -- Use Quartus installation from '%QUARTUS_PATH_WIN%' --
  @echo -- Use Quartus Version: %QUARTUS_VERSION% %QUARTUS_EDITION% --
  @GOTO RUN
)
@if not exist %QUARTUS_PATH_WIN% (
  @echo '%QUARTUS_PATH_WIN%' does not exist.
  @GOTO SPECIFY_BASIC_SETTINGS_PATH
)

:SPECIFY_BASIC_SETTINGS_PATH
@set /p new_path="Please specifiy your Quartus installation folder path (e.g. C:/intelFPGA_pro):"
@set new_path=%new_path: =%
@set new_path=%new_path:"=%
@if not exist "%new_path%" (
	@echo '%new_path%' not found.
	@GOTO SPECIFY_BASIC_SETTINGS_PATH 
)
@if "%QUARTUS_PATH_WIN%" equ "not_defined" ( @GOTO SPECIFY_BASIC_SETTINGS_LINUX_PATH ) else ( @GOTO CHECK_QUARTUS_PATH )

:SPECIFY_BASIC_SETTINGS_LINUX_PATH
@set /p new_linux_path="Please specifiy your Quartus installation folder path for linux (e.g. ~/intelFPGA_pro):"
@set new_linux_path=%new_linux_path: =%
@set new_linux_path=%new_linux_path:"=%
@GOTO SPECIFY_BASIC_SETTINGS_VERSION 

:CHECK_QUARTUS_PATH
@if not exist "%new_path%/%new_version%" ( @GOTO ASK_BASIC_SETTINGS_PATH ) else ( @GOTO WRITE_BASIC_SETTINGS )

:SPECIFY_BASIC_SETTINGS_VERSION
@set /p new_version="Please specifiy your Quartus Version (22.1std/22.4):"
@set new_version=%new_version: =%
@set new_version=%new_version:"=%
@if not exist "%new_path%/%new_version%" ( @GOTO ASK_BASIC_SETTINGS_PATH )
@GOTO SPECIFY_BASIC_SETTINGS_EDITION

:SPECIFY_BASIC_SETTINGS_EDITION
@set /p new_edition="Please specifiy your Quartus Edition (Lite/Standard/Pro):"
@set new_edition=%new_edition: =%
@set new_edition=%new_edition:"=%
@if /i "%new_edition%" neq "lite" (
  @if /i "%new_edition%" neq "standard" (
    @if /i "%new_edition%" neq "pro" ( 
      @echo '%new_edition%' Edition not supported. Choose between 'Lite', 'Standard' and 'Pro'.
      @GOTO SPECIFY_BASIC_SETTINGS_EDITION 
    )
  )
)
@GOTO WRITE_BASIC_SETTINGS

:ASK_BASIC_SETTINGS_PATH
@echo Quartus version '%new_version%' not found in Quartus installation path '%new_path%'.
@set  /p answer= "Wrong specified quartus installation path? (y/n)"
@if /i "%answer%" equ "y" ( @GOTO SPECIFY_BASIC_SETTINGS_PATH ) else (
	if "%QUARTUS_VERSION%" equ "not_defined" ( 
		@GOTO SPECIFY_BASIC_SETTINGS_VERSION 
	) else (	
		@echo Install Quartus Prime %new_version% %new_edition% in Quartus installation path %new_path%.
		@echo For manual configuration of design basic settings go to https://wiki.trenz-electronic.de/display/PD/Project+Delivery+-+Intel+devices#ProjectDelivery-Inteldevices-Reference-Design:GettingStarted .
		@GOTO ERROR
	)
)
@GOTO CHECK_QUARTUS_ENV 

:WRITE_BASIC_SETTINGS
@echo off
>"./settings/temp.tcl" (
	@for /f "delims=" %%A in (./settings/design_basic_settings.tcl) do (
		@if "%%A" equ "QUARTUS_PATH_WIN=%QUARTUS_PATH_WIN%" (echo QUARTUS_PATH_WIN=%new_path%) else (
			@if "%%A" equ "QUARTUS_PATH_LINUX=%QUARTUS_PATH_LINUX%" (echo QUARTUS_PATH_LINUX=%new_linux_path%) else (
				@if "%%A" equ "QUARTUS_VERSION=%QUARTUS_VERSION%" (echo QUARTUS_VERSION=%new_version%) else (
					@if "%%A" equ "QUARTUS_EDITION=%QUARTUS_EDITION%" (echo QUARTUS_EDITION=%new_edition%) else (
						echo %%A
					)
				)
			)
		)
	)
)
@del /f .\settings\design_basic_settings.tcl
@rename .\settings\temp.tcl design_basic_settings.tcl
@echo on
@set QUARTUS_PATH_WIN=%new_path%
@set QUARTUS_PATH_LINUX=%new_linux_path%
@set QUARTUS_VERSION=%new_version%
@set QUARTUS_EDITION=%new_edition%

@GOTO CHECK_QUARTUS_ENV

:RUN  
@echo --------------------------------------------------------------------
@echo ------------------------ Start Quartus scripts ---------------------

@if %QUARTUS_PROG% equ 1 ( @GOTO RUN_QUARTUS_PROG )

@call %QUARTUS_PATH_WIN%/%QUARTUS_VERSION%/quartus/bin64/quartus_sh.exe -t scripts/script_main.tcl --run_tk_gui
@GOTO FINISH

@REM : minimal console setup -> start
:RUN_QUARTUS_PROG
@set new_base=0
@echo --------------------------------------------------------------------
@echo ------------------------_create_win_setup.cmd-----------------------
@echo -------------------------TE Reference Design------------------------
@echo --------------------------------------------------------------------
@echo -- (0)  Module selection guide, project creation...prebuilt export...
@echo -- (4)  (internal only) Prod
@echo -- (x)  Exit Batch (nothing is done!)
@echo ----
@set /p new_base=" Select (ex.:'0' for module selection guide):"

@if "%new_base%"=="x" (@GOTO EOF)

@if "%new_base%"=="0" (
@set new_cmd=config
@GOTO CONFIG_SETUP
)

@if "%new_base%"=="4" (
@set new_cmd=production
@GOTO PRODUCTION_SETUP
)

:CONFIG_SETUP
@call %QUARTUS_PATH_WIN%/%QUARTUS_VERSION%/qprogrammer/quartus/bin64/quartus_sh.exe -t scripts/script_main.tcl --run_board_selection

:PRODUCTION_SETUP
@if "%new_cmd%"=="production" ( 
  @if exist %cmd_folder%prod_start_test.cmd ( @copy %cmd_folder%prod_start_test.cmd %batchfile_path%prod_start_test.cmd)
  @GOTO FINISH
)
@REM : minimal console setup -> end

:FINISH

@if %ERRORLEVEL% equ 1 ( @GOTO ERROR )

@echo ------------------------ Scripts finished --------------------------
@echo --------------------------------------------------------------------
@echo ------------------- Change to design folder ------------------------
@cd..
@echo ----------------------- Design finished ----------------------------

GOTO EOF

:ERROR
@echo -------------------------- Error occurs ----------------------------
@echo Errorlevel: %ERRORLEVEL%
@echo --------------------------------------------------------------------
PAUSE

:EOF
