; #########################################################################
; 
; Program: RcloneWrapper
; Purpose: Adds a GUI readout to the command line based Rclone.org client, 
; Lists and executes simple commands such as -AddGame, 
; handles parsing of -RunGame FileToExecute.exe from GOG galaxy as a 
; command line switch, 
; handles the adding, editing and updating of Cloud Storage Providers 
; i.e OneDriveGames:\Games, 
; interfaces and updates GameLibrary.db3 (SQLlite file).
; Author: Mark Albanese 
; Date: 30 May 2020
; Version: 1.0
; Release: 1
; Language: x86 Assembly / Microsoft Macro Assembler 
; Compiler: MASM32 SDK
; 
; #########################################################################

     .386
     .model flat, stdcall
     option casemap :none   ; case sensitive

; ##########################################################################
     include \masm32\include\windows.inc
     include \masm32\include\user32.inc
     include \masm32\include\kernel32.inc
     include \masm32\include\gdi32.inc
     
     includelib \masm32\lib\gdi32.lib
     includelib \masm32\lib\user32.lib
     includelib \masm32\lib\kernel32.lib

; #########################################################################
          
        ;=================
        ; Local prototypes
        ;=================
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        
        .const
        IDR_MAINMENU       equ 101
        IDM_ADDGAME        equ 40001
        
        .data
        ClassName          db "RcloneWrapperWinClass",0
        AppName            db "Rclone.org Wrapper",0
        EditClass          db "EDIT",0
        RclonePipeError    db "Error trying to retrieve output from Rclone.exe",0
        CreateProcessError db "Error during process creation",0
        CommandLine        db "rclone.exe version",0
        
        hInstance         dd 0
        hwndEdit          dd 0

        .data?

        .code
start:
; #########################################################################
        
    ;print "I am just a simple wrapper, waiting for my developer to finish me...",13,10