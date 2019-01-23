section	.text
global  turtle
;1 ebp do not change
;2 esi+ecx important esi structure (6-empty, 10-x, 10-empty, 6-y) ecx structure(5-empty, 3-color, 7-empty, 1-up/down, 6-empty, 2-dir 8-instruction start)
;1 ebx - move - (16-empty, 4- empty, 12-value)

;ecx structure(12-color, 3-empty, 1-up/down, 6-empty, 2-dir 8-instruction start)
 
turtle:
	push	ebp
	mov	ebp, esp

	

		mov	esi, 0			;reset esi
		mov	ecx, 0			;reset ecx
		mov	cl, -2
	loop:
		add	cl, 2			;advance instruction counter
		cmp	cl, [ebp+16]
		jge	loop_exit	
		
		mov 	eax, [ebp+12]		;set eax to commands start
		movzx	edi, cl
		add	eax, edi		;advance eax to current instruciton	
		mov	eax, [eax]		;load the value of eax
		shr	al, 6			;get first 2 bits of the command
		
		cmp	al, 3
		je	command_move
		cmp	al, 2
		je	command_set_pen_state
		cmp 	al, 1
		je	command_set_position
		jmp	command_set_direction

	loop_exit:
		jmp	end

;=========================================================================================
	command_set_direction:
		mov 	eax, [ebp+12]		;set eax to commands start
		movzx	edi, cl
		add	eax, edi		;advance eax to current instruciton
		mov	eax, [eax]		;load the value of eax

		shl 	ah, 6			;offset bits
		shr	ah, 6			;d1,d0 bits of command (turtle dir)

		
		mov	ch, ah			;set dir
		
		jmp 	loop
;=========================================================================================
	command_set_position:
		add	cl, 2			;advance instruction counter (32 bit instruction)
		mov 	eax, [ebp+12]		;set eax to commands start
		movzx	edi, cl
		add	eax, edi		;advance eax to current instruciton
		mov	eax, [eax]		;load the value of eax

;		rol	eax, 16			;rol eax 16

		shr	al, 2			;y5-y0 bits of command

		

		movzx	si, al			;save y		

		mov 	eax, [ebp+12]		;set eax to commands start
		movzx	edi, cl
		add	eax, edi		;advance eax to current instruciton
		mov	eax, [eax]		;load the value of eax

		rol	ax, 14			;offset bits
		shr	ax, 6			;offset bits

;		movzx	edx,ax
;		jmp	end
		
		rol	esi, 16			;prepare esi for saving
		mov	si, ax			;set x
		rol	esi, 16			;revert esi after saving

		jmp 	loop
;=========================================================================================
	command_set_pen_state:
		
	;COLORS	
		
		mov 	eax, [ebp+12]		;set eax to commands start
		movzx	edi, cl
		add	eax, edi		;advance eax to current instruciton
		mov	eax, [eax]		;load the value of eax
		rol	ecx, 16

		;rol	eax ,16
		shr	ax, 8		;offset bits
		shl	ax, 12			;offset bits
		mov	cx, ax			;set color bits

		mov 	eax, [ebp+12]		;set eax to commands start
		movzx	edi, cl
		add	eax, edi		;advance eax to current instruciton
		mov	eax, [eax]		;load the value of eax
		
		;rol	eax ,16

		shr	ax, 12			;offset bits
		shl	ax, 8			;offset bits

		add	cx,ax

		mov 	eax, [ebp+12]		;set eax to commands start
		movzx	edi, cl
		add	eax, edi		;advance eax to current instruciton
		mov	eax, [eax]		;load the value of eax

		;rol	eax ,16		
		shl	ax, 12			;offset bits
		shr	ax, 8			;offset bits

		add	cx,ax

		

		rol	ecx, 16			;revert ecx after saving		
	;UPDOWN
		mov 	eax, [ebp+12]		;set eax to commands start
		movzx	edi, cl
		add	eax, edi		;advance eax to current instruciton
		mov	eax, [eax]		;load the value of eax

		shl	al, 3			;offset bits
		shr	al, 7			;ud bit of command
		
		rol	ecx, 16			;prepare ecx for saving
		shl	ecx, 1			;clear ud
		shr	ecx, 1			;clear up
		add	cl, al			;set ud

		rol	ecx, 16			;after save
			

		jmp 	loop
