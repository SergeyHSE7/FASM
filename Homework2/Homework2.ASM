format PE console
entry start

; Студент: Елесин Сергей
; Группа: БПИ-193
; Вариант: 5

; Задание: сгенерировать массив В из элементов A,
; значение которых не совпадает с введённым числом x

include 'win32a.inc'

;------------------------- Data ----------------------------------------------
section '.data' data readable writable

        strVecSize   db 'Input size of vector A: ', 0
        strNumberX   db 'Input the number X: ', 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strVecElemI  db '[%d] = ', 0
        strScanInt   db '%d', 0
        strVecOutA   db 10, 'Vector A:', 10, 0
        strVecOutB   db 10, 'Vector B:', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        x            dd 0   ; число X
        A_size       dd 0   ; размер массива А
        B_size       dd 0   ; размер массива В
        i            dd ?
        tmp          dd ?
        tmpStack     dd ?
        vecA         rd 100 ; массив А
        vecB         rd 100 ; массив В

;------------------------- Code -----------------------------------------------
section '.code' code readable executable
start:
; 0) number x input
        push strNumberX
        call [printf]

        push x
        push strScanInt
        call [scanf]

; 1) vector А input
        call VectorInput

; 2) generate vector B
        call VectorWithoutX

; 3) vector B out
        push strVecOutB
        call [printf]

        call VectorOut

finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push A_size
        push strScanInt
        call [scanf]
        add esp, 8

        push strVecOutA
        call [printf]
        add esp, 4

        mov eax, [A_size]
        cmp eax, 0
        jg  getVector
; завершаем программу при введёном размере меньше или равном 0
        push A_size
        push strIncorSize
        call [printf]
        push 0
        call [ExitProcess]
; заполняем массив
getVector:
        xor ecx, ecx
        mov ebx, vecA
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [A_size]
        jge endInputVector

        ; считываем значение
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;--------------------------------------------------------------------------
VectorWithoutX:
        xor ecx, ecx
        mov ebx, vecA
        mov edx, vecB
VecLoop:
        cmp ecx, [A_size]
        je endSumVector

        ; сравниваем значение из массива А с числом Х
        mov eax, [x]
        cmp [ebx], eax
        je ToNextElem

        mov eax, [ebx]
        mov [edx], eax
        add edx, 4
        inc [B_size]

ToNextElem:
        inc ecx
        add ebx, 4
        jmp VecLoop
endSumVector:
        ret
;--------------------------------------------------------------------------
VectorOut:
        mov [tmpStack], esp
        xor ecx, ecx
        mov ebx, vecB
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [B_size]
        je endOutputVector
        mov [i], ecx

        ; выводим значение
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop
endOutputVector:
        mov esp, [tmpStack]
        ret

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