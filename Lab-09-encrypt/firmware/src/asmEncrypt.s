/*** asmEncrypt.s   ***/

#include <xc.h>

/* Declare the following to be in data memory */
.data  

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Amanda Earney"  
.align
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

/* Define the globals so that the C code can access them */
/* (in this lab we return the pointer, so strictly speaking, */
/* does not really need to be defined as global) */
/* .global cipherText */
.type cipherText,%gnu_unique_object

.align
 
@ NOTE: THIS .equ MUST MATCH THE #DEFINE IN main.c !!!!!
@ TODO: create a .h file that handles both C and assembly syntax for this definition
.equ CIPHER_TEXT_LEN, 200
 
/* space allocated for cipherText: 200 bytes, prefilled with 0x2A */
cipherText: .space CIPHER_TEXT_LEN,0x2A  

.align
 
.global cipherTextPtr
.type cipherTextPtr,%gnu_unique_object
cipherTextPtr: .word cipherText

/* Tell the assembler that what follows is in instruction memory     */
.text
.align

/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

    
/********************************************************************
function name: asmEncrypt
function description:
     pointerToCipherText = asmEncrypt ( ptrToInputText , key )
     
where:
     input:
     ptrToInputText: location of first character in null-terminated
                     input string. Per calling convention, passed in via r0.
     key:            shift value (K). Range 0-25. Passed in via r1.
     
     output:
     pointerToCipherText: mem location (address) of first character of
                          encrypted text. Returned in r0
     
     function description: asmEncrypt reads each character of an input
                           string, uses a shifted alphabet to encrypt it,
                           and stores the new character value in memory
                           location beginning at "cipherText". After copying
                           a character to cipherText, a pointer is incremented 
                           so that the next letter is stored in the bext byte.
                           Only encrypt characters in the range [a-zA-Z].
                           Any other characters should just be copied as-is
                           without modifications
                           Stop processing the input string when a NULL (0)
                           byte is reached. Make sure to add the NULL at the
                           end of the cipherText string.
     
     notes:
        The return value will always be the mem location defined by
        the label "cipherText".
     
     
********************************************************************/    
.global asmEncrypt
.type asmEncrypt,%function
asmEncrypt:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
    
    /* YOUR asmEncrypt CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    LDR r4, =cipherText /* each new encrypted char will be put at address in r4 */
    
loop:
    LDRB r5, [r0], 1 /* gets the current character of the input, increments after loading */
    CMP r5, 0 
    BEQ endLoop /* if the char is null, entire text has been copied */
    CMP r5, 65 
    BLO notLetter /* if less than 65, char shouldn't be shifted */
    CMP r5, 123 /* should be 123 due to HS also checking if same */
    BHS notLetter /* if greater than 122, char shouldn't be shifted */
    CMP r5, 91 /* should be 91 to include 90 in shiftable characters */
    BLO uppercase /* if less than 91 and got here, char is uppercase */
    CMP r5, 97 
    BHS lowercase /* if greater than 97 and got here, char is lowercase */
    B notLetter /* if got here, char shouldn't be shifted */
    
uppercase:
    ADD r5, r5, r1 /* adds the key to the current char */
    CMP r5, 91 /* should be 91 due to HS checking if same */
    SUBHS r5, r5, 26 /* if out of bounds, corrects the shifted char */
    STRB r5, [r4], 1 /* stores the shifted char into output, increments after loading */
    B loop /* goes through loop with next char */
    
lowercase:
    ADD r5, r5, r1 /* adds the key to the current char */
    CMP r5, 123 /* should be 123 due to HS checking if same */
    SUBHS r5, r5, 26 /* if out of bounds, corrects the shifted char */
    STRB r5, [r4], 1 /* stores the shifted char into output, increments after loading */
    B loop /* goes through loop with next char */
    
notLetter:
    STRB r5, [r4], 1 /* puts the unmodified char into the output, increments after loading */
    B loop /* goes through loop with next char */
    
endLoop:
    MOV r6, 0
    STRB r6, [r4] /* adds a null char to end of cipherText */
    LDR r0, =cipherText /* returns cipherText address in r0 */
    /* YOUR asmEncrypt CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

    /* restore the caller's registers, as required by the ARM calling convention */
    pop {r4-r11,LR}

    mov pc, lr	 /* asmEncrypt return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




