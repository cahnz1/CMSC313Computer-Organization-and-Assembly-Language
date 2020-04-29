	;;  CMSC 313 - SPRING 2018 - Project 3 - 4x4 TicTacToe

	        %define cmpb    cmp byte
	        %define decb    dec byte
	        %define incb    inc byte
	        %define xorb    xor byte
	        %define movb    mov byte
	        %define movq    mov qword
	        %define subb    sub byte
section .bss		; Uninitialized data
	        buffer          resb    4
	        pfunc           resq    1
	        buffer2 resb 4
	        pfunc2 resq 1
;;; 3x3 buffer
		buffer3 resb 4
;; dimension of the board
	        dim resb 4
;;; dimension of the board minus 1 (for the loops)
		dimM resb 4
;;; outer loop counter
	        row resb 4
;; inner loop counter
		col resb 4
;;; single digit number that is entered for moves is stored here
		num1 resb 4
;;; ; single digit number that is entered for moves is stored here
	        num2 resb 4
;;; keeps track of whos turn it is
		player resb 4
;;; counter for check wins
		count resb 4
		var resb 4
;;; a counter for diaginal checks
		i resb 4
		two resb 4
;;; counter for double digit intake
		j resb 4
		tally resb 1
		c resb 4
;;; counters for getting log 10 of c
		k resb 4
		d resb 4
		logC resb 4
;;; check if its a tie
		tieCheck resb 1
		dimSq resb 1
;;; buffer for mines
		buffer4 resb 4
;;; store the location of each mine
	mine1 resb 1
	mine2 resb 1

section .data		; Initialized data

		mdbg            db              "Do you want to enable debug information?", 0xA
	        mdbgl           equ             $ - mdbg

	        mstart          db              "If you would like to play 3x3 enter 3. If you would like to play 4x4, enter 4. If you would like to play 5x5, enter 5", 0xA
	        mstart1         equ             $ - mstart

;;; opening line that tells the user wich places are valid
;;; ; ; 3x3 board
     tx3 db " Enter a position between (0-8) ",0xA
     tx31 equ $ - tx3
;;; ; ; ; 4x4 board
     tx4 db " Enter a position between (0-15) ", 0xA
     tx41 equ $ - tx4
;;; ; ; ; 5x5 board
     tx5 db " Enter a position between (0-24) ",0xA
     tx51 equ $ - tx5
;;; ; ; ; not valid 
	notV        db              "Not valid position try agian ", 0xA
	notV1       equ             $ - notV
;; 	who goes first
	playerTurn        db              "Player X goes first"
	playerTurn1       equ             $ - playerTurn
;;; player 1
	        mplayer1        db              "Player X "
	        mplayer11       equ             $ - mplayer1
;;; player 2
	        mplayer2        db              "Player O "
	        mplayer22       equ             $ - mplayer2
;;new line
		nl db 0xA
		nl1 equ $- nl
;;; ; ; ; place mines message 3x3
	     minePrompt db " Enter a position for a mine (0-8) ",0xA
	     minePrompt1 equ $ - minePrompt
;;; ; ; ; ; place mines message 4x4
	minePrompt2 db " Enter a position for a mine (0-15) ",0xA
	minePrompt21 equ $ - minePrompt2
;;; ; ; ; ; place mines message 5x5
	minePrompt3 db " Enter a position for a mine (0-24) ",0xA
	minePrompt31 equ $ - minePrompt3
;;; spaces on board
		bSpace db "                         "
		bspacel equ $ - bSpace
;;; pipe
	        pipe db "|"
	        pipe1 equ $ - pipe
;;;  under lines
	        under db "--"
	        under1 equ $ - under
;;; ;  extra dash (needed to get the spacing rt)
	        dash db "-"
	        dash1 equ $ - dash
	printme db " "
	printmel equ $ - printme
;;; what the heck are we printing
	rns db "print debug begins:'"
	rnsl equ $ - rns
	rns1 db "' ends", 0xA
	rns1l equ $ - rns1	
;;; win and lose messages
	xW            db              "Player X wins!", 0xA
	xWl           equ             $ - xW
	
	oW            db              "Player O wins!", 0xA
	oWl           equ             $ - oW

	tie           db              "It's a draw (tie)!", 0xA
	tiel          equ             $ - tie
