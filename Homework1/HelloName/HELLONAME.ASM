format PE console
entry start

include 'win32a.inc'


section '.data' data readable writable
        inputname db 'What is your name?', 10, 0
        hello db 'Hello, Mr. %s!', 10, 0

        name dd ?
        formatStr db '%s', 0
        NULL = 0


section '.code' code readable executable
start:
        push inputname
        call [printf]

        push name
        push formatStr
        call [scanf]

        push name
        push hello
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