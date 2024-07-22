format PE GUI 4.0 ;����������� ������ ���������� ������
;��� Windows � ������ PE (Portable Executable)
entry start
include 'win32a.inc'; ���������� ���������� win32a.inc
ID_A          = 104   ;  ���������� 
ID_B          = 103
ID_C          = 101
ID_D          = 102; 

section '.data' data readable writeable ; ���� ��������
;������������ � ��������� ������

  a  rb 10     ; ������������� 10 ���� ��� ����� a
  b rb 10     ; ������������� 10 ���� ��� ����� b
  c  rb 10     ; ������������� 10 ���� ��� ����� c
  d rb 10     ; ������������� 10 ���� ��� ����� d
  caption db 'Answer',0 ;��������� ��� ���� � �������
  message db 'Y :=   ',0 ; ������ ������ ������
  sys   dd 10 ; ���������� ��� �������� �� ���������
;������� � ��������� � ���������� ������� ���������
section '.code' code readable executable ; ����
;�������� ���� ���������
  start:
        xor      eax,eax      ;���=0
        invoke  DialogBoxParam,eax,37,HWND_DESKTOP,DialogProc1,0  ;��������� ���� ��������� ��������� DialogProc
        or      eax,eax  ;�������� eax=0
        jz      exit     ;���� ��(������ ������
;cancel), �� ������� � ����� exit
        lea     esi, [c] ;�������� � ������� esi �����
;��������� ������ �
        call    StrToInt ;�������������� ���������
;������ � ����� � �������� EAX
        mov     ebx, eax ;�������� �������� c � ebx
        lea     esi, [d] ;�������� � ������� esi ����� ;��������� ������ d
        call    StrToInt ;�������������� ��������� ;������ � ����� � �������� EAX
        mul ebx          ; eax = c*d
        mov edi, eax     ; edi = c*d
        lea     esi, [a] ;�������� � ������� esi �����
;��������� ������ a
        call    StrToInt ;�������������� ���������
;������ � ����� � �������� EAX
        mov     ebx, eax ;�������� �������� a � ebx
        lea     esi, [b] ;�������� � ������� esi �����
;��������� ������ b
        call    StrToInt ;�������������� ���������
;������ � ����� � �������� EAX

        mov     esi, eax ; esi = b
        mov     eax, edi; eax = c * d
        div     ebx      ; eax = c*d / a
        sub     ebx, esi ; ebx = a - b
        add     eax, ebx;

        lea     esi, [message+5] ;ESI=����� ������
;message+5 (��� ������ ���������� � ������ ������)
        call  IntToStr   ;����� ��������� ��������
;������ ����� �� �������� EAX � ������ �� ������ �� �������� ESI
        invoke  MessageBox,HWND_DESKTOP,message,caption,MB_OK ;api ������� ������ ��������� �� �����
  exit:
        invoke  ExitProcess,0  ; api ������� ���
;���������� ���������
proc IntToStr ; eax - �����, esi - ����� ������ ���
;������
pushad
mov ebx,10   
xor ecx,ecx  
;------ �������� � ����, ������� � ������� ��������   
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
;------ ������ �� ����� � �����         
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
proc StrToInt ;(esi-������):eax-�����,esi-�������
;������,ecx-��������� ���� enter            
xor eax,eax ; ���������
xor ecx,ecx ; ������� ����� ��������         
;mov [sys],10 ; ���������� ������� ���������        
.l:                                    
mul [sys]                                
;or edx,edx                             
;jnz .exit                   
; ��������� ������ �� ������              
movzx edx,byte [esi]                    
sub dl,30h                                 
jc .err                            
cmp dl,9h                         
; ���� dl ������ 9h, �� ������� ������    
jle .next                              
sub dl,7h                                        
.next:                                        
cmp dl,byte [sys]                              
jnc .err                                       
add eax,edx                                     
jc .err2                                     
; ����������� ecx (����� �������� �� �������)     
inc ecx                                          
; ������� ��������� �� ��������� ������        
inc esi                                       
; ��������� ��� �� ��������� ��������       
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
;������� ��������� 3-� ���� ������ � ���������� c ��
;������� �������� ������������� ID_A
        invoke  GetDlgItemText,[hwnddlg],ID_B,b,3 ; api
;������� ��������� 3-� ���� ������ � ���������� d ��
;������� �������� ������������� ID_B
        invoke  GetDlgItemText,[hwnddlg],ID_C,c,3 ; api
;������� ��������� 3-� ���� ������ � ���������� c ��
;������� �������� ������������� ID_C
        invoke  GetDlgItemText,[hwnddlg],ID_D,d,3   ; api
;������� ��������� 3-� ���� ������ � ���������� d �� �������
;�������� ������������� ID_D
topmost_ok:     
        invoke  EndDialog,[hwnddlg],1  ; api ������� ����������
;������� � ���������� ����������� �� ����� (�������� 1) 
        jmp     processed            
  wmclose: 
        invoke  EndDialog,[hwnddlg],0  ; api ������� ����������
;���������� ������� �������� �� ������ cancel (�������� 0)   
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
        
  dialog demonstration,'Laboratornay rabota 1',70,70,190,100,WS_CAPTION  ; ������ ��������� � ������� ����
;����������          
    dialogitem 'STATIC','Vvedite a:',1,10,10,170,8,WS_VISIBLE  
    dialogitem 'EDIT','',ID_A,110,9,15,13,WS_VISIBLE+WS_BORDER+WS_TABSTOP       
    dialogitem 'STATIC','Vvedite b:',1,10,20,170,8,WS_VISIBLE        
    dialogitem 'EDIT','',ID_B,110,19,15,13,WS_VISIBLE+WS_BORDER+WS_TABSTOP      
    dialogitem 'STATIC','Vvedite c:',1,10,30,170,8,WS_VISIBLE  ;������ ��������� ������ �� ����������, ������������� �������
;"�������"
    dialogitem 'EDIT','',ID_C,110,29,15,13,WS_VISIBLE+WS_BORDER+WS_TABSTOP       
    dialogitem 'STATIC','Vvedite d:',1,10,40,170,8,WS_VISIBLE        
    dialogitem 'EDIT','',ID_D,110,39,15,13,WS_VISIBLE+WS_BORDER+WS_TABSTOP      
    dialogitem 'BUTTON','OK',IDOK,85,75,45,15,WS_VISIBLE+WS_TABSTOP+BS_DEFPUSHBUTTON  ;         
    dialogitem 'BUTTON','C&ancel',IDCANCEL,135,75,45,15,WS_VISIBLE+WS_TABSTOP               
  enddialog
