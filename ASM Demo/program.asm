.386
.model	flat, stdcall
.stack	4096

STD_OUTPUT_HANDLE		equ -11
STD_INPUT_HANDLE		equ -10

GetStdHandle			proto, stdHandle:dword

WriteConsole			equ	<WriteConsoleA>
WriteConsole			proto, handle:dword, buffer:dword, bytesToWrite:dword, bytesWritten:dword, reserved:dword

ReadConsole				equ <ReadConsoleA>
ReadConsole				proto, handle:dword, buffer:dword, bytesToRead:dword, bytesRead:dword, reserved:dword

ExitProcess				proto, exitCode:dword

.data
MessageInit		byte	13, "Welcome to the Wowza Kowza Fun Time Wacky Hour!", 13, 10, 0
MessageEnd		byte	"And thus ends the wacky fun. Press enter to exit...", 13, 10, 0
Wowza			byte	"Wowza", 0
Kowza			byte	"Kowza", 0
NewLine			byte	13, 10, 0
Colon			byte	":", 0
Number			byte	4	dup	(?)

.data?
ConsoleOutHandle	dword	?
ConsoleInHandle		dword	?
BytesWritten		dword	?
BytesRead			dword	?
StringBuffer		dword	?

.const
NULL	equ	0

.code
IntToAscii	proc, workingValue:dword
	pushad
	mov		ecx, 3
	mov		byte ptr [Number], 30h
	mov		byte ptr [Number + 1], 30h
	mov		byte ptr [Number + 2], 30h
	mov		byte ptr [Number + 3], 0h
	mov		eax, workingValue
div10loop:
	mov		ebx, 10
	xor		edx, edx
	idiv	ebx
	add		edx, 30h
	mov		byte ptr [Number + ecx - 1], dl
	dec		ecx
	cmp		ecx, 0
	jne		div10loop
	popad
	ret
IntToAscii	endp

GetStringLength proc uses edi, byteString:ptr byte
	mov edi, byteString
	mov	eax, 0
L1:
	cmp	byte ptr [edi], 0
	je	L2
	inc	edi
	inc eax
	jmp	L1
L2:
	ret
GetStringLength endp

Write proc
	pushad
	push	edx
	call	GetStringLength
	cld
	push	NULL
	push	offset BytesWritten
	push	eax
	push	edx
	push	ConsoleOutHandle
	call	WriteConsole
	popad
	ret
Write endp

Read proc
	push NULL
	push offset BytesRead
	push 1
	push offset StringBuffer
	push ConsoleInHandle
	call ReadConsole
	ret
Read endp

main proc
	push	STD_OUTPUT_HANDLE
	call	GetStdHandle
	mov		[ConsoleOutHandle], eax
	push	STD_INPUT_HANDLE
	call	GetStdHandle
	mov		[ConsoleInHandle], eax
	mov		edx, offset MessageInit
	call	Write
	mov		ecx, 0
MLoop:
	cmp		ecx, 100
	je		Exit
	inc		ecx
	push	ecx
	call	IntToAscii
	mov		edx, offset Number
	call	Write
	mov		edx, offset Colon
	call	Write
	; Checking for wowza
	mov		eax, ecx	; Copy counter to EAX
	mov		ebx, 3		; Copy Divisor to EBX
	xor		edx, edx	; Zeroing EDX
	idiv	ebx			; EDX:EAX / EBX or eg: 8778/3 = 22:4A/03 = 00100010:01001010 / 00000011 EAX=Quotient EDX=Remainder
	cmp		edx, 0
	jne		CheckKow
	; Wowza
	mov		edx, offset Wowza
	call	Write
CheckKow:
	mov		eax, ecx
	mov		ebx, 5
	xor		edx, edx
	idiv	ebx
	cmp		edx, 0
	jne		EndWowKow
	; Kowza
	mov		edx, offset Kowza
	call	Write
EndWowKow:
	mov		edx, offset NewLine
	call	Write
	jmp		MLoop
Exit:
	mov		edx, offset MessageEnd
	call	Write
	call	Read
	push	0
	call	ExitProcess
main endp

end main