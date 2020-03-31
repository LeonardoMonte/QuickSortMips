.macro printArray2 (%adress,%size) # function to print the array, parameters array adress and array size
li $t0,0 
addi $t5,%size,-1
Loop2: 
slt $t1,$t0,%size 
beq $t1,$zero,endloop 
sll $t2,$t0,2  
add $t3,$t2,%adress
lw $t4,0($t3) 
li $v0,1 
move $a0,$t4
syscall

slt $t6,$t0,$t5
beq $t6,$zero,any
print_str2(",")  # formatation to put ,
addi $t0,$t0,1  
j Loop2
any:
addi $t0,$t0,1  
j Loop2

endloop:
.end_macro

.macro readArray2 (%adress,%size) # functions to get the values from the user, parameters array adress and array size

sll $t2,%size,2
move $a0,$t2
li $v0,9
syscall
move %adress,$v0

li $t0,0
read: 
slt $t1,$t0,%size
beq $t1,$zero,endread
print_str2("Digite o valor: ")
li $v0,5 
syscall 

sll $t2,$t0,2 
add $t3,$t2,$s0 

sw $v0,0($t3) 
addi $t0,$t0,1 
j read
endread:
.end_macro

.macro print_str2 (%str) # function to print a string
.data
myLabel: .asciiz %str
.text
li $v0, 4
la $a0, myLabel
syscall
.end_macro

.macro scanMessage(%msg) # function to print a string and get a int value
print_str2(%msg)
li $v0,5
syscall
.end_macro

.text 
.globl main # start

main:

scanMessage("Digite 1 para ordem crescent ou 0 para ordem decrescente: ") # value of the order of the sort
move $s5,$v0

print_str2("\n")
print_str2("Digite o tamanho do vetor: ") # geting the size of the array
li $v0,5
syscall
move $s1,$v0 # S1 is the vector size 

print_str2("\n")
readArray2($s0,$s1) # writing the array 
move $s7,$s1
move $s6,$s0
addi $t9,$s1,-1

print_str2("\nArray: \n[") # printing the array before de sort
printArray2($s6,$s7)
print_str2("]\n")

addi $a0, $s0, 0 # Set argument 1 to the array.
addi $a1, $zero, 0 # Set argument 2 to (low = 0)
add $a2, $zero, $t9 # Set argument 3 to (high = 7, last index in array)
jal quicksort # Call quick sort

beq $s5,$zero,decrescenteprint2
print_str2("\nArray em ordem crescente: \n[") # priting the array sorted ascending
printArray2($s6,$s7)
print_str2("]")
li $v0, 10 # Terminate program run and
syscall # Exit

decrescenteprint2:
print_str2("\nArray em ordem decrescente: \n[") # printing the array sorted descending
printArray2($s6,$s7)
print_str2("]")
li $v0,10
syscall

swap:				#swap method

addi $sp, $sp, -12	# Make stack room for three

sw $a0, 0($sp)		# Store a0
sw $a1, 4($sp)		# Store a1
sw $a2, 8($sp)		# store a2

sll $t1, $a1, 2 	#t1 = 4a
add $t1, $a0, $t1	#t1 = arr + 4a
lw $s3, 0($t1)		#s3  t = array[a]

sll $t9, $a2, 2		#t2 = 4b
add $t9, $a0, $t9	#t2 = arr + 4b
lw $s4, 0($t9)		#s4 = arr[b]

sw $s4, 0($t1)		#arr[a] = arr[b]
sw $s3, 0($t9)		#arr[b] = t 


addi $sp, $sp, 12	#Restoring the stack size
jr $ra			#jump back to the caller


partition: 			#partition method

addi $sp, $sp, -16	#Make room for 5

sw $a0, 0($sp)		#store a0
sw $a1, 4($sp)		#store a1
sw $a2, 8($sp)		#store a2
sw $ra, 12($sp)		#store return address

move $s1, $a1		#s1 = low
move $s2, $a2		#s2 = high

sll $t1, $s2, 2		# t1 = 4*high
add $t1, $a0, $t1	# t1 = arr + 4*high
lw $t2, 0($t1)		# t2 = arr[high] //pivot

addi $t3, $s1, -1 	#t3, i=low -1
move $t4, $s1		#t4, j=low
addi $t5, $s2, -1	#t5 = high - 1

forloop: 
slt $t6, $t5, $t4	#t6=1 if j>high-1, t7=0 if j<=high-1
bne $t6, $zero, endfor	#if t6=1 then branch to endfor

sll $t1, $t4, 2		#t1 = j*4
add $t1, $t1, $a0	#t1 = arr + 4j
lw $t7, 0($t1)		#t7 = arr[j]

beq $s5,$zero,decrescente

slt $t8, $t2, $t7	#t8 = 1 if pivot < arr[j], 0 if arr[j]<=pivot
bne $t8, $zero, endfif	#if t8=1 then branch to endfif
addi $t3, $t3, 1	#i=i+1

move $a1, $t3		#a1 = i
move $a2, $t4		#a2 = j
jal swap		#swap(arr, i, j)

addi $t4, $t4, 1	#j++
j forloop

endfif:
addi $t4, $t4, 1	#j++
j forloop		#junp back to forloop

endfor:
addi $a1, $t3, 1		#a1 = i+1
move $a2, $s2			#a2 = high
add $v0, $zero, $a1		#v0 = i+1 return (i + 1);
jal swap			#swap(arr, i + 1, high);

lw $ra, 12($sp)			#return address
addi $sp, $sp, 16		#restore the stack
jr $ra				#junp back to the caller


decrescente:

slt $t8, $t7, $t2	#t8 = 1 if pivot < arr[j], 0 if arr[j]<=pivot
bne $t8, $zero, endfif	#if t8=1 then branch to endfif
addi $t3, $t3, 1	#i=i+1

move $a1, $t3		#a1 = i
move $a2, $t4		#a2 = j
jal swap		#swap(arr, i, j)

addi $t4, $t4, 1	#j++
j forloop

quicksort:				#quicksort method

addi $sp, $sp, -16		# Make room for 4

sw $a0, 0($sp)			# a0
sw $a1, 4($sp)			# low
sw $a2, 8($sp)			# high
sw $ra, 12($sp)			# return address

move $t0, $a2			#saving high in t0

slt $t1, $a1, $t0		# t1=1 if low < high, else 0
beq $t1, $zero, endif		# if low >= high, endif

jal partition			# call partition 
move $s0, $v0			# pivot, s0= v0

lw $a1, 4($sp)			#a1 = low
addi $a2, $s0, -1		#a2 = pi -1
jal quicksort			#call quicksort

addi $a1, $s0, 1		#a1 = pi + 1
lw $a2, 8($sp)			#a2 = high
jal quicksort			#call quicksort

endif:

lw $a0, 0($sp)			#restore a0
lw $a1, 4($sp)			#restore a1
lw $a2, 8($sp)			#restore a2
lw $ra, 12($sp)			#restore return address
addi $sp, $sp, 16		#restore the stack
jr $ra