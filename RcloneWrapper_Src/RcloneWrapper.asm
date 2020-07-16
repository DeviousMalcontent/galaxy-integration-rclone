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

; #########################################################################      
     include \masm32\include\masm32rt.inc

; #########################################################################
          
        ;=================
        ; local prototypes
        ;=================
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
        CatProc PROTO strBase:DWORD, strAdd:DWORD
        StrCmpProc PROTO strOne:DWORD, strTwo:DWORD
        
        .const
        IDR_MAINMENU       equ 101
        IDM_ADDGAME        equ 40001
        
        .data
        ClassName          db "RcloneWrapperWinClass",0
        AppName            db "Rclone.org Wrapper",0
        EditClass          db "EDIT",0
        CreatePipeError    db "Error during pipe creation",0
        CreateProcessError db "Error during process creation",0
        CommandLine        db "rclone.exe version",0
        
        ;For debug purposes comparing strings... 
        msgStrEqual        db 'The strings are equal.',0
        msgStrNotEqual     db 'The strings are not equal.',0
        
        .data?
        hInstance          HINSTANCE ?
        inCommandLine      LPSTR ?
        hwndEdit        dd ?
        CMDbuffer       db MAX_PATH dup(?)
        AppPathbuffer   db MAX_PATH dup(?)

        .code
start:
; #########################################################################
    ;print "I am just a simple wrapper, waiting for my developer to finish me...",13,10

    mov esi, OffSet AppPathbuffer
    invoke GetModuleFileName, rv(GetModuleHandle, 0), esi, SizeOf AppPathbuffer

    ;Check command line and see if any arguments were sent to the program...
    call main 

    invoke GetModuleHandle, NULL
    mov    hInstance,eax
    invoke GetCommandLine
    mov    inCommandLine,eax
    
    ; -------------------------------------------
    ; Call the applications main window 
    ; -------------------------------------------
    invoke WinMain, hInstance,NULL,inCommandLine, SW_SHOWDEFAULT
        
    invoke ExitProcess,eax
    
; #########################################################################

main proc uses esi edi ebx

    local argc:DWORD       

    invoke  GetCommandLineW
    lea     ecx,argc
    invoke  CommandLineToArgvW,eax,ecx
    
    mov     esi,eax
    mov     ebx,argc
    xor     edi,edi
@@:
    inc     edi

    ; Convert UNICODE string to ANSI
    invoke  WideCharToMultiByte,CP_ACP,0,DWORD PTR [esi],-1, ADDR CMDbuffer,256,0,0

    ; For debug purposes tell me what was sent to the command line...
    invoke MessageBox, NULL, ADDR CMDbuffer, ADDR CMDbuffer, MB_OK 
    
    add     esi,4
    dec     ebx
    jnz     @b
    
    ; Test to see if strings were actually parsed to the command line or the first argument is just the programs start path, in which case we can ignore it... 
    invoke  lstrcmpi, ADDR AppPathbuffer, ADDR CMDbuffer
    .if eax == 0
        invoke MessageBox, NULL, ADDR msgStrEqual, ADDR msgStrEqual, MB_OK 
    .else
        ; Do nothing...
        ;invoke MessageBox, NULL, ADDR msgStrNotEqual, ADDR msgStrNotEqual, MB_OK 
    .endif

    ret
main endp

; -------------------------------------------
; Applications Main Window 
; -------------------------------------------
WinMain proc hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
    local wc:WNDCLASSEX
    local msg:MSG
    local hwnd:HWND
    mov   wc.cbSize,SizeOf WNDCLASSEX
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OffSet WndProc
    mov   wc.cbClsExtra,NULL
    mov   wc.cbWndExtra,NULL
    push  hInst
    pop   wc.hInstance
    mov   wc.hbrBackground,COLOR_APPWORKSPACE
    mov   wc.lpszMenuName,IDR_MAINMENU
    mov   wc.lpszClassName,OffSet ClassName
    invoke LoadIcon,NULL,IDI_APPLICATION
    mov   wc.hIcon,eax
    mov   wc.hIconSm,eax
    invoke LoadCursor,NULL,IDC_ARROW
    mov   wc.hCursor,eax
    invoke RegisterClassEx, ADDR wc
    invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR ClassName, ADDR AppName,\
           WS_OVERLAPPEDWINDOW+WS_VISIBLE,CW_USEDEFAULT,\
           CW_USEDEFAULT,920,512,NULL,NULL,\
           hInst,NULL
    mov hwnd,eax
    .while TRUE
        invoke GetMessage, ADDR msg,NULL,0,0
        .BREAK .IF (!eax)
        invoke TranslateMessage, ADDR msg
        invoke DispatchMessage, ADDR msg
    .endw
    mov eax,msg.wParam
    ret
