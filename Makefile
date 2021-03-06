obj-m := char_device_encoder.o #Encoder file for make
obj-m += char_device_decoder.o #Decoder file for make
all:
	make -C /lib/modules/$(shell uname -r)/build M=$(shell pwd) modules #Called to compile the modules defined over obj-m

install:
	mknod /dev/enc_device -m 666 c 240 0 #Create a character device for the encoding
	mknod /dev/dec_device -m 666 c 239 0 #Create a character device for the decoding
	make #Calls the all subroutine of make, compiling the modules
	insmod char_device_encoder.ko #Insert the encoder module
	insmod char_device_decoder.ko #Insert the decoder module

test:
	gcc userprog.c && ./a.out #Compile and run the user program

clean:
	rm a.out 2> /dev/null || echo "removed" #Remove a.out if exists else echo "removed" 
	make -C /lib/modules/$(shell uname -r)/build M=$(shell pwd) clean #Remove the compiled modules

remove:
	test -n "$(shell grep -e "^enc_device" /proc/modules)" && rmmod enc_device.ko || echo "removed" #Check if module is already loaded, if so unload it, echo removed
	test -n "$(shell grep -e "^dec_device" /proc/modules)" && rmmod dec_device.ko || echo "removed" #Check if module is already loaded, if so unload it, echo removed
	rm /dev/enc_device 2> /dev/null || echo "removed" #Check if device already exists, if so remove, echo removed
	rm /dev/dec_device 2> /dev/null || echo "removed" #Check if device already exists, if so remove, echo removed
