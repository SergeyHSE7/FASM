format PE console
entry start

include 'win32a.inc'


section '.data' data readable writable
        input db 'Input amount: ', 0
        endloop db 10, 'The end of the loop!', 10, 0

        N dd ?
        formatNum db '%d, ', 0
        NULL = 0


section '.code' code readable executable
start:
        push input
        call [printf]

        push N
        push formatNum
        call [scanf]


metka:
    dec  [N]

    push [N]
    push formatNum
    call[printf]

    cmp [N], 0
    jne metka

        push endloop
        call [printf]

        call [getch]
        push NULL
        call [ExitProcess]



section '.import' import data readable
        library kernel32, 'kernel32.dll', \
                msvcrt,   'msvcrt.dll'
        import kernel32,\
               ExitProcess, 'ExitProcess'
        import msvcrt,\
                printf, 'printf',\
                getch, '_getch',\
                scanf, 'scanf'