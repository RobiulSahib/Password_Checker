.MODEL SMALL
.STACK 100H

.DATA

; declare variables here
welcomeMsg DB "Welcome to password strength checker$"
promptUser DB "Enter Username: $" 
usernameInput DB 21       ; Max length the user can type (20 + 1 for Enter)
              DB ?        ; Actual number of characters typed
              DB 20 DUP(?) ; Buffer for characters (max 20 characters)  

promptPass DB "Enter Password: $" 
passwordInput DB 21       ; Max length 20
              DB ?        ; Actual length entered
              DB 20 DUP(?) ; Buffer for typed password     
              
warnMatch DB 13,10,"Password cannot contain the username!$"
suggestionMsg  DB 13,10,"Username and password are valid. Suggestion(s):$"  

digitCount     DB 0
upperCount     DB 0
lowerCount     DB 0
specialCount   DB 0 

newline DB 13, 10, "$"
sequence1 DB 0
sequence2 DB 0 

passwordstr DB 0      ; for password strength score (0-7)

;message for password strength

vweak db "Password Strength: The password is very weak!$"
weak db "Password Strength: The password is weak!$"
moderate db "Password Strength: The password is moderate!$" 
strong db "Password Strength: The password is strong!$" 
vstrong db "Password Strength: The password is very strong!$" 

;message for suggestions 

addDigitsMsg DB 13,10, "Try to add digits!$", 0
addUpperMsg  DB 13,10, "Try to add uppercase letters!$", 0
addLowerMsg  DB 13,10, "Try to add lowercase letters!$", 0
addSpecialMsg DB 13,10, "Try to add special characters!$", 0       

removeSeqMsg DB 13,10, "Try to remove sequences!$", 0



.CODE
MAIN PROC

; initialize DS
MOV AX,@DATA
MOV DS,AX
 
; Print welcomeMsg   
LEA DX, welcomeMsg    
MOV AH, 09H           
INT 21H              

; New line
MOV AH, 02H
MOV DL, 0DH   ; Carriage Return
INT 21H
MOV DL, 0AH   ; Line Feed
INT 21H
  
; Print the prompt message for username
LEA DX, promptUser
MOV AH, 09H
INT 21H 

; Get username input
LEA DX, usernameInput
MOV AH, 0AH
INT 21H 

; New line
MOV AH, 02H
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H

; Print the prompt message for password
LEA DX, promptPass
MOV AH, 09H
INT 21H

; Get password input
LEA DX, passwordInput
MOV AH, 0AH
INT 21H

; Set SI = username , CL = username length
MOV SI, OFFSET usernameInput + 2
MOV CL, [usernameInput + 1]        ; Correctly get length byte

; Set DI = password, CH = password length
MOV DI, OFFSET passwordInput + 2
MOV CH, [passwordInput + 1]        ; Correctly get length byte

MOV BX, DI         ; BX = start of password buffer

CHECK_LOOP:
    ; check if remaining password length is less than username length
    MOV AL, CH
    CMP AL, CL
    JB VALID_MSG   ; if password is shorter, can't contain username

    PUSH SI
    PUSH BX
    PUSH CX

    MOV SI, OFFSET usernameInput + 2
    MOV DI, BX
    MOV AL, CL         ; counter for comparing username length
    MOV DL, 0          ; match flag = 0

REPEAT_CHECK:
    CMP AL, 0
    JE MATCH_FOUND

    MOV AH, [SI]
    CMP AH, [DI]
    JNE NO_MATCH

    INC SI
    INC DI
    DEC AL
    JMP REPEAT_CHECK

MATCH_FOUND:
    MOV DL, 1
    JMP AFTER_COMPARE

NO_MATCH:
    MOV DL, 0

AFTER_COMPARE:
    POP CX
    POP BX
    POP SI

    CMP DL, 1
    JE SHOW_WARNING

    INC BX
    DEC CH
    JMP CHECK_LOOP

SHOW_WARNING:
    LEA DX, warnMatch
    MOV AH, 09H
    INT 21H
    JMP EXIT

VALID_MSG:
    LEA DX, suggestionMsg
    MOV AH, 09H
    INT 21H

    ; Initialize counters to zero
    MOV AL, 0
    MOV digitCount, AL
    MOV upperCount, AL
    MOV lowerCount, AL
    MOV specialCount, AL

    ; Set CX = password length, SI = password buffer
    MOV CL, [passwordInput + 1]
    MOV CH, 0
    MOV SI, OFFSET passwordInput + 2

