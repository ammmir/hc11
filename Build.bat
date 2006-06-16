cls
@echo off
REM Cross-assemble and compile source code.
REM (see Compiler Command Line Options, pg 4.3 cx6811_v47.pdf)
cx6811 -vl rts.s test.c ivectors.c
echo.
echo.

REM Cross-link using definitions found in the command file.
REM (see Linker Options, pg 6-5 cx6811_v47.pdf)
clnk -mtest.map -otest.h11 test.lkf
echo.
echo.

REM convert *.h11 to *.S19 format and use this file to burn the FLASH PROM via the prom-burner.
REM (see pg 8-4 cx6811_v47.pdf)
chex -o test.s19  test.h11

REM 
REM (see pg 8-7 cx6811_v47.pdf)
clabs test.h11