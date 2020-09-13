format PE console
entry start

include 'win32a.inc'

section '.text' code executable
start:
        push hello
        call [printf]
        pop ecx

        call [getchar]
        push 0
        call [ExitProcess]

section '.rdata' data readable
        hello db 'This is my first console app!', 10, 0

section '.idata' data readable import
        library kernel32, 'kernel32.dll', \
                msvcrt,   'msvcrt.dll'
        import kernel32, ExitProcess, 'ExitProcess'
        import msvcrt, printf, 'printf', getchar, 'getchar'