;;; stepped on a mine
	xWb            db              "You exploded! Player X wins!", 0xA
	xWbl           equ             $ - xWb

	oWb            db              "You exploded! Player O wins!", 0xA
	oWbl           equ             $ - oWb
		
section .text			; Code
global  _start		; Export entry point
	
do_debug:

print_int:			; ecx: const char* msg, edx: size_t msgl
;;; ; save whatever is in ebx and eax
	        push rbx
	        push rax

		mov             eax,4 ; System call number (sys_write)
	        mov             ebx,1 ; First argument: file descriptor (stdout == 1)
	        int             0x80  ; Call kernel
	
;;;  bring them back
	        pop rax
	        pop rbx
		ret

read_int:			; ecx: char* msg, ; edx: size_t msgl
	        mov             eax,3 ; System call number (sys_read)
	        xor             ebx,ebx	; First argument: file descriptor (stdin == 0)
	        int             0x80	; Call kernel
		ret

print_board:
;;; initialize indexes
	movb [row],0
	movb [col],0

;;; outer loop for row creation
nrow:
	mov [col], byte 0
;;; inner loop for colum creation
ncol:
;;move dim into eax and add col so we can move them into ecx
;;;[bSpace+row*dim+col]
	xor eax,eax
	xor ebx, ebx
	
	mov eax, [dim]
	mov ebx, [row]
	mul ebx

	add eax,[col]
;;; [bSpace+row*dim+col]
	mov bl, [bSpace+eax]
	mov [printme],bl
	mov ecx, printme
	
	mov edx, 1
	call print_int
;;; the inside if condition:
	
;;cmp col and [dim-1]
;;; [dim-1] part

	mov eax, [dimM]

	cmpb [col], al
	jge endcol
;;; print |
	mov ecx, pipe
	mov edx, pipe1
	
	call print_int

newLine:	
;;; cmp col and dim
	cmpb [col], al
	jl endcol

;;; print nl
	mov ecx, nl
	mov edx, nl1

	call print_int

;; if row!=dim - 1
	cmpb [row], al
	je nrow
endcol:
	incb[col]
	cmpb [col],al
	jle ncol
;;; ; print nl
	mov ecx, nl
	mov edx, nl1

	call print_int
;;;   for
innerFor:

	mov al, [dimM]
	cmpb [row],al

;;; i need to ret here
	je leaveBoard
	
	movb [col], 0
	mov eax, [dimM]
;;; cmp col and dim-1
innerFor2:
	mov ecx, under
	mov edx, under1

	call print_int

	inc byte[col]
	cmpb [col],al
	
	jl innerFor2
		
	mov ecx, dash
	mov edx, dash1

	call print_int
		
	mov ecx, nl
 	mov edx, nl1

	call print_int

;;; row's condition and increment
	incb [row]

;;; cmp row and dim
	mov eax, [dim]
	cmpb [row], al
	jl nrow
leaveBoard:
	ret

;;; this sectoin will send the user to the correct bored to check the proper conditions
;;; in regard to that board
play:	
	cmpb    [buffer2],'3'
	jne              skipplay1
	call play1
skipplay1:	
	cmpb    [buffer2],'4'
	jne             skipplay2

	call play2
	
skipplay2:	
	cmpb    [buffer2],'5'
	jne            skipplay3

	call play3
	
skipplay3:
	ret



;;;   change the player
changePlayer:
	                cmpb [player], 1
	                jne changeToX

;;; ; changes to o
	                movb [player], 0
;;;               jmp playerTurn1
			ret

	changeToX:
	                movb [player], 1

;;;               jmp playerTurn1
			ret
		
;;; prompts user with appropriate message for each board
minePlacer:
		cmpb    [dim],3
	        jne              skipmine1
minePlacer1:	
;;; ; opening instructions
;;; prompt player
		mov ecx, minePrompt
	        mov edx, minePrompt1

	        call print_int
;;; ; read user's location
		mov             ecx,buffer4 ; Store input at location 'buffer'
		mov             edx,2	    ; Read these many bytes
		call    read_int

		mov bl, [buffer4]
		sub bl, '0'
		mov [num1], bl

		cmpb [num1], 9
		jl isvalidminep1

		call notValid
		jmp minePlacer
