.globl main

.data
	size: .asciiz "Array size? "
	element:  .asciiz "Enter number: "
	space: .asciiz " "
	newline: .asciiz "\n"
	xs: .asciiz "xs ="
	ys: .asciiz "ys ="
.text

main:
	# n (size of the array) is $s0
	# i (current index of the array) is $s1
	# x (the current element) is $s2
	# xs (the array itself) is $s3
	# placeholder register is $s4
	# word size (4) is $s5
	
	# read in the size of the array
	li $v0, 5
	syscall
	
	# store the array size in $s0 register
	move $s0, $v0
	
	# allocate the proper amount of space on the stack based on the size of n * 2 since we need to store both the original and sorted arrays
	li $s5, 4
	li $s4, 2
	mul $s4, $s0, $s4
	mul $s4, $s4, $s5
	sub $sp, $sp, $s2
	
	# set array index to 0
	li $s1, 0
	
array_input:
	# prompt the user to enter an element of the array
	#li $v0, 4
	#la $a0, element
	#syscall

	# read element and store it in $s2 as x
	li $v0, 5
	syscall
	move $s2, $v0

	# determine the address in memory of the word size (4) * the element index
	mul $s4, $s1, $s5
	add $s4, $sp, $s4

	# push the new element into the array at the appropriate index
	sw $s2, 0($s4)

	# increment the index stored in $s1 so that when the proper number of elements are entered, the array_input loop stops
	addi $s1, $s1, 1
	
	# loop if the desired array size has not yet been reached
	blt $s1, $s0, array_input
	
	# reset the array index to 0
	li $s1, 0

gnome_sort:	
	# determine the address in memory of the word size (4) * the element index
	mul $s4, $s1, $s5
	add $s4, $sp, $s4
	
	# get array element from memory
	lw $s2, 0($s4)
	
	# determine the address in memory of the word size (4) * the element index offset by the array length for the array to be sorted
	add $s4, $s1, $s0
	mul $s4, $s4, $s5
	add $s4, $sp, $s4
	
	# push the new element into the array  to be sorted at the appropriate index
	sw $s2, 0($s4)
	
	# increment the index stored in $s1 so that when the proper number of elements are entered, the array_input loop stops
	addi $s1, $s1, 1
	
	# loop if the desired array size has not yet been reached
	blt $s1, $s0, gnome_sort
	
	# reset index i to 0
	li $s1, 0
	move $a0, $s1


gnome_loop:	
	# $s7 and $s6 are temp registers
	# if when index is equal to n, jump to the end of the sorting loop
	beq $s1, $s0, done
	
	# if index is 0, increment index
	beq $s1, $zero, increment

	# determine the address in memory of the word size (4) * the element index
	mul $s4, $s1, $s5
	add $s4, $sp, $s4
	
	# if the current element of the sorted array is greater than or equal to the previous element of the same array, increment index
	# load current element into x
	lw $s2, 0($s4)
	
	# determine the address in memory of the word size (4) * the element index - 1
	li $s4 1
	sub $s1, $s1, $s4
	mul $s4, $s1, $s5
	add $s4, $sp, $s4
	
	# load previous element into $s7
	lw $s7, 0($s4)
	
	# fix index
	li $s4, 1
	add $s1, $s1, $s4
	
	# if current element is equal to previous element, increment index
	#beq $s2, $s7, increment
	beq $s2, $s7, increment
	
	# if current element is greater than previous element, increment index
	#bgt $s2, $s7, increment
	bgt $s2, $s7, increment
	j skip
	
	increment:
	# increment the index
	li $s4, 1
	add $s1, $s1, $s4
	j gnome_loop
	
	skip:
	j gnome_else
	
gnome_else:
	# register $s6 is temp register
	# register $s2 is current element
	# register $s7 is previous element
	# register $s1 is array index
	
	# move previous element into current position
	mul $s4, $s1, $s5
	add $s4, $sp, $s4
	sw $s7, 0($s4)
	
	# move current element to previous position
	li $s4 1
	sub $s1, $s1, $s4
	mul $s4, $s1, $s5
	add $s4, $sp, $s4
	sw $s2, 0($s4)
	
	j gnome_loop
done:

	# print xs
	li $v0, 4
	la $a0, xs
	syscall
	
	# set index to array length
	move $s6, $s0
	li $s1, 0
	
	jal print_original
	
	# set index to 0
	li $s1, 0
	li $s7, 2
	
	# print newline
	li $v0, 4
	la $a0, newline
	syscall
	
	# print ys
	li $v0, 4
	la $a0, ys
	syscall
	
	jal print_sorted
	
	# exit successfully
	li $v0, 10
	syscall
	
print_sorted:
	# register $s1 is index
	# register $s2 is current element
	# register $s4 is temp register
	
	beq $s1, $s0, finish
	
	# get current element
	mul $s4, $s1, $s5
	add $s4, $sp, $s4
	lw $s2, 0($s4)
	
	# print space
	li $v0, 4
	la $a0, space
	syscall
	
	# print element
	move $a0, $s2
	li $v0, 1
	syscall
	
	li $s4, 1
	add $s1, $s1, $s4
	
	j print_sorted
	
	finish:
	jr $ra
	
print_original:
	# register $s0 is array length
	# register $s1 is index
	# register $s2 is current element
	# register $s4 is temp register
	# register $s6 is additional temp register
	
	beq $s1, $s0, finish_original
	
	move $s4, $s6
	mul $s4, $s4, $s5
	add $s4, $sp, $s4
	lw $s2, 0($s4)
	
	# print space
	li $v0, 4
	la $a0, space
	syscall
	
	# print element
	move $a0, $s2
	li $v0, 1
	syscall
	
	li $s4, 1
	addi $s1, $s1, 1
	addi $s6, $s6, 1
	
	j print_original
	
	finish_original:
	jr $ra
	

	
	
	
	

	
        

        
	
	
	
