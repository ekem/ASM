@setlocal enableextensions enabledelayedexpansion
@echo off
set filein=%1
if [%1]==[] set filein=main.asm

set build_dir=.\bin
set src_dir=.\src


set fileout=%2

if [%2]==[] (
	set filename=%filein%
	
	if "x!filename:~-4!"=="x.asm" (
		set filename=!filename:~0,-4!
	)
	set filename=!filename!
	set fileout=!filename!.exe
	
	ml  /nologo /Zi /Fo"debug\!filename!.obj" /W3 /errorReport:prompt ^
	/Ta %src_dir%\%filein% /link /out:%build_dir%\!fileout! ^
	/pdb:"debug\!filename!.pdb" /INCREMENTAL /subsystem:console ^
	/DYNAMICBASE "user32.lib" "kernel32.lib" ^
	"msvcrt.lib" ^
	/LIBPATH:"lib"
	goto :eof
)
ml /nologo %src_dir%\%filein% /link /out:%build_dir%\%fileout% /subsystem:console /defaultlib:kernel32.lib

:eof