isvalidminep1:
		mov eax, [num1]
		mov bl,[bSpace+eax]

		cmp bl, ' '
		je isSpaceminep1

		call notValid
		jmp minePlacer
;;; ; o's turn
isSpaceminep1:
;;; after validating it stores the location of the mine according to whos turn it is
		cmpb [player], 0
		jne xTurnminep1

		mov [mine2], al
		jmp changeplayerminep1

	xTurnminep1:
		mov [mine1], al

changeplayerminep1:
;;; ; this changes the player to o
		call changePlayer
		ret
skipmine1:
	        cmpb    [dim],4
	        jne             skipmine2
;;; prompt playyer
;;; ; ; opening instructions
		mov ecx, minePrompt2
		mov edx, minePrompt21
		call print_int
;;; ; ; read user's location
		mov             ecx,buffer4 ; Store input at location 'buffer'
		mov             edx,3       ; Read these many bytes
		call    read_int

movb [k],0
log10CheckMinep2:
	        mov ecx,[k]
	        mov al, [buffer4+ecx]
	        mov [d], al

		ifForLog10Minep2:
;;; check if there is a new line
	                cmp al, 0xA
	                jne incKMinep2

	                 mov [d], ecx
	                 jmp checkDoubleDigitAMinep2
incKMinep2:
	                incb [k]
;;; checks if the number is above 9
	                cmpb [d], 0x39
	                jg invalid2aMinep2

	                jmp nextComMinep2
		invalid2aMinep2:
	                call notValid

			nextComMinep2:
;;; checks if the number is below 0
	                        cmpb [d], 0x30
	                        jl invalid2bMinep2

	                        jmp nextMinep2

				invalid2bMinep2:
	                                call notValid

				nextMinep2:
 	                                jmp log10CheckMinep2
checkDoubleDigitAMinep2:
	                movb [j], 0
;;; ; al is our tally
	                movb al, 0
	checkDoubleDigitMinep2:
;;;  checks and converts the number imputed
	                mov ecx,[j]
	                mov bl, [buffer4+ecx]

	                subb bl, '0'
	                add al, bl
	                incb [j]

	                mov dl,[k]
	                cmp [j], dl
			jge isValid2Minep2
;;; ; mul by 10
	                mul byte [nl]
	                jmp checkDoubleDigitMinep2
	isValid2Minep2:
	                cmp al, 16
	                jge notvalid2Minep2

	                cmp al, 0
	                jl notvalid2Minep2

	                jmp pickPlayerMinep2

			notvalid2Minep2:

	                        call notValid
				jmp checkDoubleDigitAMinep2
			pickPlayerMinep2:
	                                mov bl,[bSpace+eax]
	                                cmp bl, ' '
	                                je isSpace2Minep2

	                                call notValid
					jmp checkDoubleDigitAMinep2
isSpace2Minep2:
;;; ; ; o's turn
	                                cmpb [player], 0
	                                jne xTurn2Minep2

	                                mov [mine2], eax
	                                jmp changeplayerminep2
					xTurn2Minep2:
						mov [mine1], eax
	changeplayerminep2:
	                                call changePlayer
					ret	
skipmine2:
	        cmpb    [dim],5
	        jne            skipmine3
;;; prompt player
;;; ; ; opening instructions
		mov ecx, minePrompt3
		mov edx, minePrompt31
		call print_int
;;; ; ; read user's location
		mov             ecx,buffer4 ; Store input at location 'buffer'
		mov             edx,3       ; Read these many bytes
		call    read_int
	movb [k],0
log10Check3Minep3:
	                mov ecx,[k]
	                mov al, [buffer4+ecx]
	                mov [d], al
	ifForLog103Minep3:
	                        cmp al, 0xA
	                        jne incK3Minep3

	                         mov [d], ecx
	                         jmp checkDoubleDigitA3Minep3
incK3Minep3:
	                        incb [k]

	                        cmpb [d], 0x39
	                        jg invalid2a3Minep3
	                        jmp nextCom3Minep3
		invalid2a3Minep3:
	                        call notValid
				nextCom3Minep3:
	                                cmpb [d], 0x30
	                                jl invalid3bMinep3

	                                jmp next3Minep3

					invalid3bMinep3:
	                                        call notValid
					next3Minep3:	
			 jmp log10Check3Minep3
