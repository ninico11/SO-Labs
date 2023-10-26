org 7c00H
    
mov bh, 0                 
mov ax, 0H
mov es, ax                 
mov bp, msg   
             
mov al, 1  
mov cx, 6                
mov dh, 1                
mov dl, dh                

mov ax, 1302H
int 10H

jmp $                    

msg db 'H', 09H, 'e', 0aH, 'l', 0bH, 'l', 0cH, 'o', 0dH
    