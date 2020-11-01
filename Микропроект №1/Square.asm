format PE console
entry start

; �������: ������ ������
; ������: ���-193
; �������: 5

include 'win32a.inc'

;------------------------- Data ----------------------------------------------
section '.data' data readable writable

        strInputCoords          db 'Input the coordinates of point %d: ', 0
        strScanCoords           db '%d %d', 0
        strNotSquare            db 'NOT SQUARE!', 10, 0
        strIsSquare             db 'IT IS SQUARE!!!', 10, 0
        strErrorSameCoords      db 'Incorrect input. Points cannot have the same coordinates', 10, 0
        strErrorValueLessZero   db 'Incorrect input. All values must be greater or equal zero', 10, 0
        strErrorValueVeryBig    db 'Incorrect input. All values must be less than 32768', 10, 0

        x           dd ?
        y           dd ?
        i           dd ?
        count1      dd 0
        count2      dd 0
        length      dd 0
        value1      dd 0
        value2      dd 0
        counter1    dd 0
        counter2    dd 0
        Xpoints     rd 4 ; ������ ��������� ����� �� X
        Ypoints     rd 4 ; ������ ��������� ����� �� Y

;------------------------- Code -----------------------------------------------
section '.code' code readable executable
start:
; ���� ��������� �����
        call PointsInput
; ��������� ��� �������� ���������� ����� �������
        call PassingAllPairs
; ����������, �������� �� ����� ����� ���������
        call GetResult


; ���� ������������ ��������� ��������� ���������� ���������
finish:
        call [getch]
        push 0
        call [ExitProcess]

notSquare:
        push strNotSquare
        call [printf]
        jmp finish

isSquare:
        push strIsSquare
        call [printf]
        jmp finish

errorSameCoords:
        push strErrorSameCoords
        call [printf]
        jmp finish

errorValueLessZero:
        push strErrorValueLessZero
        call [printf]
        jmp finish

errorValueVeryBig:
        push strErrorValueVeryBig
        call [printf]
        jmp finish

;--------------------------------------------------------------------------
PointsInput:
; ����� ��������� ��������
        xor ecx, ecx
        mov eax, Xpoints
        mov ebx, Ypoints

beginInput:
; ��������� �������� ��������� �� ��������� ����������
        mov [x], eax
        mov [y], ebx
        mov [i], ecx
; ������ ������������ ������ ����������
        push ecx
        push strInputCoords
        call [printf]
        add esp, 8
; ��������������� �������� ���������
        mov eax, [x]
        mov ebx, [y]
; ��������� ����������
        push ebx
        push eax
        push strScanCoords
        call [scanf]
        add esp, 12
; ��������������� �������� ���������
        mov eax, [x]
        mov ebx, [y]
        mov ecx, [i]
; ���������, ��� ��������� ���������� �� ������ ����
        cmp [Xpoints + ecx*4], 0
        jl errorValueLessZero
        cmp [Ypoints + ecx*4], 0
        jl errorValueLessZero
; ���������, ��� ��������� ���������� ������ 2^15
        cmp [Xpoints + ecx*4], 32768
        jge errorValueVeryBig
        cmp [Ypoints + ecx*4], 32768
        jge errorValueVeryBig
; ��������� �� ��������� ��������
        add eax, 4
        add ebx, 4
        inc ecx
        cmp ecx, 4
        jne beginInput

        ret

;--------------------------------------------------------------------------
PassingAllPairs:

loop1:
        mov edx, [count1]
        mov [count2], edx
        inc [count2]
; ���������� ��������� ����, ����� �������� �� ���� ����� �����
        loop2:
        ; ��������� ���������� ����� �������
                call CalculateLength
        ; "������������" ����������
                call CheckLength

                inc [count2]
                cmp [count2], 4
                jl loop2

        inc [count1]
        cmp [count1], 3
        jl loop1

        ret

;------------------------------------------------------------------------------
CalculateLength:
        mov edx, [count1]
        imul edx, 4
; ���������� � �������� ���������� ������ �����
        mov eax, [Xpoints + edx]
        mov ebx, [Ypoints + edx]

        mov edx, [count2]
        imul edx, 4
; �������� �� ��������� ������ ����� ���������� ������
        sub eax, [Xpoints + edx]
        sub ebx, [Ypoints + edx]
; �������� � �������
        imul eax, eax
        imul ebx, ebx
; ���������� ���������� ��������
        add eax, ebx
        mov [length], eax

        ret

;------------------------------------------------------------------------------
CheckLength:
        mov eax, [length]
; ������� ������, ���� ���������� ����� ������� ����� 0
        cmp eax, 0
        je errorSameCoords

; ���� �������� �������, ������� � ���� ������� �����
        cmp [value1], 0
        jne compareWithValue1
        mov [value1], eax

; ���� ������� ����� ����� �������� value1, �� ����������� ������ �������
compareWithValue1:
        cmp [value1], eax
        jne checkValue2

        inc [counter1]
        ret

checkValue2:
; ���� �������� �������, ������� � ���� ������� �����
        cmp [value2], 0
        jne compareWithValue2
        mov [value2], eax

; ���� ������� ����� ����� �������� value2, �� ����������� ������ �������
compareWithValue2:
        cmp [value2], eax
        jne notSquare

        inc [counter2]
        ret

;------------------------------------------------------------------------------
GetResult:
; ����� �������� �������, ���� ��� 6 �������� ���������� ����� ���������
; �� �������� �� 2 ���������, � ������� ����� 4 � 2 �������� ��������������
        cmp [counter1], 4
        jne anotherCase

        cmp [counter2], 2
        jne notSquare

        jmp isSquare

anotherCase:
        cmp [counter1], 2
        jne notSquare

        cmp [counter2], 4
        jne notSquare

        jmp isSquare
;------------------- Imports -------------------------------------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'