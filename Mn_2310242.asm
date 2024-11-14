#Chuong trinh: Chuyen doi he so
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
	
	andi $a0, $a0,  0x7FFFFFFF # Bo dau $a0

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
	la $a0, filename
	addi $v0, $zero, 13
	addi $a1, $zero, 1 # Che do ghi
	add $a2, $zero, $zero # Quyen truy cap mac dinh
	syscall
	
	#Kiem tra loi
	move $s0, $v0
	bgez $s0, successOpenFile # Neu $v0 co gia tri >= 0 thi bao mo file thanh cong
	bltz $s0, errorOpenFile # Neu $v0 co gia tri am thi bao loi
		
 #Xuat ket qua (syscall)	
xuatKetQua:	
	# Convert ve he nhi phan
	move $a0, $s1
	jal intToBinary
	
	# Viet ket qua he nhi phan
	jal binToFile
	
	# Convert ve he thap phan
	move $a0, $s1
	jal intToDec
	
	#Viet ket qua he thap phan
	jal decToFile
	
	# Convert ve he thap luc phan
	move $a0, $s1
	jal intToHex
	
	#Viet ket qua he thap luc phan
	jal hexToFile
	
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
    			
intToBinary: 
	li $t1, 16 # So bit can chuyen
	la $t2, buffer2 # Dia chi cua buffer2
	
	binLoop:
		beqz $t1, endBinLoop # Viet het 16 chu so thi dung
		
		srl $t3, $a0, 15 # lay bit co y nghia nhat
		andi $t3, $t3, 1 # dam bao chi co bit 0 hoac 1
		addi $t3, $t3, 48 # Chuyen sang ascii
		sb $t3, 0 ($t2) 
		
		addi $t2, $t2, 1 # Di chuyen con tro buffer sang phai
		sll $a0, $a0, 1 # Dich phai so trong $a0 de xu ly bit tiep theo
		
		addi $t1, $t1, -1 # Giam so luong bit xu ly
		j binLoop
		
	endBinLoop:
		sb $zero, 0($t2)
		jr  $ra
	
binToFile: 
	move $a0, $s0
	
	 la $a1, result2 # Ghi chuoi result2 vao file
	 addi $a2, $zero, 18 
	 li $v0, 15
	 syscall
	 
	 la $a1, buffer2 # Ghi buffer 2 vao file
	 addi $a2, $zero, 16
	 li $v0, 15
	 syscall
	 
	 la $a1, newline
	 addi $a2, $zero, 1
	 li $v0, 15
	 syscall
	 
	 jr $ra
	 
intToDec:	 
	li $t1, 5 # 5 chu so
	la $t2, buffer10 # Dia chi cua buffer10
	addi $t2, $t2, 4 # Chinh ve vi tri cuoi cua buffer
	
	decLoop: # Lay chu so cuoi cung 
		li $t3, 10
		divu $a0, $t3 # Chia so cho 10
		mfhi $t4 # Lay phan du (la chu so cuoi cung)
		
		#Chuyen doi ve ASCII
		addi $t4, $t4, 48
		sb $t4, 0($t2) # luu vao buffer
		addi $t2, $t2, -1 # Di chuyen ve truoc 1 vi tri
		
		mflo $a0 # Lay thuong roi chia tiep
		
		subi $t1, $t1, 1 
		bgtz $a0, decLoop # lap lai neu thuong con > 0
		
		# Neu so co it hon 5 chu so thi dien so 0 vao truoc
	fillZeros:
		li $t5, 48 # ASCII '0'
		blez $t1, endDecLoop #Dung neu du 5 ky tu
		sb $t5, 0 ($t2)	# Them '0' vao buffer
		addi $t2, $t2, -1 # Di chuyen ve truoc 1 don vi
		subi $t1, $t1, 1
		j fillZeros
		
	endDecLoop:
		addi $t2, $t2, 5	# quay ve dau buffer roi them ky tu '\0'
		sb $zero, 5($t2) 
		jr $ra	

decToFile: 
	move $a0, $s0
	
	 la $a1, result10 # Ghi chuoi result2 vao file
	 addi $a2, $zero, 19 
	 li $v0, 15
	 syscall
	 
	 la $a1, buffer10 # Ghi buffer 2 vao file
	 addi $a2, $zero, 5
	 li $v0, 15
	 syscall
	 
	  la $a1, newline
	 addi $a2, $zero, 1
	 li $v0, 15
	 syscall
	 
	 jr $ra
	 
intToHex:
 	li $t1, 4               # So bit can chuyen
    	la $t2, buffer16         # Dia chi cua buffer16
    	addi $t2, $t2, 3         # Chinh ve vi tri cuoi cua buffer

	hexLoop:
    		li $t3, 16              # Chia cho 16 
    		divu $a0, $t3           # Chia so trong $a0 cho 16, ket qua trong $lo
    		mfhi $t4                # Lay du (phan du là gia tri hex digit)
    
    		li $t5, 10              # Neu gia tri nho hon 10, chuyen thành '0' - '9'
    		blt $t4, $t5, hexDigit  # Neu gia tri nho hon 10, chuyen thành ký tu so

    		addi $t4, $t4, 55       # Neu lon hon hoac bang 10, chuyen thanh 'A' - 'F'
    		j storeHex               # Luu vao buffer

	hexDigit:
    		addi $t4, $t4, 48       # Neu gia tri < 10, chuyen thanh '0' - '9' (ASCII '0' là 48)

	storeHex:
    		sb $t4, 0($t2)          # Luu gia tri hex vao buffer
    		addi $t2, $t2, -1        # Di chuyen sang trái de luu tiep ký tu hex

    		mflo $a0                # Lay thuong tu phep chia 
    
    		subi $t1, $t1, 1        # Giam so lan lap
    		bgtz $t1, hexLoop       # Tiep tuc neu van con bit

    		addi $t2, $t2, 4        # quay ve dau buffer roi them ky tu '\0'
    		sb $zero, 4($t2)       

    		jr $ra                  # Quay lai
		
hexToFile: 
	move $a0, $s0
	
	 la $a1, result16 # Ghi chuoi result16 vao file
	 addi $a2, $zero, 19 
	 li $v0, 15
	 syscall
	 
	 la $a1, buffer16 # Ghi buffer16 vao file
	 addi $a2, $zero, 4
	 li $v0, 15
	 syscall
	 
	  la $a1, newline
	 addi $a2, $zero, 1
	 li $v0, 15
	 syscall
	 
	 jr $ra
