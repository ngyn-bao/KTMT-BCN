#Chuong trinh: Chuyen doi he so
	.include "macro.mac"
#Data segment
	.data
#Cac dinh nghia bien
buffer2: .space 17 #Buffer cho chuoi he 2(16 ky tu + ky tu '\0')
buffer10: .space 6 #Buffer cho chuoi he 10(5 ky tu + ky tu '\0')
buffer16: .space 5 #Buffer cho chuoi he 16(4 ky tu + ky tu '\0')

#Cac cau nhac xuat du lieu
filename: .asciiz "SO_BDH.TXT"
newline: .asciiz "\n"
soN: .asciiz "So n la: "
result2: .asciiz "Ket qua he 2(B): "
result10: .asciiz "Ket qua he 10(D): "
result16: .asciiz "Ket qua he 16(H): "

#Thong bao
successMsg: .asciiz "File opened successfully!\n"
errorMsgOpen: .asciiz "Error: Cannot open file.\n"

#Code segment
	.text
	
# -------------------------------	
# BEGIN
# -------------------------------
main:	
#Nhap (syscall)
	#Lay time
	addi $v0, $zero, 30
	syscall
	
	andi $a0, $a0,  0x7FFFFFFF #Bo dau $a0

	#Dung time lam seed
	addi $v0, $zero, 40
	move $a1, $a0
	move $a0, $zero
	syscall
	
#Xu ly
	#Tao so ngau nhien 0 < n < 65536
	addi $v0, $zero, 42
	addi $a1, $zero, 65536
	syscall

	move $s1, $a0  # Luu so n vao bien de su dung sau
		
	#In so N
	addi $v0, $zero, 4
	la $a0, soN
	syscall 
			
	addi $v0, $zero, 1
	move $a0, $s1
	syscall 	
	
	#Mo tap tin de ghi
	addi $v0, $zero, 13
	la $a0, filename
	addi $a1, $zero, 1 # Che do ghi
	add $a2, $zero, $zero # Quyen truy cap mac dinh
	syscall
	
	#Kiem tra loi
	move $s0, $v0
	bgez $s0, successOpenFile # Neu $v0 co gia tri >= 0 thi bao mo file thanh cong
	bltz $s0, errorOpenFile # Neu $v0 co gia tri am thi bao loi
	
	
 #Xuat ket qua (syscall)	
xuatKetQua:	
	# Ghi ket qua nhi phan
	la $a1, buffer2
	convertToBinary $s1, buffer2
	writeFile $s0, result2, 20
	writeFile $s0, buffer2, 16
	printNewLine $s0
	
	# Ghi ket qua thap phan
	la $a1, buffer10
	convertToDecimal $s1, buffer10
	writeFile $s0, result10, 20
	writeFile $s0, buffer10, 5
	printNewLine $s0
	
	# Ghi ket qua he thap luc phan
	la $a1, buffer16
	convertToHex $s1, buffer16
	writeFile $s0, result16, 20
	writeFile $s0, buffer16, 4
	printNewLine $s0
	
	
	# Dong tap tin
	closeFile:
	addi $v0, $zero, 16
	move $a0, $s0
	syscall

#ket thuc chuong trinh (syscall)
Kthuc:	addi	$v0,$zero,10
		syscall

# -------------------------------	
# END
# -------------------------------

# -------------------------------	
# Cac chuong trinh khac
# -------------------------------
# Thong bao mo file thanh cong
successOpenFile:   addi $v0, $zero, 4
			la $a0, newline
			syscall
    			la $a0, successMsg
    			syscall
    			j xuatKetQua

# Thong bao loi
errorOpenFile:   addi $v0, $zero, 4
    			la $a0, errorMsgOpen
    			syscall
    			j Kthuc	