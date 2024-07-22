format PE GUI 4.0 ;специальный формат исполнимых файлов
;для Windows — формат PE (Portable Executable)
entry start
include 'win32a.inc'; подключаем библиотеку win32a.inc
ID_A          = 104   ;  дескриптор 
ID_B          = 103
ID_C          = 101
ID_D          = 102; 

section '.data' data readable writeable ; блок описания
;используемых в программе данных

  a  rb 10     ; зарезервируем 10 байт для ввода a
  b rb 10     ; зарезервируем 10 байт для ввода b
  c  rb 10     ; зарезервируем 10 байт для ввода c
  d rb 10     ; зарезервируем 10 байт для ввода d
  caption db 'Answer',0 ;заголовок для окна с ответом
  message db 'Y :=   ',0 ; шаблон текста ответа
  sys   dd 10 ; переменная для перевода из цифрового
;формата в текстовый в десятичной системе счисления
section '.code' code readable executable ; блок
;описания кода программы
  start:
        xor      eax,eax      ;ЕАХ=0
        invoke  DialogBoxParam,eax,37,HWND_DESKTOP,DialogProc1,0  ;открываем окно используя процедуру DialogProc
        or      eax,eax  ;проверим eax=0
        jz      exit     ;если да(нажата кнопка
;cancel), то переход к метке exit
        lea     esi, [c] ;загрузим в регистр esi адрес
;введенной строки с
        call    StrToInt ;преобразование введенной
;строки в число в регистре EAX
        mov     ebx, eax ;сохраним значение c в ebx
        lea     esi, [d] ;загрузим в регистр esi адрес ;введенной строки d
        call    StrToInt ;Преобразование введенной ;строки в число в регистре EAX
        mul ebx          ; eax = c*d
        mov edi, eax     ; edi = c*d
        lea     esi, [a] ;загрузим в регистр esi адрес
;введенной строки a
        call    StrToInt ;преобразование введенной
;строки в число в регистре EAX
        mov     ebx, eax ;сохраним значение a в ebx
        lea     esi, [b] ;загрузим в регистр esi адрес
;введенной строки b
        call    StrToInt ;преобразование введенной
;строки в число в регистре EAX

        mov     esi, eax ; esi = b
        mov     eax, edi; eax = c * d
        div     ebx      ; eax = c*d / a
        sub     ebx, esi ; ebx = a - b
        add     eax, ebx;

        lea     esi, [message+5] ;ESI=адрес строки
;message+5 (для вывода результата в шаблон ответа)
        call  IntToStr   ;вызов процедуры перевода
;целого числа из регистра EAX в строку по адресу из регистра ESI
        invoke  MessageBox,HWND_DESKTOP,message,caption,MB_OK ;api функция вывода сообщения на экран
  exit:
        invoke  ExitProcess,0  ; api функция для
;завершения программы
proc IntToStr ; eax - число, esi - адрес строки для
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
;**************************************************************************************         
proc StrToInt ;(esi-строка):eax-число,esi-остаток
;строки,ecx-прочитано цифр enter            
xor eax,eax ; Результат
xor ecx,ecx ; Счетчик числа символов         
;mov [sys],10 ; Определяет систему счисления        
.l:                                    
mul [sys]                                
;or edx,edx                             
;jnz .exit                   
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
jnc .err                                       
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
.exit:                                        
div [sys]                                    
ret                                      
endp                                        
proc DialogProc1,hwnddlg,msg,wparam,lparam        
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
        invoke  GetDlgItemText,[hwnddlg],ID_A,a,3 ; api
;функция получения 3-х байт текста в переменную c из
;объекта имеющего идентификатор ID_A
        invoke  GetDlgItemText,[hwnddlg],ID_B,b,3 ; api
;функция получения 3-х байт текста в переменную d из
;объекта имеющего идентификатор ID_B
        invoke  GetDlgItemText,[hwnddlg],ID_C,c,3 ; api
;функция получения 3-х байт текста в переменную c из
;объекта имеющего идентификатор ID_C
        invoke  GetDlgItemText,[hwnddlg],ID_D,d,3   ; api
;функция получения 3-х байт текста в переменную d из объекта
;имеющего идентификатор ID_D
topmost_ok:     
        invoke  EndDialog,[hwnddlg],1  ; api функция завершения
;диалога с введенными аргументами из формы (параметр 1) 
        jmp     processed            
  wmclose: 
        invoke  EndDialog,[hwnddlg],0  ; api функция аварийного
;завершения диалога нажатием на кнопку cancel (параметр 0)   
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
          37,LANG_RUSSIAN,demonstration    \      
        
  dialog demonstration,'Laboratornay rabota 1',70,70,190,100,WS_CAPTION  ; задаем заголовок и размеры окна
;приложения          
    dialogitem 'STATIC','Vvedite a:',1,10,10,170,8,WS_VISIBLE  
    dialogitem 'EDIT','',ID_A,110,9,15,13,WS_VISIBLE+WS_BORDER+WS_TABSTOP       
    dialogitem 'STATIC','Vvedite b:',1,10,20,170,8,WS_VISIBLE        
    dialogitem 'EDIT','',ID_B,110,19,15,13,WS_VISIBLE+WS_BORDER+WS_TABSTOP      
    dialogitem 'STATIC','Vvedite c:',1,10,30,170,8,WS_VISIBLE  ;задаем заголовок строки ее координаты, устанавливаем атрибут
;"видимая"
    dialogitem 'EDIT','',ID_C,110,29,15,13,WS_VISIBLE+WS_BORDER+WS_TABSTOP       
    dialogitem 'STATIC','Vvedite d:',1,10,40,170,8,WS_VISIBLE        
    dialogitem 'EDIT','',ID_D,110,39,15,13,WS_VISIBLE+WS_BORDER+WS_TABSTOP      
    dialogitem 'BUTTON','OK',IDOK,85,75,45,15,WS_VISIBLE+WS_TABSTOP+BS_DEFPUSHBUTTON  ;         
    dialogitem 'BUTTON','C&ancel',IDCANCEL,135,75,45,15,WS_VISIBLE+WS_TABSTOP               
  enddialog