COUNT_LOOP:
    CMP CX, 0
    JE DONE_COUNTING

    MOV AL, [SI]

    ; Check digit '0' to '9'
    CMP AL, '0'
    JB CHECK_UPPERCASE
    CMP AL, '9'
    JA CHECK_UPPERCASE

    ; Increment digitCount
    MOV BL, digitCount
    INC BL
    MOV digitCount, BL
    JMP NEXT_CHAR

CHECK_UPPERCASE:
    CMP AL, 'A'
    JB CHECK_LOWERCASE
    CMP AL, 'Z'
    JA CHECK_LOWERCASE

    MOV BL, upperCount
    INC BL
    MOV upperCount, BL
    JMP NEXT_CHAR

CHECK_LOWERCASE:
    CMP AL, 'a'
    JB COUNT_SPECIAL
    CMP AL, 'z'
    JA COUNT_SPECIAL

    MOV BL, lowerCount
    INC BL
    MOV lowerCount, BL
    JMP NEXT_CHAR

COUNT_SPECIAL:
    MOV BL, specialCount
    INC BL
    MOV specialCount, BL

NEXT_CHAR:
    INC SI
    DEC CX
    JMP COUNT_LOOP  
    
DONE_COUNTING: 

; Check if digitCount is zero
MOV AL, digitCount
CMP AL, 0
JNE CHECK_UPPER_MSG
LEA DX, addDigitsMsg
MOV AH, 09H
INT 21H

CHECK_UPPER_MSG:
MOV AL, upperCount
CMP AL, 0
JNE CHECK_LOWER_MSG
LEA DX, addUpperMsg
MOV AH, 09H
INT 21H

CHECK_LOWER_MSG:
MOV AL, lowerCount
CMP AL, 0
JNE CHECK_SPECIAL_MSG
LEA DX, addLowerMsg
MOV AH, 09H
INT 21H

CHECK_SPECIAL_MSG:
MOV AL, specialCount
CMP AL, 0
JNE AFTER_SPECIAL_CHECK
LEA DX, addSpecialMsg
MOV AH, 09H
INT 21H

AFTER_SPECIAL_CHECK:
; continue with sequence checking code

; === Initialize flags ===
MOV sequence1, 0
MOV sequence2, 0

; === Set SI to password buffer, CX = password length
MOV SI, OFFSET passwordInput + 2
MOV CL, [passwordInput + 1]
MOV CH, 0

; If less than 3 characters, skip check
CMP CX, 3
JB AFTER_SEQ_CHECK

SEQ_LOOP:
    ; Load current, next, and next+1 characters
    MOV AL, [SI]         ; char1
    MOV AH, [SI + 1]     ; char2
    MOV DL, [SI + 2]     ; char3

    ; Check for sequential pattern ('abc' or '123')
    MOV BL, AL
    INC BL
    CMP AH, BL
    JNE CHECK_REPEAT

    INC BL
    CMP DL, BL
    JNE CHECK_REPEAT

    ; If matched, set sequence1 = 1
    MOV sequence1, 1
    JMP CHECK_BOTH

CHECK_REPEAT:
    ; Check for repeated characters ('aaa')
    CMP AL, AH
    JNE CHECK_BOTH
    CMP AL, DL
    JNE CHECK_BOTH

    ; If matched, set sequence2 = 1
    MOV sequence2, 1

CHECK_BOTH:
    ; Check if both flags are 1, then break
    MOV AL, sequence1
    CMP AL, 1
    JNE CONT_SEQ

    MOV AL, sequence2
    CMP AL, 1
    JE AFTER_SEQ_CHECK

CONT_SEQ:
    INC SI
    DEC CX
    CMP CX, 2
    JAE SEQ_LOOP

AFTER_SEQ_CHECK: 

; Check sequence flags
MOV AL, sequence1
CMP AL, 0
JE CHECK_SEQ2_MSG

LEA DX, removeSeqMsg
MOV AH, 09H
INT 21H

CHECK_SEQ2_MSG:
MOV AL, sequence2
CMP AL, 0
JE CONTINUE_AFTER_SEQ_MSG

