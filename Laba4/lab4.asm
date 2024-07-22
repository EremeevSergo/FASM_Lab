format PE GUI 4.0   ;специальный формат исполнимых
;файлов для Windows — формат PE (Portable Executable)
entry start
include 'win32a.inc'; подключаем библиотеку win32a.inc
ID_x          = 101    ;  дескриптор для x
section '.data' data readable writeable ; блок описания
;используемых в программе данных
  x  rb 10     ; зарезервируем 10 байт для ввода x
  caption db 'Ответ',0 ;заголовок для окна с ответом
  error   db 'Ошибка ввода!!!',0
  message db 'F(x)=          ',0 ; шаблон текста ответа
  sys   dd 10  ; для перевода из цифрового формата в
;текстовый в десятичной системе счисления
  chislo dd ?
section '.code' code readable executable ; блок
;описания кода программы
 start:
        xor      eax,eax      ;EAX=0
        invoke  DialogBoxParam,eax,37,HWND_DESKTOP,DialogProc,0 ;открываем окно используя процедуру DialogProc
        or      eax,eax  ;проверим eax=0
        jz      exit     ;если да(нажата кнопка
;cancel), то переход к метке exit
        lea     esi, [x] ;загрузим в регистр esi адрес
;введенной строки x
        call    StrToInt ;преобразование введенной
;строки x в число в регистре EAX
        or      ecx,ecx  ;ecx=0?
        jnz     norm     ;если нет, то ввод данных
;корректный
        invoke  MessageBox,HWND_DESKTOP,error,caption,MB_OK ;вывод
;сообщения об ошибке
        jmp     exit
; вычислим ответ
 norm:  cmp      eax,0 ;сравним наше число x с 0
        jl       var1  ; Если EAX<0 то переход к метке var1
        cmp      eax,3 ;сравним наше число x с 3
        jg       var1  ; Если EAX>3 то переход к метке var1
        mov      ebx,eax ; ebx = eax (ebx = x)
        mul      ebx    ; eax = eax * ebx (eax = x * x)
        jmp      vivod   ; переходим к выводу:результата
var1:   mov      eax,4    ; eax = 4
vivod:  lea     esi, [message+6] ;ESI=адрес строки
;message+6 (для вывода результата в шаблон ответа)
        call  IntToStr
        invoke  MessageBox,HWND_DESKTOP,message,caption,MB_OK
  exit:
        invoke  ExitProcess,0
proc IntToStr; eax - число, esi - адрес строки для
;вывода
pushad
mov ebx,10
xor ecx,ecx
;------ загоняем в стек, начиная с младших разрядов
start1:
cmp eax,0
je end1
xor edx,edx
div ebx
or dl,30h
push edx
inc ecx
jmp start1
end1:
;------ читаем из стека в буфер
start3:
cmp ecx,0
je end3
pop eax
mov [esi],al
inc esi
dec ecx
jmp start3
end3:
popad
ret
endp
;********************************************************************************************
proc StrToInt ;(esi-строка):eax-число,esi-остаток
;строки,ecx-прочитано цифр enter
xor eax,eax ; Результат
xor ecx,ecx ; Счетчик числа символов
.l:
mul [sys]
; считываем символ из строки
movzx edx,byte [esi]
sub dl,30h
jc .err
cmp dl,9h
; если dl меньше 9h, то переход дальше
jle .next
sub dl,7h
.next:
cmp dl,byte [sys]
jnc .errs
add eax,edx
jc .err2
; Увеличиваем ecx (число символов на единицу)
inc ecx
; Смещаем указатель на следующий символ
inc esi
; Повторяем все со следующим символом
jmp .l
.err2:
sub eax,edx
.err:
xor edx,edx
jmp .exit
.errs:
xor ecx,ecx
ret
.exit:
div [sys]
ret
endp
proc DialogProc,hwnddlg,msg,wparam,lparam
        push    ebx esi edi
        cmp     [msg],WM_INITDIALOG
        je      processed
        cmp     [msg],WM_COMMAND
        je      wmcommand
        cmp     [msg],WM_CLOSE
        je      wmclose
        xor     eax,eax
        jmp     finish
 wmcommand:
        cmp     [wparam],BN_CLICKED shl 16 + IDCANCEL
        je      wmclose
        cmp     [wparam],BN_CLICKED shl 16 + IDOK
        jne     processed
        invoke  GetDlgItemText,[hwnddlg],ID_x,x,10
topmost_ok:
        invoke  EndDialog,[hwnddlg],1
        jmp     processed
  wmclose:
        invoke  EndDialog,[hwnddlg],0
  processed:
        mov     eax,1
  finish:
        pop     edi esi ebx
        ret
endp
section '.idata' import data readable writeable
  library kernel,'KERNEL32.DLL',\
          user,'USER32.DLL'
  import kernel,\
         GetModuleHandle,'GetModuleHandleA',\
         ExitProcess,'ExitProcess'
  import user,\
         DialogBoxParam,'DialogBoxParamA',\
         CheckRadioButton,'CheckRadioButton',\
         GetDlgItemText,'GetDlgItemTextA',\
         IsDlgButtonChecked,'IsDlgButtonChecked',\
         MessageBox,'MessageBoxA',\
         EndDialog,'EndDialog'
section '.rsrc' resource data readable
  directory RT_DIALOG,dialogs
  resource dialogs,\
          37,LANG_RUSSIAN,demonstration    
  dialog demonstration,'Laboratornay rabota 4',100,100,110,60,WS_CAPTION ; задаем заголовок,
;координаты верхнего левого угла окна на экране, ширина
;окна, высота окна
    dialogitem 'STATIC','X=',1,10,10,70,8,WS_VISIBLE        ; задаем заголовок строки ее координаты, устанавливаем
;атрибут "видимая"
    dialogitem 'EDIT','',ID_x,22,8,15,13,WS_VISIBLE+WS_BORDER+WS_TABSTOP       ;
    dialogitem 'BUTTON','OK',IDOK,10,35,45,15,WS_VISIBLE+WS_TABSTOP+BS_DEFPUSHBUTTON  ;
    dialogitem 'BUTTON','C&ancel',IDCANCEL,60,35,45,15,WS_VISIBLE+WS_TABSTOP         ;
  enddialog
