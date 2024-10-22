[org 0x7c00]
[bits 16]

jmp boot
nop

bpbOEMLabel            : db "LOADER"
bpbBytesPerSector      : dw 512
bpbSectorsPerCluster   : db 1
bpbReservedSectors     : dw (loader_end - loader_start) / 512 + 1
bpbNumberOfFats        : db 2
bpbRootDirEntries      : dw 224
bpbLogicalSectors      : dw 2880
bpbMediaDescriptorType : db 0xF0
bpbSectorsPerTable     : dw 9
bpbSectorsPerTrack     : dw 18
bpbHeadsPerCylinder    : dw 2
bpbHiddenSectors       : dd 1
bpbLargeSectors        : dd 0
bpbDriveNumber         : db 5
bpbNTReserved          : db 0
bpbSignature           : db 0x29
bpbVolumeID            : dd 42
bpbVolumeLabel         : db "DOSNIX"
bpbFileSystem          : db "FAT12   "

boot:
	mov [bpbDriveNumber], dl
	cli                                                                       
	mov ax, cs                                                                
	mov ds, ax                                                                
	                                                                          
	push 0x07c0                                                               
	pop sp                                                                    
	xor ax, ax                                                                
	mov ss, ax                                                                
	sti

	mov cx, [bpbReservedSectors]
    	dec cx                         
   	push 0x7c0                    
    	pop es                       
    	mov bx, 512                 
    	mov ax, 1                                                                   

	call read_loader
	jc halt

	jmp loader_start

	jmp halt
	
read_loader:
	pusha
	mov di, 5
.read_loop0:
	push ax
	push bx
	push cx
.LBAtoCHS:	                                                                 
	xor dx, dx                                                                
	div WORD [bpbSectorsPerTrack]                                             
	inc dl                                                                    
	mov BYTE [lbachs_absoluteSector], dl                                      
	                                                                          
	xor dx, dx                                                                
	div WORD [bpbHeadsPerCylinder]                                            
	mov BYTE [lbachs_absoluteHead], dl                                        
	mov BYTE [lbachs_absoluteTrack], al                                       
.read_loop1:
	mov ah, 2                                                                 
	mov al, 1                                                                 
	mov ch, BYTE [lbachs_absoluteTrack]                                       
	mov cl, BYTE [lbachs_absoluteSector]                                      
	mov dh, BYTE [lbachs_absoluteHead]                                        
	mov dl, BYTE [bpbDriveNumber]                                             

	push dx                                                                   
	int 0x13                                                              
	pop dx                                                                    

	jnc .end                                                                  
	                                                                          
.reset_disk:
	push ax                                                                   
	xor ax, ax                                                                
	int 0x13                                                              
	pop ax                                                                    
.read_loop2:
	dec di                                                                    
	                                                                          
	pop cx                                                                    
	pop bx                                                                    
	pop ax                                                                    
	                                                                          
	pop cx                                                                    

	loop .read_loop0                                                                
	                                                                          
	stc
.end:	                                                                     
	pop cx                                                                    
	pop bx                                                                    
	pop ax                                                                    
	popa                                                                      
	ret                                                                       

lbachs_absoluteTrack db 0	                                                 
lbachs_absoluteSector db 0	                                                
lbachs_absoluteHead db 0	                                                  

halt:	                                                                     
	cli                                                                       
	hlt                                                                       
	jmp halt                                                                  

times 510 - ($ - $$) db 0	                                                 
dw 0xAA55	                                                                 

loader_start:
incbin "loader.bin"
loader_end:
