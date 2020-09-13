format PE console
entry start

include 'win32a.inc'


section '.data' data readable writable
        firstnum db 'Input first number: ', 0
        secondnum db 'Input second number: ', 0
        result db 'Result of sum: %d!', 10, 0

        A dd ?
        B dd ?
        R dd ?
        formatNum db '%d', 0
        NULL = 0


section '.code' code readable executable
start:
        push firstnum
        call [printf]

        push A
        push formatNum
        call [scanf]

        push secondnum
        call [printf]

        push B
        push formatNum
        call [scanf]

        mov ecx, [A]
        add ecx, [B]
        mov [R], ecx


        push [R]
        push result
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