LEA DX, removeSeqMsg
MOV AH, 09H
INT 21H

CONTINUE_AFTER_SEQ_MSG:


; password strength score (0-7)

MOV AL, 0
MOV passwordstr, AL      ; initialize score to 0

; Length scoring
MOV AL, [passwordInput + 1]
CMP AL, 12
JB LEN_CHECK_8
; length >= 12
MOV AL, passwordstr
ADD AL, 2
MOV passwordstr, AL
JMP LEN_DONE

LEN_CHECK_8:
CMP AL, 8
JB LEN_DONE
MOV AL, passwordstr
ADD AL, 1
MOV passwordstr, AL

LEN_DONE:

; Digit count scoring
MOV AL, digitCount
CMP AL, 3
JB DIGIT_CHECK_1
MOV BL, passwordstr
ADD BL, 2
MOV passwordstr, BL
JMP DIGIT_DONE

DIGIT_CHECK_1:
CMP AL, 1
JB DIGIT_DONE
MOV BL, passwordstr
INC BL
MOV passwordstr, BL

DIGIT_DONE:

; Case diversity scoring (both upper and lower > 0)
MOV AL, upperCount
CMP AL, 0
JE CASE_DONE
MOV AL, lowerCount
CMP AL, 0
JE CASE_DONE

MOV BL, passwordstr
INC BL
MOV passwordstr, BL

CASE_DONE:

; Special character scoring
MOV AL, specialCount
CMP AL, 3
JB SPEC_CHECK_1
MOV BL, passwordstr
ADD BL, 2
MOV passwordstr, BL
JMP SPEC_DONE

SPEC_CHECK_1:
CMP AL, 1
JB SPEC_DONE
MOV BL, passwordstr
INC BL
MOV passwordstr, BL

SPEC_DONE:

; Subtract penalties for sequences
MOV AL, sequence1
CMP AL, 1
JNE NO_SEQ1_PENALTY
MOV BL, passwordstr
SUB BL, 2
JC SET_ZERO_SEQ1
MOV passwordstr, BL
JMP NO_SEQ1_PENALTY

SET_ZERO_SEQ1:
MOV passwordstr, 0

NO_SEQ1_PENALTY:

MOV AL, sequence2
CMP AL, 1
JNE NO_SEQ2_PENALTY
MOV BL, passwordstr
SUB BL, 2
JC SET_ZERO_SEQ2
MOV passwordstr, BL
JMP NO_SEQ2_PENALTY

SET_ZERO_SEQ2:
MOV passwordstr, 0

NO_SEQ2_PENALTY:

; Clamp max score to 7
MOV AL, passwordstr
CMP AL, 7
JBE SCORE_OK
MOV passwordstr, 7

SCORE_OK:

JMP DISPLAY_STRENGTH        

; Display password strength message based on passwordstr

DISPLAY_STRENGTH:

MOV AL, passwordstr

CMP AL, 0
JE VERY_WEAK
CMP AL, 1
JE VERY_WEAK
CMP AL, 2
JE WEAK_PW
CMP AL, 3
JE WEAK_PW
CMP AL, 4
JE MODERATE_PW
CMP AL, 5
JE STRONG_PW
CMP AL, 6
JE STRONG_PW
CMP AL, 7
JE VERY_STRONG

JMP EXIT

VERY_WEAK:
    LEA DX, newline
    MOV AH, 09H
    INT 21H

    LEA DX, vweak
    MOV AH, 09H
    INT 21H
    JMP EXIT

WEAK_PW:
    LEA DX, newline
    MOV AH, 09H
    INT 21H

    LEA DX, weak
    MOV AH, 09H
    INT 21H
    JMP EXIT

MODERATE_PW:
    LEA DX, newline
    MOV AH, 09H
    INT 21H

    LEA DX, moderate
    MOV AH, 09H
    INT 21H
    JMP EXIT

STRONG_PW:
    LEA DX, newline
    MOV AH, 09H
    INT 21H

    LEA DX, strong
    MOV AH, 09H
    INT 21H
    JMP EXIT

VERY_STRONG:
    LEA DX, newline
    MOV AH, 09H
    INT 21H

    LEA DX, vstrong
    MOV AH, 09H
    INT 21H
    JMP EXIT



; Exit program
EXIT:
    MOV AX,4C00H
    INT 21H

MAIN ENDP
END MAIN