WinMain endp

; -------------------------------------------
; Main window loop
; ------------------------------------------- 
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    local rect:RECT
    local hRead:DWORD
    local hWrite:DWORD
    local startupinfo:STARTUPINFO
    local pinfo:PROCESS_INFORMATION
    local buffer[1024]:byte
    local bytesRead:DWORD
    local hdc:DWORD
    local sat:SECURITY_ATTRIBUTES
    .if uMsg==WM_CREATE
        invoke CreateWindowEx,NULL, ADDR EditClass,NULL,WS_CHILD+WS_VISIBLE+ES_MULTILINE+ES_AUTOHSCROLL+ES_AUTOVSCROLL,0,0,0,0,hWnd,NULL,hInstance,NULL
        mov hwndEdit,eax
    .elseif uMsg==WM_CTLCOLOREDIT
        invoke SetTextColor,wParam,Green
        invoke SetBkColor,wParam,Black
        invoke GetStockObject,BLACK_BRUSH
        ret
    .elseif uMsg==WM_SIZE
        mov edx,lParam
        mov ecx,edx
        shr ecx,16
        and edx,0ffffh
        invoke MoveWindow,hwndEdit,0,0,edx,ecx,TRUE
    .elseif uMsg==WM_COMMAND
        .if lParam==0
            mov eax,wParam
            .if ax==IDM_ADDGAME
                mov sat.nLength,SizeOf SECURITY_ATTRIBUTES
                mov sat.lpSecurityDescriptor,NULL
                mov sat.bInheritHandle,TRUE
                invoke CreatePipe, ADDR hRead, ADDR hWrite, ADDR sat,NULL
                .if eax==NULL
                    invoke MessageBox,hWnd, ADDR CreatePipeError, ADDR AppName,MB_ICONERROR+MB_OK
                .else
                    mov startupinfo.cb,SizeOf STARTUPINFO
                    invoke GetStartupInfo, ADDR startupinfo
                    mov eax,hWrite
                    mov startupinfo.hStdOutput,eax
                    mov startupinfo.hStdError,eax
                    mov startupinfo.dwFlags,STARTF_USESHOWWINDOW+STARTF_USESTDHANDLES
                    mov startupinfo.wShowWindow,SW_HIDE
                    ;-------------------------------------------------
                    ; Create process
                    ;-------------------------------------------------
                    invoke CreateProcess,NULL, ADDR CommandLine,NULL,NULL,TRUE,NULL,NULL,NULL, ADDR startupinfo, ADDR pinfo
                    .if eax==NULL
                        invoke MessageBox,hWnd, ADDR CreateProcessError, ADDR AppName,MB_ICONERROR+MB_OK
                    .else
                        invoke CloseHandle,hWrite
                        .while TRUE
                            invoke RtlZeroMemory, ADDR buffer,1024
                            invoke ReadFile,hRead, ADDR buffer,1023, ADDR bytesRead,NULL
                            .if eax==NULL
                                .break
                            .else
                                invoke SendMessage,hwndEdit,EM_SETSEL,-1,0
                                invoke SendMessage,hwndEdit,EM_REPLACESEL,FALSE, ADDR buffer
                            .endif
                        .endw
                    .endif
                    invoke CloseHandle,hRead
                    invoke CloseHandle,pinfo.hProcess
                    invoke CloseHandle,pinfo.hThread
                .endif
            .endif
        .endif
    .elseif uMsg==WM_DESTROY
        invoke PostQuitMessage,NULL
    .else
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam        
        ret
    .endif
    xor eax,eax
    ret
WndProc endp

; -------------------------------------------
; Procedure for string concatenation.
; -------------------------------------------
CatProc proc strBase:DWORD, strAdd:DWORD
    mov edi, strBase
    mov al, 0
    repne scasb
    dec edi
    mov esi, strAdd
    @@:
        mov al, [esi]
        mov [edi], al
        inc esi
        inc edi
        test al, al
        jnz @B
        ret
CatProc endp

;; -------------------------------------------
;; Procedure for string compare.
;; -------------------------------------------
;StrCmpProc proc strOne:DWORD, strTwo:DWORD
;    invoke  lstrcmp, ADDR strOne, ADDR strTwo
;    cmp     eax,0
;    jne     @f
;    invoke MessageBox, NULL, ADDR msg1, ADDR msg1, MB_OK 
;    jmp     strnotequal
;@@:    
;    invoke MessageBox, NULL, ADDR msg2, ADDR msg2, MB_OK 
;strnotequal:
;    jnz @B
;    ret
;StrCmpProc endp

end start