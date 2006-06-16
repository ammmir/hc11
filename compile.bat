@echo off

set BIOS_VERSION=1.0-rc1
c:\cygwin\bin\date -u "+#define BUILDDATE \"%%Y-%%m-%%d %%H:%%M:%%S UTC\""' > buildversion.s
echo #define VERSION "%BIOS_VERSION%" >> buildversion.s

echo Running preprocessor...
cpp -Iinclude boot.asm > boot.s
echo Assembling boot.asm...
as --warn -o boot.o boot.s

rem gcc -IF:\hc11\lib\gcc-lib\m6811-elf\3.3.6-m68hc1x-20060122\include -IF:\hc11\m6811-elf\include -IF:\hc11\gel\include -fomit-frame-pointer -g -Os -mshort -Wl,-m,m68hc11elfb -c main.c
rem gcc -g -Os -mshort -c main.c

echo Compiling...
gcc -IF:\hc11\lib\gcc-lib\m6811-elf\3.3.6-m68hc1x-20060122\include -IF:\hc11\m6811-elf\include -IF:\hc11\gel\include -fomit-frame-pointer -g -Os -mshort -c main.c

echo Linking...
rem gcc -Wl,--unresolved-symbols=ignore-all -LF:\hc11\lib\gcc-lib\m6811-elf\3.3.6-m68hc1x-20060122\mshort\ -LF:\hc11\m6811-elf\lib\mshort\ -nostartfiles -fomit-frame-pointer -mshort -Wl,-m,m68hc11elfb -o firmware.elf boot.o main.o -lc
gcc -LF:\hc11\lib\gcc-lib\m6811-elf\3.3.6-m68hc1x-20060122\mshort\ -LF:\hc11\m6811-elf\lib\mshort\ -nostartfiles -fomit-frame-pointer -mshort -Wl,-m,m68hc11elfb -o firmware.elf boot.o main.o

rem ld -mshort -m m68hc11elfb -LF:\hc11\m6811-elf\lib\mshort -lc -o firmware.elf memory.x boot.o main.o

rem ld -mshort -m m68hc11elfb -LF:\hc11\m6811-elf\lib\mshort -lc -o firmware.elf memory.x boot.o main.o

echo Creating S19...
objcopy --change-section-address .data=0x4000 --output-target=srec firmware.elf firmware.s19



rem old shit
rem c:\cygwin\bin\date -u "+BuildDate:  .asciz  \"%%Y-%%m-%%d %%H:%%M:%%S UTC\""' > buildversion.s
rem echo BuildVersion:  .asciz "%BIOS_VERSION%" >> buildversion.s