checkDoubleDigitA3Minep3:
	                        movb [j], 0
;;; ; ; al is our tally
	                        movb al, 0
	checkDoubleDigit3Minep3:
;;; ;  checks and converts the number imputed
	                        mov ecx,[j]
	                        mov bl, [buffer4+ecx]

 	                        subb bl, '0'

	                        add al, bl
				incb [j]

	                        mov dl,[k]
	                        cmp [j], dl
	                        jge isValid23Minep3

	
;;; ; ; mul by 10
	                        mul byte [nl]

	                        jmp checkDoubleDigit3Minep3

isValid23Minep3:
				cmp al, 25
	                        jge notvalid23Minep3

	                        cmp al, 0
	                        jl notvalid23Minep3

	                        jmp pickPlayer3Minep3
			notvalid23Minep3:

	                                call notValid
					jmp skipmine2
		pickPlayer3Minep3:
	                         mov bl,[bSpace+eax]

	                                        cmp bl, ' '
	                                        je isSpace3Minep3

	                                        call notValid
						jmp skipmine2
isSpace3Minep3:
;;; ; ; ; o's turn
	                                        cmpb [player], 0
	                                        jne xTurn3Minep3

	                                        mov [mine2], al

	                                        jmp changeplayerminep3
					xTurn3Minep3:

						mov [mine1], eax
	changeplayerminep3:

	                                        call changePlayer
	                                        ret	
skipmine3:
	        ret

notValid:
	mov ecx, notV
	mov edx, notV1
	call print_int
	ret
	
_start:
	movb [player], 1
	movb [tieCheck], 0
	;;  Enable debug?
	        mov             ecx,mdbg ; Second argument: pointer to message to write
	        mov             edx,mdbgl ; Third argument: message length
	        call    print_int
	;;  Read answer
	        mov             ecx,buffer ; Store input at location 'buffer'
	        mov             edx,2	   ; Read these many bytes
	        call    read_int
;;;   Switch case
	                cmpb    [buffer],'Y'
	                je              do_debug
	                cmpb    [buffer],'y'
	                je              do_debug
	                cmpb    [buffer],'D'
	                je              do_debug
	                cmpb    [buffer],'d'
	                je              do_debug
;;;   which board?
	                mov             ecx,mstart
	                mov             edx,mstart1
	                call    print_int
;;;   Read answer
	                mov             ecx,buffer2 ; Store input at location 'buffer'
	                mov             edx,2	    ; Read these many bytes
	                call    read_int
;;; sets up dim, dimM, and dimSq
		mov bl, [buffer2]
		sub bl, '0'
	        mov [dim], bl
		mov al,bl
		mul bl
		mov [dimSq], al
		mov [dimM], bl
	        subb [dimM], 1

		call minePlacer
		call minePlacer
		call print_board
	
		call play
play1:
;;; opening instructions
 	mov ecx, tx3
 	mov edx, tx31
	
	call print_int

;;;  start at x
		movb [player], 1

playerTurn1a:
		cmpb [player], 1
		jne Oturn1

;;; print x's turn
		mov ecx, mplayer1
		mov edx, mplayer11

		call print_int
		jmp playerTurn1b
	
	Oturn1:
;;;  ; ; player 2 turn message
		
	                mov ecx, mplayer2
	                mov edx, mplayer22
	                call print_int
	
	playerTurn1b:	

;;; read user's location
		mov             ecx,buffer3 ; Store input at location 'buffer'
		mov             edx,2 ; Read these many bytes
		call    read_int
;;; ; convert the character entered into a number and store it in dim
		mov bl, [buffer3]
		sub bl, '0'
		mov [num1], bl

		cmpb [num1], 9
		jl isvalid1

		call notValid
		jmp playerTurn1a
isvalid1:
		mov eax, [num1]

		mov bl,[bSpace+eax]

		cmp bl, ' '
		je isSpace1

		call notValid
		jmp playerTurn1a
