org 7c00H
    
mov bh, 0                 
mov ax, 0H
mov es, ax                 
mov bp, msg   

mov bl, 0fH                
mov al, 1                
mov cx, 12                
mov dh, 1                
mov dl, dh                

mov ax, 1300H
int 10H

jmp $                    

msg dd "Hello World!"
    