;=========================================================================================
	command_move:
		mov 	ebx, 0			;reset ebx
		mov 	eax, [ebp+12]		;set eax to commands start
		movzx	edi, cl
		add	eax, edi		;advance eax to current instruciton
		mov	eax, [eax]		;load the value of eax

		rol	ax, 8
		shl	ax, 6			;offset bits
		shr	ax, 6			;offset bits

		mov	bx, ax			;set how many to move	
		
		;======================================
		move_loop:
			cmp 	ebx, 0
			jle	move_loop_exit		
			
			rol	esi, 16			;prepare esi for reading x
			cmp	si, 0
			jl	move_error		;Error: x<0
			cmp	si, 600
			jge	move_error		;Error: x>=600
			rol	esi, 16			;prepare esi for reading y
			cmp	si, 0		
			jl	move_error		;Error: y<0
			cmp	si, 50
			jge	move_error		;Error: y>=50

			rol	ecx, 16			;prepare ecx for reading ud
			mov	edi,ecx
			shl	edi,31
			shr	edi,31

			rol	ecx, 16			;invert ecx after reading ud
			
			cmp	edi, 0
			je	move_paint
			
		move_continue:
			cmp	ch, 3
			je	move_right
			cmp	ch, 2
			je	move_down
			cmp	ch, 1
			je	move_left
			jmp	move_up
		move_continue2:
			sub	ebx, 1			;Reduce move counter
			jmp 	move_loop

		move_paint:
			mov 	edx, 0			;reset edx
			mov 	edi, 0			;reset edi
					
			movzx	edi, si			;read y
			mov 	eax, 1800		;calculate byte offset based on y
			mul	edi			;-||-
			mov 	edi, eax		;save offset in edi
	
			rol 	esi, 16			;prepare esi for reading x
			movzx	edx, si			;read x
			add	edi, edx		;add offset based on x	
			add	edi, edx		;add offset based on x	
			add	edi, edx		;add offset based on x	
			rol 	esi, 16			;invert esi after reading x
			add	edi, 122		;header offset

			mov	edx, DWORD [ebp+8]	;address of bitmap
			add	edx, edi		;add offset to address

			mov 	eax, DWORD [edx]	;read 4 bytes in to eax
			
			rol 	ecx, 16			;prepare ecx for reading color			
			rol	eax, 16			;prepare eax for reading 1 byte of other channel color
	
			movzx 	edi, ah			;save 1 byte of other channel color to edi
			
			rol	eax, 16

		;SET COLOR
           
           
       		;RED
        		mov al,ch
			shr al,4
        		shl al,4		;rrrr0000
        		mov     BYTE [edx + 0], al;store eax in bitmap
        	;GREEN 
			mov al,ch
            		shr al,4        ;gggg0000
			
            		mov     BYTE [edx + 1], al  ;store eax in bitmap
        	;BLUE
            		mov al,cl
        				;bbbb0000
            		mov     BYTE [edx + 2], al;store eax in bitmap
            

		finish_setting_color:
			rol 	eax, 8			;prepare eax for good color restore		
			add	eax, edi		;restore saved channel color
			rol 	eax, 24		;invert eax after restoring color

			rol 	ecx, 16			;invert ecx after reading color	
			


			mov 	DWORD [edx], eax	;store eax in bitmap  

			jmp 	move_continue
			
		move_up:
			add	si, 1			;Move 1 up
			jmp	move_continue2
		move_down:
			sub	si, 1			;Move 1 down
			jmp	move_continue2
		move_right:
			rol	esi, 16			;Prepare esi for reading x
			add	si, 1			;Move 1 right
			rol	esi, 16			;Invert esi after reading x
			jmp	move_continue2
		move_left:
			rol	esi, 16			;Prepare esi for reading x
			sub	si, 1			;Move 1 right
			rol	esi, 16			;Invert esi after reading x
			jmp	move_continue2

		move_error:
			mov	ebx, 0			;reset move counter
			
			cmp	ch, 3
			je	move_left		;Cancel move 1 right
			cmp	ch, 2
			je	move_up			;Cancel move 1 down
			cmp	ch, 1
			je	move_right		;Cancel move 1 left
			jmp	move_down		;Cancel move 1 up

		move_loop_exit:
		;======================================
		jmp 	loop
;=========================================================================================
end:
	mov	eax, 0
	pop	ebp
	ret
