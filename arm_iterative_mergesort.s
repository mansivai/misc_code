/* arm_iterative_mergesort.s */
.data
.balign 4
   string:  .asciz "\n A[%d] = : %d"   // define data format to print out the array
.balign 4                            
   string2: .asciz "\n k= %d,left=%d"  // define data format to print k and left
.balign 4
   A:       .skip 512 @128*4           // define array A
.balign 4
   B:       .skip 512 @128*4           // define array B
.balign 4                              
   N:  .word 3                         // define constant N (num), the number of elements

/* CODE SECTION */
.text
.balign 4
.global main
.extern printf
.extern rand

main:
    push  {ip,lr}        // This is needed to return to the Operating System

@@@@@@@@@@@@@@@@ ARRAY LOOP @@@@@@@@@@@@@@@@
/* this section creates an array of size N */
    mov  r5,#0           // move 0 into register 5, similar to int i = 0;
    ldr  r4,=A           // load r4 with &A
loop1:
    ldr  r0,=N           // load r0 with &N, this address stores the constant N
    ldr  r0,[r0]         // load r0 with *&N, the actual value of N defined in data section  
    cmp  r5, r0          // compare the values in r5 and r0, similar to i < n
    bge  end1            // if r5 >= r0, goto end1 label to end the loop. The loop has reached N iterations.
     bl  rand            // else, continue. Call funct. random to generate random number.
    and  r0,r0,#255      // AND the result with 255 to produce a random number b/w 0 and 255.
    str  r0,[r4],#4      // Store current contents of r0 at &A, then update the address in r4 by 4 bytes. r4 = &A+4
    add  r5,r5,#1        // add 1 to r5, similar to i++
    b    loop1           // return to the start of the loop
end1:
@@@@@@@@@@@@@@@@ PRINT LOOP @@@@@@@@@@@@@@@@
/* this section prints all the elements in an array of size N */
    mov  r5,#0           // int i = 0; once again r5 is used as i
    ldr  r4,=A           // load r4 with &A.
loop2:
    ldr  r0,=N           // load r0 with &N, this address holds the value of the constant N
    ldr  r0,[r0]         // load r0 with *&N, the actual value of N defined in data section
    cmp  r5, r0          // has the loop reached N iterations?, i < n
    beq  end2            // if yes, goto end2 label to end the loop.
    ldr  r0,=string      // else load r0 with &string. string contains the format of our output.
    mov  r1,r5           // r1 equals r5
    ldr  r2,[r4],#4      // load r2 with *&A then point to the next element. r4 = &A+4
     bl  printf          // r0, r1, and r2 are printed to the console according to specified format in string
    add  r5, r5, #1      // i++
    b    loop2           // return to the start of the loop
end2:

