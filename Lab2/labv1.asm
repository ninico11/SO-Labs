org 7c00h           ; Set the origin of the program to 7c00h

buffer: times 256 db 0h   ; Define a 256-byte buffer for input
mov si, buffer            ; Initialize SI register to point to the buffer

write_chr:               ; Start of the write_chr loop
	mov ah, 0           ; Set AH register to 0 for keyboard input
	int 16h             ; Call interrupt 16h to get a key press

	cmp ah, 0eh         ; Compare the value in AH with backspace (0x0e)
	je press_backspace  ; If equal, jump to the press_backspace label

	cmp ah, 1ch         ; Compare the value in AH with enter (0x1c)
	je press_enter      ; If equal, jump to the press_enter label

	cmp si, buffer + 256  ; Compare SI with the end of the buffer
	je write_chr         ; If SI has reached the end of the buffer, continue

	mov [si], al         ; Store the character in AL into the buffer at [SI]
	add si, 1            ; Increment SI to point to the next buffer location

	mov ah, 0eh          ; Set AH to 0x0e for display function
	int 10h              ; Call interrupt 10h to print the character on the screen

	jmp write_chr         ; Jump back to the beginning of the write_chr loop

press_backspace:        ; Label for handling backspace key press
	cmp si, buffer       ; Compare SI with the start of the buffer
	je write_chr         ; If SI is at the start, continue with write_chr

	sub si, 1             ; Decrement SI to move it back in the buffer
	mov byte [si], 0     ; Clear the character in the buffer at [SI]

	mov ah, 03h           ; Set AH to 0x03 for cursor information
	mov bh, 0             ; Set BH to 0 for page 0
	int 10h               ; Call interrupt 10h to get cursor information

	cmp dl, 0             ; Compare DL (cursor column) with 0
	jz previous_line      ; If DL is 0, jump to previous_line
	jmp write_space       ; Otherwise, jump to write_space

write_space:            ; Label for writing a space character
	mov ah, 02h           ; Set AH to 0x02 for writing character function
	sub dl, 1             ; Decrement DL (cursor column)
	int 10h               ; Call interrupt 10h to write a space

	mov ah, 0ah           ; Set AH to 0x0a for write attribute function
	mov al, 20h           ; Set AL to 0x20 for space character
	mov cx, 1             ; Set CX to 1 for the number of spaces to write
	int 10h               ; Call interrupt 10h to write the space character
	jmp write_chr         ; Jump back to the beginning of the write_chr loop

previous_line:           ; Label for moving to the previous line
	mov ah, 02h           ; Set AH to 0x02 for setting cursor position
	mov dl, 79            ; Set DL to 79 (last column)
	sub dh, 1             ; Decrement DH (cursor row)
	int 10h               ; Call interrupt 10h to set the cursor position

press_enter:            ; Label for handling enter key press
	mov ah, 03h           ; Set AH to 0x03 for cursor information
	mov bh, 0             ; Set BH to 0 for page 0
	int 10h               ; Call interrupt 10h to get cursor information

	sub si, buffer        ; Calculate the number of characters in the buffer
	jz move_curs_down     ; If SI is 0, jump to move_curs_down

	cmp dh, 24            ; Compare DH (cursor row) with 24
	jl print_word         ; If DH is less than 24, jump to print_word

	mov ah, 06h           ; Set AH to 0x06 for scroll function
	mov al, 1             ; Set AL to 1 (scroll up by 1 row)
	mov bh, 07h           ; Set BH to 07h (attribute for new lines)
	mov cx, 0             ; Set CX to 0 (start column)
	mov dx, 184fh         ; Set DX to 184Fh (end column and row)
	int 10h               ; Call interrupt 10h to scroll the screen
	mov dh, 17h           ; Set DH to 17h (end row)

print_word:              ; Label for printing the word in the buffer
	mov bh, 0              ; Set BH to 0 for page 0
	mov ax, 0              ; Clear AX register
	mov es, ax             ; Set ES register to 0 for video memory
	mov bp, buffer         ; Set BP to the buffer address

	mov bl, 07h            ; Set BL to 07h (attribute for the text)
	mov cx, si             ; Set CX to the number of characters in the buffer
	add dh, 1              ; Increment DH (cursor row)
	mov dl, 0              ; Set DL to 0 (start column)

	mov ax, 1301h          ; Set AH to 13h (write string) and AL to 01h (write with attribute)
	int 10h                ; Call interrupt 10h to write the string with attribute

move_curs_down:          ; Label for moving the cursor down
	mov ah, 03h            ; Set AH to 0x03 for cursor information
	mov bh, 0              ; Set BH to 0 for page 0
	int 10h                ; Call interrupt 10h to get cursor information

	mov ah, 02h            ; Set AH to 0x02 for setting cursor position
	mov bh, 0              ; Set BH to 0 for page 0
	add dh, 1              ; Increment DH (cursor row)
	mov dl, 0              ; Set DL to 0 (start column)
	int 10h                ; Call interrupt 10h to set the cursor position

	add si, buffer         ; Move SI to the start of the buffer

clear_buffer:            ; Label for clearing the buffer
	mov byte [si], 0       ; Clear the character at the current buffer location
	add si, 1              ; Move SI to the next buffer location
	cmp si, 0              ; Compare SI with 0 (end of buffer)
	jne clear_buffer        ; If SI is not at the end, continue clearing
	mov si, buffer          ; Reset SI to point to the start of the buffer
	jmp write_chr           ; Jump back to the beginning of the write_chr loop
