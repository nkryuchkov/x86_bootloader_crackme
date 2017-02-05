	use16
	org		7C00h


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


start:
	mov		ax, cs
	mov		ds, ax
	mov		es, ax

	mov		si, pass_enter
	call	puts_with_delay

	mov		di, password
	call	read_pass

	mov		di, vendor_id
	call	vendor

	call	writeln

	mov		si, password
	call	puts_with_delay

	mov		di, password
	mov		si, vendor_id
	call	check_password

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;FUNCTIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


puts_with_delay:						; si = string
	cld
	mov		ah, 0Eh
	xor		bh, bh
puts_loop:
	mov		cx, 0001h
	xor		dx, dx
	call	delay
	lodsb
	test	al, al
	jz  	puts_loop_exit
	int 	10h
	jmp 	puts_loop
puts_loop_exit:
	ret

writeln:
	mov		si, newline
	call	puts_with_delay
	ret

read_key:								; al = ASCII code
	mov		ah, 10h
	int		16h
	ret

read_pass:								; di = string
	mov		cx, 000Ch
	cld
pass_loop:
	call	read_key
	stosb
	loop 	pass_loop
	ret

check_password:							; si = string1, di = string2
	mov 	cx, 0Dh
	repe	cmpsb
	jnz		password_incorrect
	mov		si, good
	call	puts_with_delay
	xor		dx, dx
	mov 	cx, 0010h
	call	delay
	call	shutdown
	ret
password_incorrect:
	mov		si, bad
	call	puts_with_delay
	xor		dx, dx
	mov 	cx, 0010h
	call	delay
	call	reboot	
	ret

vendor:									; di = message
	xor		eax, eax
	cpuid
	mov		dword[di], ebx
	mov		dword[di+04h], edx
	mov		dword[di+08h], ecx
	ret

reboot:
	jmp 	0FFFFh:0000h
	ret

shutdown:
	mov		ax, 5307h
	mov		bx, 0001h
	mov		cx, 0003h
	int		15h
	ret

delay:									; CX:DX = microseconds
	pusha
	mov		ah, 86h
	int		15h
	popa
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DATA;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


pass_enter:
	db		"Enter the password (12 bytes): ", 00h

good:
	db		0Dh, 0Ah, "Good job, hacker! The key is your input.", 0Dh, 0Ah, "Good bye! ", 01h, 0Dh, 0Ah, 00h

bad:
	db		0Dh, 0Ah, "You failed ", 02h, 0Dh, 0Ah, "Try again.", 0Dh, 0Ah, 00h

newline:
	db		0Dh, 0Ah, 00h

password:
	times 	13 db 00h

vendor_id:
	times	13 db 00h

finish:
	times	1FEh-finish+start db 00h	; fill with nulls
	db  	55h, 0AAh					; signature