/* Here begins the execution of the iterative mergesort */
@@@@@@@@@@@@@@@@ OUTER LOOP @@@@@@@@@@@@@@@@
/* this section defines the 2 outer for loops of the iterative MergeSort */

     /* This section requests labels for r0-r2 */
        left  .req r2         // left is r2
        k     .req r1         // k    is r1
        num   .req r0         // num  is r0

      @ for (int k=1; k < num; k *= 2 ) {
        mov   k,#1            // k=1
OLoop1: ldr   r0,=N           // put &N into r0
        ldr   num,[r0]        // load num into r0
        cmp   k,num           // is k < num?
        bge   OLoop1e         // end this loop if false

      @ for (int left=0; left+k < num; left += k*2 ) {
        mov   left,#0         // left = 0
OLoop2: add   r3,left,k       // r3 = left+k;
        ldr   r0,=N           // put &N into r0
        ldr   num,[r0]        // load num with *&N
        cmp   r3,num          // is left+k < num?
        bge   OLoop2e         // end this loop if false

     /* print k and left to verify code operation */
        push  {r0,r1,r2,r3}   // push regs into the stack to save their current state
        ldr   r0,=string2     // load string2 into r0 to specify the the format of the output
         bl   printf          // print the values  to the console
        pop   {r0,r1,r2,r3}   // restore the prior state of regs

@@@@@@@@@@@@@@@@ INNER LOOPS @@@@@@@@@@@@@@@@
/* this section defines the 4 while loops and the for loop of the iterative MergeSort */

     /* This section requests labels for r3-r4*/
      @ rght = left + k;
        rght   .req r3        // r3 contains left+k, see line 74
        rend   .req r4        // rend is r4

      @ rend = rght + k;
        add    rend,rght,k

      @ if (rend > num) rend = num;
        cmp    rend,num       // rend < num
        movgt  rend,num       // rend = (rend>num)?num:rend;

     /* This section requests labels for r5-r7*/
        m      .req r5
        i      .req r6
        j      .req r7

      @ m = left; i = left; j = rght
        mov    m,left
        mov    i,left
        mov    j,rght

      @ while (i < rght && j < rend) {
while1: cmp    i,rght                // while i < rght and...
        bge    endWhile1             // end loop if above statement is false
        cmp    j,rend                // ... j < rend
        bge    endWhile1             // end loop if above statement is false
        ldr    r8,=A                 // load r8 with &A
        ldr    r9,[r8,i,lsl #2]      // load r9 with *&A[i*4] (cause of 4 byte alignment)
        ldr    r10,[r8,j,lsl #2]     // load r10 with *&A[j*4] (cause of 4 byte alignment)
     /* after last instruction r9 holds A[i], r10 holds A[j] */

      @ if (a[i] <= a[j]);
     /* conditional assignment r9 = (a[i] <= a[j])? r9:r10; is more efficient */
        cmp    r9,r10                // if (a[i] <= a[j])
        movgt  r9,r10                // r9 is A[i] or A[j] conditionally
        addle  i,i,#1                // if r9 is A[i], i++
        addgt  j,j,#1                // if r9 is A[j], j++

      @ b[m] = a[i]; i++; combined with...
      @ b[m] = a[j]; j++;
        ldr    r11,=B                // load &B into r11
        str    r9,[r11,r5,lsl #2]    // store r9 in &B[m*4], B[m] = A[i] or A[j]
        add    m,m,#1                // m++
        b      while1                // go to the start of the loop
endWhile1:
      @ }

      @ while (i < rght) {
while2: cmp    i,rght
        bge    while2end
      @ b[m]=a[i];
        ldr    r8,=A
        ldr    r9,[r8,i,lsl #2]
        ldr    r8,=B
        str    r9,[r8,m,lsl #2]
      @ i++; m++;
        add    i,i,#1
        add    m,m,#1
        @}
        b      while2
while2end:

      @ while (j < rend) {
while3: cmp    j,rend
        bge    while3end
      @ b[m]=a[j];
        ldr    r8,=A
        ldr    r9,[r8,j,lsl #2]
        ldr    r8,=B
        str    r9,[r8,m,lsl #2]
      @ j++; m++;
        add    j,j,#1
        add    m,m,#1
        @}
        b      while3
while3end:
@@@@@@@@@@@@@@@@ for m loop @@@@@@@@@@@@@@@@@
      @ for (m=left; m < rend; m++) {
        mov  m,left                 // m = left;
  form: cmp  m,rend                 // m < rend
        bge formend
      @ a[m] = b[m];
        ldr  r8,=B                  // load &B into r8
        ldr  r9, [r8,m,lsl #2]      // retrieve into r9 contents from B[m*4]
        ldr  r8,=A                  // load &A into r8
        str  r9, [r8,m,lsl #2]      // store *B[m*4] in A[m*4]
        add  m,m,#1                 // m++
        @}
        b    form
formend:
@@@@@@@@@@@@@@@@ UPDATE left @@@@@@@@@@@@@@@@
      @ left += k*2
        lsl  r3,k,#1        // r3 = 2k
        add  left,left,r3   // left = left + 2k
        b    OLoop2         // return to Oloop2 label

OLoop2e:
@@@@@@@@@@@@@@@@ UPDATE k @@@@@@@@@@@@@@@@@@@
      @ k*=2, r1 is k
        lsl  k,k,#1
        b    OLoop1         // return to Oloop1 label
OLoop1e:
/* this is the end of the iterative mergesort */

@@@@@@@@@@@@@@@ PRINT LOOP 2 @@@@@@@@@@@@@@@@
/* this loop prints the array which should be sorted */
      mov  r5,#0
      ldr  r4,=A
loop3:
      ldr  r0,=N
      ldr  r0,[r0]
      cmp  r5, r0
      beq  end3
      ldr  r0,=string
      mov  r1,r5
      ldr  r2,[r4],#4
       bl  printf
      add  r5,r5,#1
      b    loop3
end3:
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    mov     r0,#0

    pop     {ip, pc}    @ This is the return to the operating system
