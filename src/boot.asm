org 0x7C00                ; Set the origin to 0x7C00, where the bootloader is loaded

section .text             ; Declare the text section for both code and data
start:                    ; Entry point of the bootloader

    ; Set video mode to 80x25 text mode
    mov ax, 0x0003        ; 80x25 color text mode
    int 0x10              ; Call BIOS interrupt to set video mode

    ; Initialize the cursor position
    xor dh, dh            ; Set line (row) to 0 (top of the screen)
    xor dl, dl            ; Set column (column) to 0 (leftmost position)

input_loop:
    ; Print prompt character
    mov si, prompt        ; Load the address of the prompt string into SI
    call print_string     ; Print the prompt string

    ; Read characters in a loop until Enter is pressed
read_input:
    ; Wait for a key press
    mov ah, 0x01          ; Set to check for keypress
    int 0x16              ; BIOS interrupt to check for keypress
    jz read_input         ; Loop until a key is pressed

    ; Read the key and check if it is Enter
    mov ah, 0x00          ; Prepare to read the key
    int 0x16              ; Read key into AL
    cmp al, 0x0D          ; Compare AL with Enter key code (0x0D)
    je submit_line        ; Jump to submit_line if Enter is pressed

    ; Print the character and store it
    call print_char       ; Print the character in AL
    jmp read_input        ; Continue reading input

submit_line:
    ; Move to the next line
    call reset_cursor      ; Move cursor to the beginning of the next line

    jmp input_loop        ; Go back to input loop for the next command

; Print a character in AL
print_char:
    ; Print the character in AL
    mov ah, 0x0E          ; Prepare for printing a character
    int 0x10              ; Call BIOS interrupt to print character
    ret                    ; Return to the input loop

; Print a string from SI (null-terminated)
print_string:
    mov al, [si]          ; Load the byte at address SI into AL (character to print)
    cmp al, 0             ; Check if the character is null (end of string)
    je end_print          ; If it is, jump to end_print

    ; Print the character in AL
    mov ah, 0x0E          ; Prepare for printing a character
    int 0x10              ; Call BIOS interrupt to print character

    ; Move to the next character
    inc si                ; Increment SI to point to the next character
    jmp print_string      ; Repeat the loop

end_print:
    ret                    ; Return to the calling function (input_loop)

reset_cursor:
    ; Move the cursor to the next line
    inc dh                ; Increment the line (row) for the next line
    mov ah, 0x02          ; Function to set cursor position
    mov bh, 0             ; Page number (usually 0)
    mov dl, 0             ; Column (0 for the first column)
    int 0x10              ; Call BIOS interrupt to set cursor position
    ret                    ; Return to the print routine

prompt db "> ", 0        ; Define a null-terminated string for the prompt

times 510-($-$$) db 0     ; Pad with zeros to make 512 bytes
dw 0xAA55                 ; Boot sector signature