;;; o's turn
isSpace1:	
		cmpb [player], 0
		jne xTurn1

		call mineCheck
		movb [bSpace+eax], 'O'
	
		jmp printTheThing	

	xTurn1:	
		call mineCheck
	
		movb [bSpace+eax], 'X'

	printTheThing:	
		call print_board
		incb [tieCheck]
		call checkWin1		
;;; this changes the player to o
		call changePlayer
		jmp playerTurn1a

play2:
;;; ; opening instructions
	mov ecx, tx4
	mov edx, tx41
	call print_int
;;; ;  start at x
                movb [player], 1
	playerTurn2a:
	                cmpb [player], 1
	                jne Oturn2 
;;; ; print x's turn
	                mov ecx, mplayer1
	                mov edx, mplayer11
	                call print_int
	                jmp playerTurn2b
		Oturn2:
;;; ;  ; ; player 2 turn message
	                        mov ecx, mplayer2
	                        mov edx, mplayer22
	                        call print_int
	playerTurn2b:	
;;; ; read user's location
		mov             ecx,buffer3 ; Store input at location 'buffer'
		mov             edx,3	    ; Read these many bytes
		call    read_int
;;; this loop checks if a single digit was inputed or two digits
	movb [k],0
log10Check:
	mov ecx,[k]
	mov al, [buffer3+ecx]
	mov [d], al

	ifForLog10:
		cmp al, 0xA
		jne incK

		 mov [d], ecx
	         jmp checkDoubleDigitA
	
incK:
		incb [k]

		cmpb [d], 0x39
		jg invalid2a

		jmp nextCom
	invalid2a:
		call notValid
		nextCom:
	                cmpb [d], 0x30
	                jl invalid2b

	                jmp next
			invalid2b:
				call notValid

			next:
				jmp log10Check

;;; once we know how many digits were imputed, each digit is evaluated and mul if needed by 10
checkDoubleDigitA:
		movb [j], 0
;;; al is our tally
		movb al, 0
	checkDoubleDigit:
		;; checks and converts the number imputed
		mov ecx,[j]
		mov bl, [buffer3+ecx]

		subb bl, '0'

		add al, bl
		
		incb [j]

		mov dl,[k]
		cmp [j], dl
		jge isValid2

;;; mul by 10
		mul byte [nl]

		jmp checkDoubleDigit
;;; now that we have the value converted into double or single digit--> check if its in the dimensions of the board
	
	isValid2:

		cmp al, 16
		jge notvalid2

		cmp al, 0
		jl notvalid2

		jmp pickPlayer
	
		notvalid2:

			call notValid
			jmp playerTurn2a
	
	
			pickPlayer:

				mov bl,[bSpace+eax]

				cmp bl, ' '
				je isSpace2

				call notValid
				jmp playerTurn2a
	;; we now can place the players piece
isSpace2:
		;;; ; o's turn
	 	                cmpb [player], 0
	 	                jne xTurn2
				call mineCheck
	
				movb [bSpace+eax], 'O'

				jmp printTheThing2
	
	 			xTurn2:
				call mineCheck
	
				movb [bSpace+eax], 'X'                 	
				
printTheThing2:	
				call print_board
				incb [tieCheck]
				call checkWin1
				
				call changePlayer
				jmp playerTurn2a

	
;;; ;play3 works just like play2 except it compares the digits enetered with 25 instead of 16

play3:
;;; ; ; opening instructions
	        mov ecx, tx5
	        mov edx, tx51
	        call print_int
;;; ; ;  start at x
	                movb [player], 1
playerTurn3a:
	                        cmpb [player], 1
	                        jne Oturn3
;;; ; ; print x's turn
	                        mov ecx, mplayer1
	                        mov edx, mplayer11
	                        call print_int
	                        jmp playerTurn3b
			Oturn3:
;;; ; ;  ; ; player 2 turn message
	                                mov ecx, mplayer2
	                                mov edx, mplayer22
	                                call print_int
	playerTurn3b:
;;; ; ; read user's location
	                mov             ecx,buffer3 ; Store input at location 'buffer'
	                mov             edx,3       ; Read these many bytes
	                call    read_int

	        movb [k],0
log10Check3:

	        mov ecx,[k]
	        mov al, [buffer3+ecx]
	        mov [d], al
	ifForLog103:
	                cmp al, 0xA
	                jne incK3

	                 mov [d], ecx
	                 jmp checkDoubleDigitA3

