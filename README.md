# mem128k_000
We installed 128KiB S-RAM outside the Atmel ATmega162.

The circuit diagram and test program will be published here.

S-RAM is divided into 4 banks of 32KiB each, and can be mapped to 0x8000-0xffff. The first bank is partly fixedly mapped to 0x2000-0x7fff. By mapping other banks to 0x8000-, you can access up to 56KiB continuously. The first bank can be mapped to 0x8000 - at the same time, so the top 8KiB is also accessible.

These are without warranty without exception.
