# program that reads two integers and an operator and displays results
        # Start .text segment (program code)
    .text

    .globl  main
main:
    # Prompt for 1st integer
    li  $v0,4       # print_string syscall code = 4
    la  $a0, msg1   # load the address of msg
    syscall

    # READ input integer 1 from user and save
    li  $v0,5       # read_int syscall code = 5
    syscall
    move    $t0,$v0     # syscall results returned in $v0: move $vo=>$t0 (A)

    # Prompt for 2nd integer
    li  $v0,4       # print_string syscall code = 4
    la  $a0, msg2   # load the address of msg2
    syscall

    # READ input integer 2 from user and save
    li  $v0,5       # read_int syscall code = 5
    syscall
    move    $t1,$v0     # syscall results returned in $v0: move $vo=>$t1 (B)

    # Prompt for Operator
    li  $v0, 4      # print_string syscall code = 4
    la  $a0, msg3   # load the address of msg3
    syscall

    # READ input operator from user and save
    li  $v0, 12     # read_char syscall code = 12
    syscall
    move    $t2,$v0     # syscall results returned in $v0: move $vo=>$t2 (C)
    
    # Comparing to branch
    beq $t2, '+', addOperation
    beq $t2, '-', subOperation
    beq $t2, '*', mulOperation
    beq $t2, '/', divOperation
    beq $t2, '%', modOperation
    j err2    

    addOperation:
    # Print semantics message
    li  $v0, 4
    la  $a0, msgAdd
    syscall

    add $t3, $t0, $t1   # t3 = t0 + t1
    j result

    subOperation:
    # Print semantics message
    li  $v0, 4
    la  $a0, msgSub
    syscall

    sub $t3, $t0, $t1
    j result

    mulOperation:
    # Print semantics message
    li  $v0, 4
    la  $a0, msgMul
    syscall

    mult  $t0, $t1
    mflo  $t3
    j result

    divOperation:
    beq $t1, 0, err    
    # Print semantics message
    li  $v0, 4
    la  $a0, msgDiv
    syscall

    div     $t0, $t1
    mflo    $t3
    j result

    modOperation:
    beq $t1, 0, err
    # Print semantics message
    li  $v0, 4
    la  $a0, msgMod
    syscall

    div     $t0, $t1
    mfhi    $t3

    result:
    # Print 1st operand of result
    li  $v0,1       # print_int syscall code = 1
    move    $a0, $t0    # int to print must be loaded into $a0
    syscall

    # Print Operator symbol of result
    li  $v0, 11 # print_char syscall code = 11
    la  $a0, ($t2)
    syscall

    # Print 2nd operand of result
    li  $v0,1       # print_int syscall code = 1
    move    $a0, $t1    # int to print must be loaded into $a0
    syscall

    # Print equal sign
    li  $v0, 4  # print_string syscall code = 4
    la  $a0, equal
    syscall

    # Print result
    li  $v0,1       # print_int syscall code = 1
    move    $a0, $t3    # int to print must be loaded into $a0
    syscall
    j end
        
    err:
    # Print div by zero error    
    li  $v0, 4
    la  $a0, msgErr1
    syscall
    j end
    
    err2:
    # Print wrong op error    
    li  $v0, 4
    la  $a0, msgErr2
    syscall    

    end:
    # Exit
    li  $v0,10      # exit call
    syscall

    # Start .data segment (data!)
    .data
    
msg1:   .asciiz "Enter the 1st integer: "
msg2:   .asciiz "Enter the 2nd integer: "
msg3:   .asciiz "Enter an operator: "
msgAdd:  .asciiz "\nThe semantics of the operator + is addition\n"
msgSub:  .asciiz "\nThe semantics of the operator - is subtraction\n"
msgMul:  .asciiz "\nThe semantics of the operator * is multiplication \n"
msgDiv:  .asciiz "\nThe semantics of the operator / is division \n"
msgMod:  .asciiz "\nThe semantics of the operator % is modulus \n"
msgErr1:  .asciiz "\nError - Division/Modulus by zero is not allowed"
msgErr2:  .asciiz "\nError - Invalid Operator!!"

equal:  .asciiz " = "
#newline:   .asciiz  "\n"
