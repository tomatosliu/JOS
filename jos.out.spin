+ ld obj/kern/kernel
+ mk obj/kern/kernel.img
Could not open option rom 'sgabios.bin': No such file or directory
6828 decimal is 15254 octal!
Physical memory: 66556K available, base = 640K, extended = 65532K
check_page_free_list() succeeded!
check_page_alloc() succeeded!
check_page() succeeded!
check_kern_pgdir() succeeded!
check_page_free_list() succeeded!
check_page_installed_pgdir() succeeded!
SMP: CPU 0 found 1 CPU(s)
enabled interrupts: 1 2
[00000000] new env 00001000
**Start transfering
SYSTEM CALL!
SYS_getenvid
**Start transfering
SYSTEM CALL!
SYS_cputs
Check for user memory!

user_mem_check success va: eebfde88, len: 27
I am the parent.  Forking the child...
**Start transfering
SYSTEM CALL!
SYS_getenvid
**Start transfering
SYSTEM CALL!
SYS_cputs
Check for user memory!

user_mem_check success va: eebfde38, len: 35
[00001000] user panic in <unknown> at lib/fork.c:82: **Start transfering
SYSTEM CALL!
SYS_cputs
Check for user memory!

user_mem_check success va: eebfde58, len: 14
fork not implemented**Start transfering
SYSTEM CALL!
SYS_cputs
Check for user memory!

user_mem_check success va: eebfde38, len: 1

**Start transfering
BREAK POINT!
TRAP frame at 0xf028a000 from CPU 0
  edi  0x00000000
  esi  0xeebfdfa4
  ebp  0xeebfdf90
  oesp 0xefffffdc
  ebx  0x00801476
  edx  0xeebfde38
  ecx  0x00000001
  eax  0x00000001
  es   0x----0023
  ds   0x----0023
  trap 0x00000003 Breakpoint
  err  0x00000000
  eip  0x0080111c
  cs   0x----001b
  flag 0x00000092
  esp  0xeebfdf68
  ss   0x----0023
Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.
TRAP frame at 0xf028a000 from CPU 0
  edi  0x00000000
  esi  0xeebfdfa4
  ebp  0xeebfdf90
  oesp 0xefffffdc
  ebx  0x00801476
  edx  0xeebfde38
  ecx  0x00000001
  eax  0x00000001
  es   0x----0023
  ds   0x----0023
  trap 0x00000003 Breakpoint
  err  0x00000000
  eip  0x0080111c
  cs   0x----001b
  flag 0x00000092
  esp  0xeebfdf68
  ss   0x----0023
Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.

QEMU: Terminated via GDBstub
