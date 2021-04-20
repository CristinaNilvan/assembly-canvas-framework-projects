.386
.model flat, stdcall

includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc

public start

.data

include digits.inc
include letters.inc

window_title db "Hello World", 0
area_width equ 640		
area_height equ 480		
area dd 0

counter dd 0

argument_1 equ 8				
argument_2 equ 12
argument_3 equ 16
argument_4 equ 20

symbol_width equ 10
symbol_height equ 20

.code

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp + argument_1] 			
	
	cmp eax, 'A'
	jl make_digit
	
	cmp eax, 'Z'
	jg make_digit
	
	sub eax, 'A'
	lea esi, letters
	jmp draw_text

	make_digit :
		cmp eax, '0'
		jl make_space
		
		cmp eax, '9'
		jg make_space
		
		sub eax, '0'
		
		lea esi, digits
		jmp draw_text

	make_space :	
		mov eax, 26 					
		lea esi, letters
	
	draw_text :
		mov ebx, symbol_width
		mul ebx
		mov ebx, symbol_height
		mul ebx
		add esi, eax
		mov ecx, symbol_height

	lines_symbol_loop :	; 
		mov edi, [ebp + argument_2]		 	
		mov eax, [ebp + argument_4] 				
		add eax, symbol_height
		sub eax, ecx
		mov ebx, area_width
		mul ebx
		add eax, [ebp + argument_3]				
		shl eax, 2 							
		add edi, eax
		push ecx
		mov ecx, symbol_width

	columns_symbol_loop :
		cmp byte ptr [esi], 0
		je white_pixel_symbol
		mov dword ptr [edi], 0
		jmp next_pixel_symbol

	white_pixel_symbol :
		mov dword ptr [edi], 0FFFFFFh

	next_pixel_symbol :
		inc esi
		add edi, 4
		loop columns_symbol_loop
		pop ecx
		loop lines_symbol_loop
		
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp


make_text_macro macro symbol, draw_area, x, y
	push y
	push x
	push draw_area
	push symbol
	call make_text
	
	add esp, 16
endm

draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp + argument_1]		
	
	cmp eax, 1
	jz event_click
	
	cmp eax, 2
	jz event_timer 				
	
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	
	push eax
	push 255				
	push area
	call memset
	
	add esp, 12
	
	jmp display_on_screen
	
	event_click :
		mov eax, [ebp + argument_3]								
		mov ebx, area_width
		mul ebx												
		add eax, [ebp + argument_2]								
		shl eax, 2		
		
		add eax, area   
		
		mov dword ptr [eax], 0FF0000h						
		mov dword ptr [eax + 4], 0FF0000h					
		mov dword ptr [eax - 4], 0FF0000h		           
		mov dword ptr [eax + 4 * area_width], 0FF0000h		
		
		mov dword ptr [eax - 4 * area_width - 4], 0FF0000h
		mov dword ptr [eax - 4 * area_width + 4], 0FF0000h
		
		mov dword ptr [eax + 4 * area_width - 4], 0FF0000h
		mov dword ptr [eax + 4 * area_width + 4], 0FF0000h
		mov dword ptr [eax + 8 * area_width], 0FF0000h

	event_timer :
		inc counter
	
	display_on_screen :

	mov ebx, 10
	mov eax, counter

	mov edx, 0 
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10

	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10

	mov edx, 0
	div ebx
	add edx, '0'
	
	make_text_macro edx, area, 10, 10
	
	make_text_macro 'H', area, 260, 220
	make_text_macro 'E', area, 270, 220
	make_text_macro 'L', area, 280, 220
	make_text_macro 'L', area, 290, 220
	make_text_macro 'O', area, 300, 220
	
	make_text_macro 'W', area, 320, 220
	make_text_macro 'O', area, 330, 220
	make_text_macro 'R', area, 340, 220
	make_text_macro 'L', area, 350, 220
	make_text_macro 'D', area, 360, 220
	
	final_draw:
	
	popa
	mov esp, ebp
	pop ebp
	ret
	
draw endp

start:

	;Writes Hello World on the screen and also when you click somewhere it draws a heart.
	
	mov eax, area_width
	mov ebx, area_height
	mul ebx						
	shl eax, 2	
	
	push eax
	call malloc
	
	add esp, 4
	
	mov area, eax
	
	push offset draw			
	push area					
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	
	add esp, 20
	
	push 0
	call exit
end start