incK3:
	                incb [k]

	                cmpb [d], 0x39
	                jg invalid2a3
			jmp nextCom3
	invalid2a3:
	                call notValid
			nextCom3:
	                        cmpb [d], 0x30
	                        jl invalid3b

	                        jmp next3
				invalid3b:
	                                call notValid
				next3:
	                                jmp log10Check3

checkDoubleDigitA3:
	                movb [j], 0
;;; ; al is our tally
	                movb al, 0

	checkDoubleDigit3:
;;;  checks and converts the number imputed
	                mov ecx,[j]
	                mov bl, [buffer3+ecx]

	                subb bl, '0'

	                add al, bl


	                incb [j]

	                mov dl,[k]
	                cmp [j], dl
	                jge isValid23

;;; ; mul by 10
	                mul byte [nl]

	                jmp checkDoubleDigit3
	isValid23:
	                cmp al, 25
	                jge notvalid23

	                cmp al, 0
	                jl notvalid23

	                jmp pickPlayer3

		notvalid23:

	                        call notValid
	                        jmp playerTurn3a

			pickPlayer3:


			 mov bl,[bSpace+eax]

	                                cmp bl, ' '
	                                je isSpace3

	                                call notValid
	                                jmp playerTurn3a
	isSpace3:	
;;; ; ; o's turn
	                                cmpb [player], 0
	                                jne xTurn3
					call mineCheck
	
	                                movb [bSpace+eax], 'O'

	                                jmp printTheThing3

					xTurn3:
					call mineCheck
	
	                                movb [bSpace+eax], 'X'
	printTheThing3:
	                                call print_board
					incb [tieCheck]
	                                call checkWin1
					
	                                call changePlayer
	                                jmp playerTurn3a
	

;;;  check if the player landed on a mine
mineCheck:
;;; if x landed on o's mine
	        cmpb [player], 1
	        jne checkOmine

	        cmp al, [mine2]
	        jne leaveCheck

	        mov ecx, oWb
	        mov edx, oWbl

	        call print_int

		mov bl, [mine1]
		movb [bSpace + ebx], '1'
	
	        mov eax, [mine2]
	        movb [bSpace + eax], '@'
	        call print_board


	        jmp exit


;;; ; o stepped on x's mine
checkOmine:
	                cmp al, [mine1]
	                jne leaveCheck

	                mov ecx, xWb
	                mov edx, xWbl

	                call print_int


			mov bl, [mine2]
	                movb [bSpace + ebx], '2'
	
			mov al, [mine1]
	                movb [bSpace + eax], '!'
	                call print_board
	

	                jmp exit
leaveCheck:

	ret
;;; check win
checkWin1:
	
;;; row check
	checkRow:
		movb [row], 0
		movb [col], 0
		movb [count], 0

		xIf:
;;;  checks if player is x if not, player is o
			cmpb [player], 1
			jl varEO

			movb [var], 'X'
			jmp crl
		varEO:
;;;  player is o
			movb [var], 'O'
			jmp cc1
		crl:
	;; row loop
;;; reset col to 0 for the next row
			mov [col], byte 0
			movb [count], 0
		cc1:	;; col loop
;;; move dim into eax and add col so we can move them into ecx
;;; ;[bSpace+row*dim+col]
			xor eax,eax
			xor ebx, ebx
	
			mov eax, [dim]
			mov ebx, [row]
			mul ebx

			add eax,[col]
;;; ; [bSpace+row*dim+col]
			mov cl, [bSpace+eax]
		check:
	;; this will check if the space equals the var and add it to count
;;; so we can check if its a win
			cmpb [var], cl
			jne jmpd

			add [count],byte 1

			mov eax, [dim]
			cmp [count], eax
			je pWins

			mov edx, [dimM]
	
			incb [col]	

			cmpb [col], dl
			jle cc1

			jmpd:	
				incb [row]
				mov eax, [dimM]
				cmp [row], eax
				jl crl
;; checks if there is a col win
	checkCol:
		movb [row], 0
		movb [col], 0
		movb [count], 0

		xIfcol:
