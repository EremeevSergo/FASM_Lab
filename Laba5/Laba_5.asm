; ������ ���������� ������������ ������ �5 �� ����������
;            ___   ___
;  Y = X3 /\((X2 /\ X3) \/ X1)
;
format PE GUI 4.0
entry start
include 'win32a.inc'

ID_x1 = 101
ID_x2 = 102
ID_x3 = 103

section '.data' data readable writeable
x1 rb 2
x2 rb 2
x3 rb 2
caption_er db '������!',0
message_er db '������� �� ������ ��������� x1, x2, x3',0
caption db '�����',0
message db 'Y('
x_1 db 0,','
x_2 db 0,','
x_3 db 0,')='
y db 0,0

section '.code' code readable executable
start:
xor eax,eax
invoke DialogBoxParam,eax,37,HWND_DESKTOP,DialogProc,0
or eax,eax
jz exit
mov al,[x1]
mov [x_1],al
sub al,30h
jz ok_1
cmp al,1
jz ok_1
jmp error
ok_1: mov bl,[x2]
mov [x_2],bl
sub bl,30h
jz ok_2
cmp bl,1
jz ok_2
jmp error
ok_2: mov ah,[x3]
mov [x_3],ah
sub ah,30h
jz ok_3
cmp ah,1
jz ok_3
jmp error
ok_3:
;al=x1, bl=x2, ah=x3
;���������� ���������� ������� Y �� �������� � ������� �������
mov bh,ah ;bh=ah (bh=x3)
and bl,ah ;bl=bl/\ah (bl=(x2/\x3))
or bl,al ;bl=bl/al (bl=(x2/\x3)/x1)
mov bh,bh ;bh=bh/\bl (bh=x3/\((x2/\x3)/x1))
add bh,30h
mov [y],bh
invoke MessageBox,HWND_DESKTOP,message,caption,MB_OK
jmp exit
error: invoke MessageBox,HWND_DESKTOP,message_er,caption_er,MB_OK
jmp exit
exit:
invoke ExitProcess,0
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
        invoke  GetDlgItemText,[hwnddlg],ID_x1,x1,2   ; api ������� ��������� 2-� ���� ������ � ���������� x1 �� ������� �������� ������������� ID_x1
        invoke  GetDlgItemText,[hwnddlg],ID_x2,x2,2   ; api ������� ��������� 2-� ���� ������ � ���������� x2 �� ������� �������� ������������� ID_x2
        invoke  GetDlgItemText,[hwnddlg],ID_x3,x3,2   ; api ������� ��������� 2-� ���� ������ � ���������� x3 �� ������� �������� ������������� ID_x3
topmost_ok:
        invoke  EndDialog,[hwnddlg],1  ; api ������� ���������� ������� � ���������� ����������� �� ����� (�������� 1)
        jmp     processed
  wmclose:
        invoke  EndDialog,[hwnddlg],0  ; api ������� ���������� ���������� ������� �������� �� ������ cancel (�������� 0)
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

  dialog demonstration,'Laboratornay rabota 3',70,70,120,65,WS_CAPTION               ; ������ ��������� � ������� ���� ����������
    dialogitem 'STATIC','x1:',1,10,10,170,8,WS_VISIBLE        ; ������ ��������� ������ �� ����������, ������������� ������� "�������"
    dialogitem 'EDIT','',ID_x1,20,9,10,13,WS_VISIBLE+WS_BORDER+WS_TABSTOP       ;
    dialogitem 'STATIC','x2:',1,10,20,170,8,WS_VISIBLE        ;
    dialogitem 'EDIT','',ID_x2,20,19,10,13,WS_VISIBLE+WS_BORDER+WS_TABSTOP      ;
    dialogitem 'STATIC','x3:',1,10,30,170,8,WS_VISIBLE        ;
    dialogitem 'EDIT','',ID_x3,20,29,10,13,WS_VISIBLE+WS_BORDER+WS_TABSTOP      ;
    dialogitem 'BUTTON','OK',IDOK,15,45,45,15,WS_VISIBLE+WS_TABSTOP+BS_DEFPUSHBUTTON  ;
    dialogitem 'BUTTON','C&ancel',IDCANCEL,65,45,45,15,WS_VISIBLE+WS_TABSTOP         ;
  enddialog
