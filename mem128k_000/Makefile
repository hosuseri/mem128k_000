TARGET = mem128k

OBJS = \
	main.o \
	exram.o

CC = avr-gcc
OBJCOPY = avr-objcopy

CFLAGS = -mmcu=atmega162 -Wa,-als
LDFLAGS = -Wl,-Map=$(TARGET).map

# avrdude settings (example)
PARTNO = m162
PORT = usb:39:34
PROGRAMMER = atmelice_isp

all: $(TARGET).mot

clean:
	rm -f $(TARGET).mot
	rm -f $(TARGET)
	rm -f $(TARGET).map
	rm -f $(OBJS)

flash: $(TARGET).mot
	avrdude -c $(PROGRAMMER) -p $(PARTNO) -P $(PORT) -e \
		-U flash:w:$(TARGET).mot

fuse:
	avrdude -c $(PROGRAMMER) -p $(PARTNO) -P $(PORT) -u \
		-U efuse:w:0xff:m \
		-U hfuse:w:0xd1:m \
		-U lfuse:w:0x9f:m

$(TARGET).mot: $(TARGET)
	$(OBJCOPY) -I elf32-avr -O srec $(TARGET) $(TARGET).mot

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(TARGET) $(OBJS)

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

exram.o: exram.S
	$(CC) $(CFLAGS) -c exram.S
