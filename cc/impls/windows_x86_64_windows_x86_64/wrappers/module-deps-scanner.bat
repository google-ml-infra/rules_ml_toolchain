@echo off
"%CPP_MODULE_DEPS_SCANNER_PATH:/=\%" -format=p1689 -- "%CPP_PATH:/=\%" %* > "%DEPS_SCANNER_OUTPUT_FILE:/=\%"
