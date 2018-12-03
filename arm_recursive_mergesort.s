/* arm_recursive_mergesort.s */

/* DATA SECTION */
.data
.balign 4
   string:  .asciz "\n A[%d] = : %d"   // define data format to print out the array
.balign 4
   string1: .asciz "\n l= %d,r=%d"     // define format to print out l and r 
.balign 4
   A:       .skip 512 @128*4
.balign 4
   L:       .skip 256 @left half the array
.balign 4
   R:       .skip 256 @right half the array
.balign 4
   N:  .word 128

/* CODE SECTION */
.text
.balign 4
.global main
.extern printf
.extern rand

    @; Merges two subarrays of arr[]. 
    @; First subarray is arr[l..m] 
    @; Second subarray is arr[m+1..r]   
    @; void merge(int arr[], int l, int m, int r){
merge: push  {r0,r1,r2,r3,LR}     //save the state before entering method call
               
       push  {r5,r6,r7,r8,r9} // save regs state to restore later
    @; int i, j, k;
    /* This section requests labels for r5-r9*/
       i     .req r5
       j     .req r6
       k     .req r7
       n1    .req r8
       n2    .req r9
    
       push  {r2} //save m
    @; int n1 = m - l + 1;
       sub   r2,r2,r1       // r2 = r2-r1 = m-l 
       add   n1,r2,#1       // n1 = m-l+1
       
       pop   {r2} //restore m
    
    @; int n2 = r - m; 
       sub   n2,r3,r2       // n2 = r3-r2 = r-m

    @; /* create temp arrays */
    @; int L[n1], R[n2];
    /* Arrays were created in data section */
    
       push  {r0,r1,r2,r3}                
    @; /* Copy data to temp arrays L[] and R[] */
    @; for (i = 0; i < n1; i++)
       mov   i,#0                  // i = 0;
  forL:cmp   i,n1                  // i < n1?
       bge   forLend               // end loop if false
    @; L[i] = arr[l + i];
       add   r2,r1,i               // r2 becomes r1 + 1, r2 = l + i
       ldr   r3,[r0,r2,lsl #2]     // r3 = *&A[(l+i)*4] = arr[l+i]
       ldr   r2,=L                 // load &L into r2
       str   r3,[r2,i,lsl #2]      // store arr[l+i] in L[i]
       add   i,i,#1                // i++
       b     forL
forLend:
       pop   {r0,r1,r2,r3}            

       push  {r0,r1,r2,r3}       
    @; for (j = 0; j < n2; j++) 
       mov   j,#0                  // j = 0;
  forR:cmp   j,n2                  // j < n2?
       bge   forRend               // end loop if false
    @; R[j] = arr[m + 1 + j]; 
       add   r1,r2,#1              // m is in r2, so r1 becomes r2+1 which is m+1
       add   r1,r1,j               // m+1 is in r1, r1 becomes m+1+j
       ldr   r3,[r0,r1,lsl #2]     // load r3 with *[base&A + (m+1+j)*4] aka arr[m+1+j]
       ldr   r1,=R                 // load &R into r1
       str   r3,[r1,j,lsl #2]      // store arr[m+1+j] in R[j], R[j] = arr[m + 1 + j]; 
       add   j,j,#1                // j++
       b     forR
forRend:      
       pop   {r0,r1,r2,r3}             

    @; /* Merge the temp arrays back into arr[l..r]*/
    @; i = 0; // Initial index of first subarray
        mov i,#0
    
    @; j = 0; // Initial index of second subarray 
        mov j,#0
    
    @; k = l; // Initial index of merged subarray 
        mov k,r1
 
     @; while (i < n1 && j < n2){
        push   {r1,r2,r3,r4}
while1: cmp    i,n1                  // while i < n1 and...
        bge    endWhile1             // end loop if above statement is false
        cmp    j,n2                  // ... j < n2
        bge    endWhile1             // end loop if above statement is false
        ldr    r1,=L                 // load r1 with base &L
        ldr    r2,[r1,i,lsl #2]      // load r2 with *&L[i*4] (cause of 4 byte alignment)
        ldr    r1,=R                 // load r1 with base &R
        ldr    r3,[r1,j,lsl #2]      // load r3 with *&R[j*4] (cause of 4 byte alignment)
     
     /* after last instruction r2 holds L[i], r3 holds R[j] */
     
     /* base address of A should still be in r0 */     
     
     @; if (L[i] <= R[j]){
     /* conditional assignment r2 = (L[i] <= R[j]) ? r9:r10 is more efficient */
        cmp    r2,r3                 // if (L[i] <= R[j])
        movgt  r2,r3                 // r2 is L[i] or R[j] conditionally
     @;     arr[k] = L[i]; 
        str    r2,[r0,k,lsl #2]      // store r2 in &A[k*4], A[k] = L[i] or R[j]
     @;     i++; 
        addle  i,i,#1                // if r9 is L[i], i++
     @; } 
     @; else { 
     @;     arr[k] = R[j]; 
     @;     j++; 
        addgt  j,j,#1                // if r9 is R[j], j++ 
     @; } 
     @; k++; 
        add    k,k,#1                // k++
        b      while1                // go to the start of the loop
endWhile1:
     @; }
      
     @; /* Copy the remaining elements of L[], if there are any */
     @; while (i < n1){ 
while2: cmp    i,n1
        bge    while2end
     @;     arr[k] = L[i]; 
        ldr    r1,=L
        ldr    r2,[r1,i,lsl #2]
        str    r2,[r0,k,lsl #2]
     @;     i++; 
        add    i,i,#1
     @;     k++; 
        add    k,k,#1
        b      while2
     @; }
while2end:   
     
     @; /* Copy the remaining elements of R[], if there are any */
     @; while (j < n2){ 
while3: cmp    j,n2
        bge    while3end
     @;     arr[k] = R[j]; 
        ldr    r1,=R
        ldr    r2,[r1,j,lsl #2]
        str    r2,[r0,k,lsl #2]
     @;     j++; 
        add    j,j,#1
     @;     k++; 
        add    k,k,#1
        b      while3
     @; } 
while3end:
        pop    {r1,r2,r3,r4}
        
        pop    {r5,r6,r7,r8,r9}

     /*var ref guide
    @  r0=arr @ r1=l @ r2=m @ r3=r
       i     .req r5
       j     .req r6
       k     .req r7
       n1    .req r8
       n2    .req r9
     */

mergeEnd:
         pop  {r0,r1,r2,r3,PC}
@; }

        @; mergeSort(int arr[], int l, int r) {
mergeSort: push  {r0,r1,r2,LR}     //save the state before entering recursive call
       
           push  {r0,r1,r2}        // save r0-r2 before call to print
           ldr   r0,=string1       // load format
            bl   printf            // print the values
           pop   {r0,r1,r2}        // return r0-r2 to their prev state
       
        @; if (l < r) {
           cmp   r1,r2             // is l less than r?
           bge   mergeSortEnd      // if so end mergesort
        
           push  {r1,r2}           // save L and R
           
        @; int m = l+(r-l)/2;      // Same as (l+r)/2, but avoids overflow for large l and h */
           sub   r2,r2,r1          // r2 = r-l 
           lsr   r2,r2,#1          // r2 = (r-l)/2
           add   r2,r2,r1          // r2 = l+(r-l)/2 = m
           push  {r2}              // save m
         
        /* Sort first and second halves */
        /* formal params before method call r0=arr, r1=l, r2=m */
        @; mergeSort(arr, l, m); Remember l is R1, R2 is r=m
             bl  mergeSort
            
        /* setting params for method call */
           pop   {r3}          // put m into r3 to use in m+1 operation
           pop   {r1,r2}       // restore l and r, r1=l and r2=r
           push  {r1,r2}       // save r1 and r2 once again
           push  {r3}          // save m 
           add   r1,r3,#1      // r1 = m+1           
        
        /* formal params before method call r0=arr, r1=m+1, r2=r */       
        @; mergeSort(arr, m+1, r);
            bl   mergeSort
           
        /* setting params for method call */   
           pop   {r3}          // restore r3, r3 = m 
           pop   {r1,r2}       // restore r1 and r2, r1=l,r2=r
           push  {r2}          // save r 
           mov   r2,r3         // r2 = m
           pop   {r3}          // r3 = r 
        
        /* before method call regs should contain r0=arr,r1=l,r2=m,r3=r */ 
        @; merge(arr, l, m, r);
            bl   merge     
        
        @; }
       
mergeSortEnd:            
           pop {r0,r1,r2,PC}  @ notice put LR into PC to force return
        @; }

main:
    push    {ip,lr}     @ This is needed to return to the Operating System
    
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

 /* This is where the parameters for mergeSort are set */
 @; mergeSort(arr, l, r);
    ldr     r0,=A       // load &A, this is int ;arr[]
    mov     r1,#0       // r1 = 0, this is ;l
    ldr     r2,=N       // load r2 with &N
    ldr     r2,[r2]     // r2 = *&N 
    sub     r2,r2,#1    // r2 = N-1 = r
     bl     mergeSort
     
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

    mov     r0,#0

    pop     {ip, pc}    @ This is the return to the operating system