;;; ;  checks if player is x if not, player is o
			cmpb [player], 1
			jl varEOcol

			movb [var], 'X'
			jmp crlcol
		varEOcol:
	;;; ;  player is o
			movb [var], 'O'
			jmp cc1col
		crlcol:
;;;  col loop
;;; ; reset row to 0 for the next col
			mov [row], byte 0
			movb [count], 0
		cc1col:	
	;;  row loop
;;; ; move dim into eax and add col so we can move them into ecx
;;; ; ;[bSpace+col*dim+row]
			xor eax,eax
			xor ebx, ebx

			mov eax, [dim]
			mov ebx, [row]
			mul ebx

			add eax,[col]
;;; ; ; [bSpace+col*dim+row]
			mov cl, [bSpace+eax]
		checkcolum:
;;;  this will check if the space equals the var and add it to count
;;; ; so we can check if its a win
			cmpb [var], cl
			jne jmpdcol
	
			add [count],byte 1
	
			mov eax, [dim]
			cmp [count], eax
			je pWins
	
			mov edx, [dimM]
	
			incb [row]

			cmpb [row], dl
			jle cc1col

		jmpdcol:
			incb [col]
;;; ;     movb [count], 0
			mov eax, [dimM]
			cmp [col], eax
			jl crlcol
;;; checks diaginal bottom left to top rt
			movb [count], 0
			movb [i], 0
	checkDig2:
;;; ; ; ;[bSpace+(2 -i) * dim + i]
		xor eax,eax
		xor ebx, ebx
;;; (2-i)
		mov eax, [dimM]
		mov [two], eax
		mov eax, [i]
		sub [two], eax

		mov eax, [two]
;;; dim (2-i)
		mov ebx, [dim]
		mul ebx
;;; [((2-i) * dim) +i]
		add eax, [i]
;;; ; ; ; [bspace +[((2-i) * dim) +i]]
		mov cl, [bSpace+eax]
		For:	
		firstIfDig2:
;;; if var == bspace...
			cmp [var], cl
			jne endOfLoop
			add [count],byte 1
	secondIfDig2:
;;; check if count equals 3, if so, send to proper win message
		mov eax, [dim]
		cmp [count], eax
	
		je pWins
;;;  i<dim for the for loop
		mov eax,[dim]
		incb [i]
		cmpb [i], al
		jl checkDig2

		endOfLoop:
			movb [count], 0
			movb [i], 0
		checkDig1:
;;; ; ; ; ;[bSpace+ (i * dim) + i]
			xor eax,eax
			xor ebx, ebx
;;; ; dim * i
			mov eax, [i]
			mov ebx, [dim]
			mul ebx
;;; ; [(i * dim) +i]
			add eax, [i]
;;; ; ; ; ; [bspace +[(i * dim) +i]]
			mov cl, [bSpace+eax]
		For1:
			firstIfDig1:	
;;; ; if var == bspace...
				cmp [var], cl
				jne endOfLoop1
				add [count],byte 1
			secondIfDig1:
;;; ; check if count equals 3, if so, send to proper win message
				mov eax, [dim]
				cmp [count], eax
				je pWins
;;; ;  i<dim for the for loop
				mov eax,[dim]
				incb [i]
				cmpb [i], al
				jl checkDig1
		endOfLoop1:


;;; checkTie1:
		mov al, [dimSq]
		cmp [tieCheck], al
		jne returntie
		
		mov ecx, tie
		mov edx, tiel
		
		call print_int
		jmp exit
	
returntie:	
				ret

pWins:
	cmpb [var], 'X'
	jne owins
;;; message x wins
	mov ecx, xW
	mov edx, xWl
	call print_int

	mov bl, [mine1]
	movb [bSpace + ebx], '1'

	mov eax, [mine2]
	movb [bSpace + eax], '2'
	call print_board
	
	jmp exit
owins:
;;; message o wins
	mov ecx, oW
	mov edx, oWl
	call print_int
	
	mov bl, [mine1]
	movb [bSpace + ebx], '1'

	mov eax, [mine2]
	movb [bSpace + eax], '2'
	call print_board

	jmp exit
exit:
;;; ; quit
	mov eax, 1	;system call number (sys_exit)
	xor ebx, ebx
	int 0x80	