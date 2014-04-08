
obj/user/evilhello:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800049:	e8 6a 00 00 00       	call   8000b8 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800062:	e8 0d 01 00 00       	call   800174 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80006f:	c1 e0 05             	shl    $0x5,%eax
  800072:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800077:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007c:	85 f6                	test   %esi,%esi
  80007e:	7e 07                	jle    800087 <libmain+0x37>
		binaryname = argv[0];
  800080:	8b 03                	mov    (%ebx),%eax
  800082:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008b:	89 34 24             	mov    %esi,(%esp)
  80008e:	e8 a1 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800093:	e8 0c 00 00 00       	call   8000a4 <exit>
}
  800098:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009b:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009e:	89 ec                	mov    %ebp,%esp
  8000a0:	5d                   	pop    %ebp
  8000a1:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 61 00 00 00       	call   800117 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d2:	89 c3                	mov    %eax,%ebx
  8000d4:	89 c7                	mov    %eax,%edi
  8000d6:	89 c6                	mov    %eax,%esi
  8000d8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000e3:	89 ec                	mov    %ebp,%esp
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 0c             	sub    $0xc,%esp
  8000ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fb:	b8 01 00 00 00       	mov    $0x1,%eax
  800100:	89 d1                	mov    %edx,%ecx
  800102:	89 d3                	mov    %edx,%ebx
  800104:	89 d7                	mov    %edx,%edi
  800106:	89 d6                	mov    %edx,%esi
  800108:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80010d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800110:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800113:	89 ec                	mov    %ebp,%esp
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	83 ec 38             	sub    $0x38,%esp
  80011d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800120:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800123:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012b:	b8 03 00 00 00       	mov    $0x3,%eax
  800130:	8b 55 08             	mov    0x8(%ebp),%edx
  800133:	89 cb                	mov    %ecx,%ebx
  800135:	89 cf                	mov    %ecx,%edi
  800137:	89 ce                	mov    %ecx,%esi
  800139:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80013b:	85 c0                	test   %eax,%eax
  80013d:	7e 28                	jle    800167 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80013f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800143:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80014a:	00 
  80014b:	c7 44 24 08 82 10 80 	movl   $0x801082,0x8(%esp)
  800152:	00 
  800153:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80015a:	00 
  80015b:	c7 04 24 9f 10 80 00 	movl   $0x80109f,(%esp)
  800162:	e8 3d 00 00 00       	call   8001a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800167:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80016a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80016d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800170:	89 ec                	mov    %ebp,%esp
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 0c             	sub    $0xc,%esp
  80017a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80017d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800180:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800183:	ba 00 00 00 00       	mov    $0x0,%edx
  800188:	b8 02 00 00 00       	mov    $0x2,%eax
  80018d:	89 d1                	mov    %edx,%ecx
  80018f:	89 d3                	mov    %edx,%ebx
  800191:	89 d7                	mov    %edx,%edi
  800193:	89 d6                	mov    %edx,%esi
  800195:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800197:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80019a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80019d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001a0:	89 ec                	mov    %ebp,%esp
  8001a2:	5d                   	pop    %ebp
  8001a3:	c3                   	ret    

008001a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001ac:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001af:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001b5:	e8 ba ff ff ff       	call   800174 <sys_getenvid>
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	c7 04 24 b0 10 80 00 	movl   $0x8010b0,(%esp)
  8001d7:	e8 c3 00 00 00       	call   80029f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e3:	89 04 24             	mov    %eax,(%esp)
  8001e6:	e8 53 00 00 00       	call   80023e <vcprintf>
	cprintf("\n");
  8001eb:	c7 04 24 d4 10 80 00 	movl   $0x8010d4,(%esp)
  8001f2:	e8 a8 00 00 00       	call   80029f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f7:	cc                   	int3   
  8001f8:	eb fd                	jmp    8001f7 <_panic+0x53>
	...

008001fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	53                   	push   %ebx
  800200:	83 ec 14             	sub    $0x14,%esp
  800203:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800206:	8b 03                	mov    (%ebx),%eax
  800208:	8b 55 08             	mov    0x8(%ebp),%edx
  80020b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80020f:	83 c0 01             	add    $0x1,%eax
  800212:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800214:	3d ff 00 00 00       	cmp    $0xff,%eax
  800219:	75 19                	jne    800234 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80021b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800222:	00 
  800223:	8d 43 08             	lea    0x8(%ebx),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	e8 8a fe ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  80022e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800234:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800247:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024e:	00 00 00 
	b.cnt = 0;
  800251:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800258:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800262:	8b 45 08             	mov    0x8(%ebp),%eax
  800265:	89 44 24 08          	mov    %eax,0x8(%esp)
  800269:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800273:	c7 04 24 fc 01 80 00 	movl   $0x8001fc,(%esp)
  80027a:	e8 97 01 00 00       	call   800416 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800285:	89 44 24 04          	mov    %eax,0x4(%esp)
  800289:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80028f:	89 04 24             	mov    %eax,(%esp)
  800292:	e8 21 fe ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  800297:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80029d:	c9                   	leave  
  80029e:	c3                   	ret    

0080029f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8002af:	89 04 24             	mov    %eax,(%esp)
  8002b2:	e8 87 ff ff ff       	call   80023e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002b7:	c9                   	leave  
  8002b8:	c3                   	ret    
  8002b9:	00 00                	add    %al,(%eax)
	...

008002bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 3c             	sub    $0x3c,%esp
  8002c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002c8:	89 d7                	mov    %edx,%edi
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002d6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002e4:	72 11                	jb     8002f7 <printnum+0x3b>
  8002e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002e9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ec:	76 09                	jbe    8002f7 <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ee:	83 eb 01             	sub    $0x1,%ebx
  8002f1:	85 db                	test   %ebx,%ebx
  8002f3:	7f 51                	jg     800346 <printnum+0x8a>
  8002f5:	eb 5e                	jmp    800355 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f7:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002fb:	83 eb 01             	sub    $0x1,%ebx
  8002fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800302:	8b 45 10             	mov    0x10(%ebp),%eax
  800305:	89 44 24 08          	mov    %eax,0x8(%esp)
  800309:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80030d:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800311:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800318:	00 
  800319:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031c:	89 04 24             	mov    %eax,(%esp)
  80031f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800322:	89 44 24 04          	mov    %eax,0x4(%esp)
  800326:	e8 a5 0a 00 00       	call   800dd0 <__udivdi3>
  80032b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80032f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800333:	89 04 24             	mov    %eax,(%esp)
  800336:	89 54 24 04          	mov    %edx,0x4(%esp)
  80033a:	89 fa                	mov    %edi,%edx
  80033c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033f:	e8 78 ff ff ff       	call   8002bc <printnum>
  800344:	eb 0f                	jmp    800355 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800346:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034a:	89 34 24             	mov    %esi,(%esp)
  80034d:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800350:	83 eb 01             	sub    $0x1,%ebx
  800353:	75 f1                	jne    800346 <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800355:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800359:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80035d:	8b 45 10             	mov    0x10(%ebp),%eax
  800360:	89 44 24 08          	mov    %eax,0x8(%esp)
  800364:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80036b:	00 
  80036c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036f:	89 04 24             	mov    %eax,(%esp)
  800372:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800375:	89 44 24 04          	mov    %eax,0x4(%esp)
  800379:	e8 82 0b 00 00       	call   800f00 <__umoddi3>
  80037e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800382:	0f be 80 d6 10 80 00 	movsbl 0x8010d6(%eax),%eax
  800389:	89 04 24             	mov    %eax,(%esp)
  80038c:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80038f:	83 c4 3c             	add    $0x3c,%esp
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80039a:	83 fa 01             	cmp    $0x1,%edx
  80039d:	7e 0e                	jle    8003ad <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80039f:	8b 10                	mov    (%eax),%edx
  8003a1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a4:	89 08                	mov    %ecx,(%eax)
  8003a6:	8b 02                	mov    (%edx),%eax
  8003a8:	8b 52 04             	mov    0x4(%edx),%edx
  8003ab:	eb 22                	jmp    8003cf <getuint+0x38>
	else if (lflag)
  8003ad:	85 d2                	test   %edx,%edx
  8003af:	74 10                	je     8003c1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b1:	8b 10                	mov    (%eax),%edx
  8003b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b6:	89 08                	mov    %ecx,(%eax)
  8003b8:	8b 02                	mov    (%edx),%eax
  8003ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bf:	eb 0e                	jmp    8003cf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c1:	8b 10                	mov    (%eax),%edx
  8003c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c6:	89 08                	mov    %ecx,(%eax)
  8003c8:	8b 02                	mov    (%edx),%eax
  8003ca:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003db:	8b 10                	mov    (%eax),%edx
  8003dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e0:	73 0a                	jae    8003ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e5:	88 0a                	mov    %cl,(%edx)
  8003e7:	83 c2 01             	add    $0x1,%edx
  8003ea:	89 10                	mov    %edx,(%eax)
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800402:	8b 45 0c             	mov    0xc(%ebp),%eax
  800405:	89 44 24 04          	mov    %eax,0x4(%esp)
  800409:	8b 45 08             	mov    0x8(%ebp),%eax
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	e8 02 00 00 00       	call   800416 <vprintfmt>
	va_end(ap);
}
  800414:	c9                   	leave  
  800415:	c3                   	ret    

00800416 <vprintfmt>:
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);


void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800416:	55                   	push   %ebp
  800417:	89 e5                	mov    %esp,%ebp
  800419:	57                   	push   %edi
  80041a:	56                   	push   %esi
  80041b:	53                   	push   %ebx
  80041c:	83 ec 5c             	sub    $0x5c,%esp
  80041f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800422:	8b 75 10             	mov    0x10(%ebp),%esi
  800425:	eb 12                	jmp    800439 <vprintfmt+0x23>
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800427:	85 c0                	test   %eax,%eax
  800429:	0f 84 e4 04 00 00    	je     800913 <vprintfmt+0x4fd>
				return;
			putch(ch, putdat);
  80042f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800433:	89 04 24             	mov    %eax,(%esp)
  800436:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
	char col[4];

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800439:	0f b6 06             	movzbl (%esi),%eax
  80043c:	83 c6 01             	add    $0x1,%esi
  80043f:	83 f8 25             	cmp    $0x25,%eax
  800442:	75 e3                	jne    800427 <vprintfmt+0x11>
  800444:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
  800448:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80044f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800454:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80045b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800460:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  800463:	eb 2b                	jmp    800490 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 75 d4             	mov    -0x2c(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800468:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80046c:	eb 22                	jmp    800490 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800471:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800475:	eb 19                	jmp    800490 <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80047a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800481:	eb 0d                	jmp    800490 <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800483:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800486:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800489:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	0f b6 06             	movzbl (%esi),%eax
  800493:	0f b6 d0             	movzbl %al,%edx
  800496:	8d 7e 01             	lea    0x1(%esi),%edi
  800499:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049c:	83 e8 23             	sub    $0x23,%eax
  80049f:	3c 55                	cmp    $0x55,%al
  8004a1:	0f 87 46 04 00 00    	ja     8008ed <vprintfmt+0x4d7>
  8004a7:	0f b6 c0             	movzbl %al,%eax
  8004aa:	ff 24 85 7c 11 80 00 	jmp    *0x80117c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b1:	83 ea 30             	sub    $0x30,%edx
  8004b4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
				ch = *fmt;
  8004b7:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004bb:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004c1:	83 fa 09             	cmp    $0x9,%edx
  8004c4:	77 4a                	ja     800510 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c9:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004cc:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004cf:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004d3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004d6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004d9:	83 fa 09             	cmp    $0x9,%edx
  8004dc:	76 eb                	jbe    8004c9 <vprintfmt+0xb3>
  8004de:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  8004e1:	eb 2d                	jmp    800510 <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 50 04             	lea    0x4(%eax),%edx
  8004e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ec:	8b 00                	mov    (%eax),%eax
  8004ee:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f4:	eb 1a                	jmp    800510 <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004f9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004fd:	79 91                	jns    800490 <vprintfmt+0x7a>
  8004ff:	e9 73 ff ff ff       	jmp    800477 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800507:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
			goto reswitch;
  80050e:	eb 80                	jmp    800490 <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  800510:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800514:	0f 89 76 ff ff ff    	jns    800490 <vprintfmt+0x7a>
  80051a:	e9 64 ff ff ff       	jmp    800483 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800522:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800525:	e9 66 ff ff ff       	jmp    800490 <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8d 50 04             	lea    0x4(%eax),%edx
  800530:	89 55 14             	mov    %edx,0x14(%ebp)
  800533:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 04 24             	mov    %eax,(%esp)
  80053c:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800542:	e9 f2 fe ff ff       	jmp    800439 <vprintfmt+0x23>

		// color
		case 'C':
			// Get the color index
			
			col[0] = *(unsigned char *) fmt++;
  800547:	0f b6 46 01          	movzbl 0x1(%esi),%eax
  80054b:	88 45 e4             	mov    %al,-0x1c(%ebp)
			col[1] = *(unsigned char *) fmt++;
  80054e:	0f b6 56 02          	movzbl 0x2(%esi),%edx
  800552:	88 55 e5             	mov    %dl,-0x1b(%ebp)
			col[2] = *(unsigned char *) fmt++;
  800555:	0f b6 4e 03          	movzbl 0x3(%esi),%ecx
  800559:	88 4d e6             	mov    %cl,-0x1a(%ebp)
  80055c:	83 c6 04             	add    $0x4,%esi
			col[3] = '\0';
  80055f:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
			// check for the color
			if (col[0] >= '0' && col[0] <= '9') {
  800563:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800566:	80 f9 09             	cmp    $0x9,%cl
  800569:	77 1d                	ja     800588 <vprintfmt+0x172>
				ncolor = ( (col[0]-'0')*10 + (col[1]-'0') ) * 10 + (col[3]-'0');
  80056b:	0f be c0             	movsbl %al,%eax
  80056e:	6b c0 64             	imul   $0x64,%eax,%eax
  800571:	0f be d2             	movsbl %dl,%edx
  800574:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800577:	8d 84 50 30 eb ff ff 	lea    -0x14d0(%eax,%edx,2),%eax
  80057e:	a3 04 20 80 00       	mov    %eax,0x802004
  800583:	e9 b1 fe ff ff       	jmp    800439 <vprintfmt+0x23>
			} 
			else {
				if (strcmp (col, "red") == 0) ncolor = COLOR_RED;
  800588:	c7 44 24 04 ee 10 80 	movl   $0x8010ee,0x4(%esp)
  80058f:	00 
  800590:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800593:	89 04 24             	mov    %eax,(%esp)
  800596:	e8 10 05 00 00       	call   800aab <strcmp>
  80059b:	85 c0                	test   %eax,%eax
  80059d:	75 0f                	jne    8005ae <vprintfmt+0x198>
  80059f:	c7 05 04 20 80 00 04 	movl   $0x4,0x802004
  8005a6:	00 00 00 
  8005a9:	e9 8b fe ff ff       	jmp    800439 <vprintfmt+0x23>
				else if (strcmp (col, "grn") == 0) ncolor = COLOR_GRN;
  8005ae:	c7 44 24 04 f2 10 80 	movl   $0x8010f2,0x4(%esp)
  8005b5:	00 
  8005b6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8005b9:	89 14 24             	mov    %edx,(%esp)
  8005bc:	e8 ea 04 00 00       	call   800aab <strcmp>
  8005c1:	85 c0                	test   %eax,%eax
  8005c3:	75 0f                	jne    8005d4 <vprintfmt+0x1be>
  8005c5:	c7 05 04 20 80 00 02 	movl   $0x2,0x802004
  8005cc:	00 00 00 
  8005cf:	e9 65 fe ff ff       	jmp    800439 <vprintfmt+0x23>
				else if (strcmp (col, "blk") == 0) ncolor = COLOR_BLK;
  8005d4:	c7 44 24 04 f6 10 80 	movl   $0x8010f6,0x4(%esp)
  8005db:	00 
  8005dc:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8005df:	89 0c 24             	mov    %ecx,(%esp)
  8005e2:	e8 c4 04 00 00       	call   800aab <strcmp>
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	75 0f                	jne    8005fa <vprintfmt+0x1e4>
  8005eb:	c7 05 04 20 80 00 01 	movl   $0x1,0x802004
  8005f2:	00 00 00 
  8005f5:	e9 3f fe ff ff       	jmp    800439 <vprintfmt+0x23>
				else if (strcmp (col, "pur") == 0) ncolor = COLOR_PUR;
  8005fa:	c7 44 24 04 fa 10 80 	movl   $0x8010fa,0x4(%esp)
  800601:	00 
  800602:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800605:	89 3c 24             	mov    %edi,(%esp)
  800608:	e8 9e 04 00 00       	call   800aab <strcmp>
  80060d:	85 c0                	test   %eax,%eax
  80060f:	75 0f                	jne    800620 <vprintfmt+0x20a>
  800611:	c7 05 04 20 80 00 06 	movl   $0x6,0x802004
  800618:	00 00 00 
  80061b:	e9 19 fe ff ff       	jmp    800439 <vprintfmt+0x23>
				else if (strcmp (col, "wht") == 0) ncolor = COLOR_WHT;
  800620:	c7 44 24 04 fe 10 80 	movl   $0x8010fe,0x4(%esp)
  800627:	00 
  800628:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80062b:	89 04 24             	mov    %eax,(%esp)
  80062e:	e8 78 04 00 00       	call   800aab <strcmp>
  800633:	85 c0                	test   %eax,%eax
  800635:	75 0f                	jne    800646 <vprintfmt+0x230>
  800637:	c7 05 04 20 80 00 07 	movl   $0x7,0x802004
  80063e:	00 00 00 
  800641:	e9 f3 fd ff ff       	jmp    800439 <vprintfmt+0x23>
				else if (strcmp (col, "gry") == 0) ncolor = COLOR_GRY;
  800646:	c7 44 24 04 02 11 80 	movl   $0x801102,0x4(%esp)
  80064d:	00 
  80064e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800651:	89 14 24             	mov    %edx,(%esp)
  800654:	e8 52 04 00 00       	call   800aab <strcmp>
  800659:	83 f8 01             	cmp    $0x1,%eax
  80065c:	19 c0                	sbb    %eax,%eax
  80065e:	f7 d0                	not    %eax
  800660:	83 c0 08             	add    $0x8,%eax
  800663:	a3 04 20 80 00       	mov    %eax,0x802004
  800668:	e9 cc fd ff ff       	jmp    800439 <vprintfmt+0x23>
			break;


		// error message
		case 'e':
			err = va_arg(ap, int);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 50 04             	lea    0x4(%eax),%edx
  800673:	89 55 14             	mov    %edx,0x14(%ebp)
  800676:	8b 00                	mov    (%eax),%eax
  800678:	89 c2                	mov    %eax,%edx
  80067a:	c1 fa 1f             	sar    $0x1f,%edx
  80067d:	31 d0                	xor    %edx,%eax
  80067f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800681:	83 f8 06             	cmp    $0x6,%eax
  800684:	7f 0b                	jg     800691 <vprintfmt+0x27b>
  800686:	8b 14 85 d4 12 80 00 	mov    0x8012d4(,%eax,4),%edx
  80068d:	85 d2                	test   %edx,%edx
  80068f:	75 23                	jne    8006b4 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800691:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800695:	c7 44 24 08 06 11 80 	movl   $0x801106,0x8(%esp)
  80069c:	00 
  80069d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a4:	89 3c 24             	mov    %edi,(%esp)
  8006a7:	e8 42 fd ff ff       	call   8003ee <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ac:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006af:	e9 85 fd ff ff       	jmp    800439 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006b8:	c7 44 24 08 0f 11 80 	movl   $0x80110f,0x8(%esp)
  8006bf:	00 
  8006c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c7:	89 3c 24             	mov    %edi,(%esp)
  8006ca:	e8 1f fd ff ff       	call   8003ee <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006d2:	e9 62 fd ff ff       	jmp    800439 <vprintfmt+0x23>
  8006d7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
  8006da:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006dd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 50 04             	lea    0x4(%eax),%edx
  8006e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e9:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8006eb:	85 f6                	test   %esi,%esi
  8006ed:	b8 e7 10 80 00       	mov    $0x8010e7,%eax
  8006f2:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8006f5:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006f9:	7e 06                	jle    800701 <vprintfmt+0x2eb>
  8006fb:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8006ff:	75 13                	jne    800714 <vprintfmt+0x2fe>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800701:	0f be 06             	movsbl (%esi),%eax
  800704:	83 c6 01             	add    $0x1,%esi
  800707:	85 c0                	test   %eax,%eax
  800709:	0f 85 94 00 00 00    	jne    8007a3 <vprintfmt+0x38d>
  80070f:	e9 81 00 00 00       	jmp    800795 <vprintfmt+0x37f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800714:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800718:	89 34 24             	mov    %esi,(%esp)
  80071b:	e8 9b 02 00 00       	call   8009bb <strnlen>
  800720:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800723:	29 c2                	sub    %eax,%edx
  800725:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800728:	85 d2                	test   %edx,%edx
  80072a:	7e d5                	jle    800701 <vprintfmt+0x2eb>
					putch(padc, putdat);
  80072c:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  800730:	89 75 c4             	mov    %esi,-0x3c(%ebp)
  800733:	89 7d c0             	mov    %edi,-0x40(%ebp)
  800736:	89 d6                	mov    %edx,%esi
  800738:	89 cf                	mov    %ecx,%edi
  80073a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073e:	89 3c 24             	mov    %edi,(%esp)
  800741:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800744:	83 ee 01             	sub    $0x1,%esi
  800747:	75 f1                	jne    80073a <vprintfmt+0x324>
  800749:	8b 7d c0             	mov    -0x40(%ebp),%edi
  80074c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80074f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
  800752:	eb ad                	jmp    800701 <vprintfmt+0x2eb>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800754:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800758:	74 1b                	je     800775 <vprintfmt+0x35f>
  80075a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80075d:	83 fa 5e             	cmp    $0x5e,%edx
  800760:	76 13                	jbe    800775 <vprintfmt+0x35f>
					putch('?', putdat);
  800762:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800765:	89 44 24 04          	mov    %eax,0x4(%esp)
  800769:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800770:	ff 55 08             	call   *0x8(%ebp)
  800773:	eb 0d                	jmp    800782 <vprintfmt+0x36c>
				else
					putch(ch, putdat);
  800775:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800778:	89 54 24 04          	mov    %edx,0x4(%esp)
  80077c:	89 04 24             	mov    %eax,(%esp)
  80077f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800782:	83 eb 01             	sub    $0x1,%ebx
  800785:	0f be 06             	movsbl (%esi),%eax
  800788:	83 c6 01             	add    $0x1,%esi
  80078b:	85 c0                	test   %eax,%eax
  80078d:	75 1a                	jne    8007a9 <vprintfmt+0x393>
  80078f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800792:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800795:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800798:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80079c:	7f 1c                	jg     8007ba <vprintfmt+0x3a4>
  80079e:	e9 96 fc ff ff       	jmp    800439 <vprintfmt+0x23>
  8007a3:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8007a6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a9:	85 ff                	test   %edi,%edi
  8007ab:	78 a7                	js     800754 <vprintfmt+0x33e>
  8007ad:	83 ef 01             	sub    $0x1,%edi
  8007b0:	79 a2                	jns    800754 <vprintfmt+0x33e>
  8007b2:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007b5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007b8:	eb db                	jmp    800795 <vprintfmt+0x37f>
  8007ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007bd:	89 de                	mov    %ebx,%esi
  8007bf:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007cd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007cf:	83 eb 01             	sub    $0x1,%ebx
  8007d2:	75 ee                	jne    8007c2 <vprintfmt+0x3ac>
  8007d4:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8007d9:	e9 5b fc ff ff       	jmp    800439 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007de:	83 f9 01             	cmp    $0x1,%ecx
  8007e1:	7e 10                	jle    8007f3 <vprintfmt+0x3dd>
		return va_arg(*ap, long long);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8d 50 08             	lea    0x8(%eax),%edx
  8007e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ec:	8b 30                	mov    (%eax),%esi
  8007ee:	8b 78 04             	mov    0x4(%eax),%edi
  8007f1:	eb 26                	jmp    800819 <vprintfmt+0x403>
	else if (lflag)
  8007f3:	85 c9                	test   %ecx,%ecx
  8007f5:	74 12                	je     800809 <vprintfmt+0x3f3>
		return va_arg(*ap, long);
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	8d 50 04             	lea    0x4(%eax),%edx
  8007fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800800:	8b 30                	mov    (%eax),%esi
  800802:	89 f7                	mov    %esi,%edi
  800804:	c1 ff 1f             	sar    $0x1f,%edi
  800807:	eb 10                	jmp    800819 <vprintfmt+0x403>
	else
		return va_arg(*ap, int);
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8d 50 04             	lea    0x4(%eax),%edx
  80080f:	89 55 14             	mov    %edx,0x14(%ebp)
  800812:	8b 30                	mov    (%eax),%esi
  800814:	89 f7                	mov    %esi,%edi
  800816:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800819:	85 ff                	test   %edi,%edi
  80081b:	78 0e                	js     80082b <vprintfmt+0x415>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80081d:	89 f0                	mov    %esi,%eax
  80081f:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800821:	be 0a 00 00 00       	mov    $0xa,%esi
  800826:	e9 84 00 00 00       	jmp    8008af <vprintfmt+0x499>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80082b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800836:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800839:	89 f0                	mov    %esi,%eax
  80083b:	89 fa                	mov    %edi,%edx
  80083d:	f7 d8                	neg    %eax
  80083f:	83 d2 00             	adc    $0x0,%edx
  800842:	f7 da                	neg    %edx
			}
			base = 10;
  800844:	be 0a 00 00 00       	mov    $0xa,%esi
  800849:	eb 64                	jmp    8008af <vprintfmt+0x499>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80084b:	89 ca                	mov    %ecx,%edx
  80084d:	8d 45 14             	lea    0x14(%ebp),%eax
  800850:	e8 42 fb ff ff       	call   800397 <getuint>
			base = 10;
  800855:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
  80085a:	eb 53                	jmp    8008af <vprintfmt+0x499>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80085c:	89 ca                	mov    %ecx,%edx
  80085e:	8d 45 14             	lea    0x14(%ebp),%eax
  800861:	e8 31 fb ff ff       	call   800397 <getuint>
    			base = 8;
  800866:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
  80086b:	eb 42                	jmp    8008af <vprintfmt+0x499>

		// pointer
		case 'p':
			putch('0', putdat);
  80086d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800871:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800878:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80087b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800886:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800889:	8b 45 14             	mov    0x14(%ebp),%eax
  80088c:	8d 50 04             	lea    0x4(%eax),%edx
  80088f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800892:	8b 00                	mov    (%eax),%eax
  800894:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800899:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
  80089e:	eb 0f                	jmp    8008af <vprintfmt+0x499>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a0:	89 ca                	mov    %ecx,%edx
  8008a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a5:	e8 ed fa ff ff       	call   800397 <getuint>
			base = 16;
  8008aa:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008af:	0f be 4d d0          	movsbl -0x30(%ebp),%ecx
  8008b3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8008b7:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8008ba:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8008be:	89 74 24 08          	mov    %esi,0x8(%esp)
  8008c2:	89 04 24             	mov    %eax,(%esp)
  8008c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c9:	89 da                	mov    %ebx,%edx
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	e8 e9 f9 ff ff       	call   8002bc <printnum>
			break;
  8008d3:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8008d6:	e9 5e fb ff ff       	jmp    800439 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008df:	89 14 24             	mov    %edx,(%esp)
  8008e2:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008e8:	e9 4c fb ff ff       	jmp    800439 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008f8:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008fb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008ff:	0f 84 34 fb ff ff    	je     800439 <vprintfmt+0x23>
  800905:	83 ee 01             	sub    $0x1,%esi
  800908:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80090c:	75 f7                	jne    800905 <vprintfmt+0x4ef>
  80090e:	e9 26 fb ff ff       	jmp    800439 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800913:	83 c4 5c             	add    $0x5c,%esp
  800916:	5b                   	pop    %ebx
  800917:	5e                   	pop    %esi
  800918:	5f                   	pop    %edi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	83 ec 28             	sub    $0x28,%esp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800927:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80092a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80092e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800931:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800938:	85 c0                	test   %eax,%eax
  80093a:	74 30                	je     80096c <vsnprintf+0x51>
  80093c:	85 d2                	test   %edx,%edx
  80093e:	7e 2c                	jle    80096c <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800940:	8b 45 14             	mov    0x14(%ebp),%eax
  800943:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800947:	8b 45 10             	mov    0x10(%ebp),%eax
  80094a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800951:	89 44 24 04          	mov    %eax,0x4(%esp)
  800955:	c7 04 24 d1 03 80 00 	movl   $0x8003d1,(%esp)
  80095c:	e8 b5 fa ff ff       	call   800416 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800961:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800964:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800967:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096a:	eb 05                	jmp    800971 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80096c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800979:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80097c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800980:	8b 45 10             	mov    0x10(%ebp),%eax
  800983:	89 44 24 08          	mov    %eax,0x8(%esp)
  800987:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	89 04 24             	mov    %eax,(%esp)
  800994:	e8 82 ff ff ff       	call   80091b <vsnprintf>
	va_end(ap);

	return rc;
}
  800999:	c9                   	leave  
  80099a:	c3                   	ret    
  80099b:	00 00                	add    %al,(%eax)
  80099d:	00 00                	add    %al,(%eax)
	...

008009a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8009ae:	74 09                	je     8009b9 <strlen+0x19>
		n++;
  8009b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b7:	75 f7                	jne    8009b0 <strlen+0x10>
		n++;
	return n;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ca:	85 c9                	test   %ecx,%ecx
  8009cc:	74 1a                	je     8009e8 <strnlen+0x2d>
  8009ce:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009d1:	74 15                	je     8009e8 <strnlen+0x2d>
  8009d3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009d8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009da:	39 ca                	cmp    %ecx,%edx
  8009dc:	74 0a                	je     8009e8 <strnlen+0x2d>
  8009de:	83 c2 01             	add    $0x1,%edx
  8009e1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009e6:	75 f0                	jne    8009d8 <strnlen+0x1d>
		n++;
	return n;
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	53                   	push   %ebx
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009fe:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a01:	83 c2 01             	add    $0x1,%edx
  800a04:	84 c9                	test   %cl,%cl
  800a06:	75 f2                	jne    8009fa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a08:	5b                   	pop    %ebx
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	83 ec 08             	sub    $0x8,%esp
  800a12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a15:	89 1c 24             	mov    %ebx,(%esp)
  800a18:	e8 83 ff ff ff       	call   8009a0 <strlen>
	strcpy(dst + len, src);
  800a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a20:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a24:	01 d8                	add    %ebx,%eax
  800a26:	89 04 24             	mov    %eax,(%esp)
  800a29:	e8 bd ff ff ff       	call   8009eb <strcpy>
	return dst;
}
  800a2e:	89 d8                	mov    %ebx,%eax
  800a30:	83 c4 08             	add    $0x8,%esp
  800a33:	5b                   	pop    %ebx
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a41:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a44:	85 f6                	test   %esi,%esi
  800a46:	74 18                	je     800a60 <strncpy+0x2a>
  800a48:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a4d:	0f b6 1a             	movzbl (%edx),%ebx
  800a50:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a53:	80 3a 01             	cmpb   $0x1,(%edx)
  800a56:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a59:	83 c1 01             	add    $0x1,%ecx
  800a5c:	39 f1                	cmp    %esi,%ecx
  800a5e:	75 ed                	jne    800a4d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a70:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a73:	89 f8                	mov    %edi,%eax
  800a75:	85 f6                	test   %esi,%esi
  800a77:	74 2b                	je     800aa4 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a79:	83 fe 01             	cmp    $0x1,%esi
  800a7c:	74 23                	je     800aa1 <strlcpy+0x3d>
  800a7e:	0f b6 0b             	movzbl (%ebx),%ecx
  800a81:	84 c9                	test   %cl,%cl
  800a83:	74 1c                	je     800aa1 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a85:	83 ee 02             	sub    $0x2,%esi
  800a88:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a8d:	88 08                	mov    %cl,(%eax)
  800a8f:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a92:	39 f2                	cmp    %esi,%edx
  800a94:	74 0b                	je     800aa1 <strlcpy+0x3d>
  800a96:	83 c2 01             	add    $0x1,%edx
  800a99:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a9d:	84 c9                	test   %cl,%cl
  800a9f:	75 ec                	jne    800a8d <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800aa1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aa4:	29 f8                	sub    %edi,%eax
}
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ab4:	0f b6 01             	movzbl (%ecx),%eax
  800ab7:	84 c0                	test   %al,%al
  800ab9:	74 16                	je     800ad1 <strcmp+0x26>
  800abb:	3a 02                	cmp    (%edx),%al
  800abd:	75 12                	jne    800ad1 <strcmp+0x26>
		p++, q++;
  800abf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ac2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800ac6:	84 c0                	test   %al,%al
  800ac8:	74 07                	je     800ad1 <strcmp+0x26>
  800aca:	83 c1 01             	add    $0x1,%ecx
  800acd:	3a 02                	cmp    (%edx),%al
  800acf:	74 ee                	je     800abf <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad1:	0f b6 c0             	movzbl %al,%eax
  800ad4:	0f b6 12             	movzbl (%edx),%edx
  800ad7:	29 d0                	sub    %edx,%eax
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	53                   	push   %ebx
  800adf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aed:	85 d2                	test   %edx,%edx
  800aef:	74 28                	je     800b19 <strncmp+0x3e>
  800af1:	0f b6 01             	movzbl (%ecx),%eax
  800af4:	84 c0                	test   %al,%al
  800af6:	74 24                	je     800b1c <strncmp+0x41>
  800af8:	3a 03                	cmp    (%ebx),%al
  800afa:	75 20                	jne    800b1c <strncmp+0x41>
  800afc:	83 ea 01             	sub    $0x1,%edx
  800aff:	74 13                	je     800b14 <strncmp+0x39>
		n--, p++, q++;
  800b01:	83 c1 01             	add    $0x1,%ecx
  800b04:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b07:	0f b6 01             	movzbl (%ecx),%eax
  800b0a:	84 c0                	test   %al,%al
  800b0c:	74 0e                	je     800b1c <strncmp+0x41>
  800b0e:	3a 03                	cmp    (%ebx),%al
  800b10:	74 ea                	je     800afc <strncmp+0x21>
  800b12:	eb 08                	jmp    800b1c <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b14:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1c:	0f b6 01             	movzbl (%ecx),%eax
  800b1f:	0f b6 13             	movzbl (%ebx),%edx
  800b22:	29 d0                	sub    %edx,%eax
  800b24:	eb f3                	jmp    800b19 <strncmp+0x3e>

00800b26 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b30:	0f b6 10             	movzbl (%eax),%edx
  800b33:	84 d2                	test   %dl,%dl
  800b35:	74 1c                	je     800b53 <strchr+0x2d>
		if (*s == c)
  800b37:	38 ca                	cmp    %cl,%dl
  800b39:	75 09                	jne    800b44 <strchr+0x1e>
  800b3b:	eb 1b                	jmp    800b58 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b3d:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800b40:	38 ca                	cmp    %cl,%dl
  800b42:	74 14                	je     800b58 <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b44:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800b48:	84 d2                	test   %dl,%dl
  800b4a:	75 f1                	jne    800b3d <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b51:	eb 05                	jmp    800b58 <strchr+0x32>
  800b53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b64:	0f b6 10             	movzbl (%eax),%edx
  800b67:	84 d2                	test   %dl,%dl
  800b69:	74 14                	je     800b7f <strfind+0x25>
		if (*s == c)
  800b6b:	38 ca                	cmp    %cl,%dl
  800b6d:	75 06                	jne    800b75 <strfind+0x1b>
  800b6f:	eb 0e                	jmp    800b7f <strfind+0x25>
  800b71:	38 ca                	cmp    %cl,%dl
  800b73:	74 0a                	je     800b7f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b75:	83 c0 01             	add    $0x1,%eax
  800b78:	0f b6 10             	movzbl (%eax),%edx
  800b7b:	84 d2                	test   %dl,%dl
  800b7d:	75 f2                	jne    800b71 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 0c             	sub    $0xc,%esp
  800b87:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b8a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b8d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800b90:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b99:	85 c9                	test   %ecx,%ecx
  800b9b:	74 30                	je     800bcd <memset+0x4c>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b9d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ba3:	75 25                	jne    800bca <memset+0x49>
  800ba5:	f6 c1 03             	test   $0x3,%cl
  800ba8:	75 20                	jne    800bca <memset+0x49>
		c &= 0xFF;
  800baa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	c1 e3 08             	shl    $0x8,%ebx
  800bb2:	89 d6                	mov    %edx,%esi
  800bb4:	c1 e6 18             	shl    $0x18,%esi
  800bb7:	89 d0                	mov    %edx,%eax
  800bb9:	c1 e0 10             	shl    $0x10,%eax
  800bbc:	09 f0                	or     %esi,%eax
  800bbe:	09 d0                	or     %edx,%eax
  800bc0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bc2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bc5:	fc                   	cld    
  800bc6:	f3 ab                	rep stos %eax,%es:(%edi)
  800bc8:	eb 03                	jmp    800bcd <memset+0x4c>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bca:	fc                   	cld    
  800bcb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bcd:	89 f8                	mov    %edi,%eax
  800bcf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bd8:	89 ec                	mov    %ebp,%esp
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 08             	sub    $0x8,%esp
  800be2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800be5:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800be8:	8b 45 08             	mov    0x8(%ebp),%eax
  800beb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bf1:	39 c6                	cmp    %eax,%esi
  800bf3:	73 36                	jae    800c2b <memmove+0x4f>
  800bf5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bf8:	39 d0                	cmp    %edx,%eax
  800bfa:	73 2f                	jae    800c2b <memmove+0x4f>
		s += n;
		d += n;
  800bfc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bff:	f6 c2 03             	test   $0x3,%dl
  800c02:	75 1b                	jne    800c1f <memmove+0x43>
  800c04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c0a:	75 13                	jne    800c1f <memmove+0x43>
  800c0c:	f6 c1 03             	test   $0x3,%cl
  800c0f:	75 0e                	jne    800c1f <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c11:	83 ef 04             	sub    $0x4,%edi
  800c14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c17:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c1a:	fd                   	std    
  800c1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c1d:	eb 09                	jmp    800c28 <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c1f:	83 ef 01             	sub    $0x1,%edi
  800c22:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c25:	fd                   	std    
  800c26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c28:	fc                   	cld    
  800c29:	eb 20                	jmp    800c4b <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c31:	75 13                	jne    800c46 <memmove+0x6a>
  800c33:	a8 03                	test   $0x3,%al
  800c35:	75 0f                	jne    800c46 <memmove+0x6a>
  800c37:	f6 c1 03             	test   $0x3,%cl
  800c3a:	75 0a                	jne    800c46 <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c3c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c3f:	89 c7                	mov    %eax,%edi
  800c41:	fc                   	cld    
  800c42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c44:	eb 05                	jmp    800c4b <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c46:	89 c7                	mov    %eax,%edi
  800c48:	fc                   	cld    
  800c49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c4b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c4e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c51:	89 ec                	mov    %ebp,%esp
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c5b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c69:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6c:	89 04 24             	mov    %eax,(%esp)
  800c6f:	e8 68 ff ff ff       	call   800bdc <memmove>
}
  800c74:	c9                   	leave  
  800c75:	c3                   	ret    

00800c76 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c82:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c85:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c8a:	85 ff                	test   %edi,%edi
  800c8c:	74 37                	je     800cc5 <memcmp+0x4f>
		if (*s1 != *s2)
  800c8e:	0f b6 03             	movzbl (%ebx),%eax
  800c91:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c94:	83 ef 01             	sub    $0x1,%edi
  800c97:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c9c:	38 c8                	cmp    %cl,%al
  800c9e:	74 1c                	je     800cbc <memcmp+0x46>
  800ca0:	eb 10                	jmp    800cb2 <memcmp+0x3c>
  800ca2:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ca7:	83 c2 01             	add    $0x1,%edx
  800caa:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800cae:	38 c8                	cmp    %cl,%al
  800cb0:	74 0a                	je     800cbc <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800cb2:	0f b6 c0             	movzbl %al,%eax
  800cb5:	0f b6 c9             	movzbl %cl,%ecx
  800cb8:	29 c8                	sub    %ecx,%eax
  800cba:	eb 09                	jmp    800cc5 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cbc:	39 fa                	cmp    %edi,%edx
  800cbe:	75 e2                	jne    800ca2 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cd0:	89 c2                	mov    %eax,%edx
  800cd2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cd5:	39 d0                	cmp    %edx,%eax
  800cd7:	73 19                	jae    800cf2 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800cdd:	38 08                	cmp    %cl,(%eax)
  800cdf:	75 06                	jne    800ce7 <memfind+0x1d>
  800ce1:	eb 0f                	jmp    800cf2 <memfind+0x28>
  800ce3:	38 08                	cmp    %cl,(%eax)
  800ce5:	74 0b                	je     800cf2 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ce7:	83 c0 01             	add    $0x1,%eax
  800cea:	39 d0                	cmp    %edx,%eax
  800cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	75 f1                	jne    800ce3 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d00:	0f b6 02             	movzbl (%edx),%eax
  800d03:	3c 20                	cmp    $0x20,%al
  800d05:	74 04                	je     800d0b <strtol+0x17>
  800d07:	3c 09                	cmp    $0x9,%al
  800d09:	75 0e                	jne    800d19 <strtol+0x25>
		s++;
  800d0b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d0e:	0f b6 02             	movzbl (%edx),%eax
  800d11:	3c 20                	cmp    $0x20,%al
  800d13:	74 f6                	je     800d0b <strtol+0x17>
  800d15:	3c 09                	cmp    $0x9,%al
  800d17:	74 f2                	je     800d0b <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d19:	3c 2b                	cmp    $0x2b,%al
  800d1b:	75 0a                	jne    800d27 <strtol+0x33>
		s++;
  800d1d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d20:	bf 00 00 00 00       	mov    $0x0,%edi
  800d25:	eb 10                	jmp    800d37 <strtol+0x43>
  800d27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d2c:	3c 2d                	cmp    $0x2d,%al
  800d2e:	75 07                	jne    800d37 <strtol+0x43>
		s++, neg = 1;
  800d30:	83 c2 01             	add    $0x1,%edx
  800d33:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d37:	85 db                	test   %ebx,%ebx
  800d39:	0f 94 c0             	sete   %al
  800d3c:	74 05                	je     800d43 <strtol+0x4f>
  800d3e:	83 fb 10             	cmp    $0x10,%ebx
  800d41:	75 15                	jne    800d58 <strtol+0x64>
  800d43:	80 3a 30             	cmpb   $0x30,(%edx)
  800d46:	75 10                	jne    800d58 <strtol+0x64>
  800d48:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d4c:	75 0a                	jne    800d58 <strtol+0x64>
		s += 2, base = 16;
  800d4e:	83 c2 02             	add    $0x2,%edx
  800d51:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d56:	eb 13                	jmp    800d6b <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d58:	84 c0                	test   %al,%al
  800d5a:	74 0f                	je     800d6b <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d61:	80 3a 30             	cmpb   $0x30,(%edx)
  800d64:	75 05                	jne    800d6b <strtol+0x77>
		s++, base = 8;
  800d66:	83 c2 01             	add    $0x1,%edx
  800d69:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d70:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d72:	0f b6 0a             	movzbl (%edx),%ecx
  800d75:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d78:	80 fb 09             	cmp    $0x9,%bl
  800d7b:	77 08                	ja     800d85 <strtol+0x91>
			dig = *s - '0';
  800d7d:	0f be c9             	movsbl %cl,%ecx
  800d80:	83 e9 30             	sub    $0x30,%ecx
  800d83:	eb 1e                	jmp    800da3 <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d85:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d88:	80 fb 19             	cmp    $0x19,%bl
  800d8b:	77 08                	ja     800d95 <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d8d:	0f be c9             	movsbl %cl,%ecx
  800d90:	83 e9 57             	sub    $0x57,%ecx
  800d93:	eb 0e                	jmp    800da3 <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d95:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d98:	80 fb 19             	cmp    $0x19,%bl
  800d9b:	77 14                	ja     800db1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d9d:	0f be c9             	movsbl %cl,%ecx
  800da0:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800da3:	39 f1                	cmp    %esi,%ecx
  800da5:	7d 0e                	jge    800db5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800da7:	83 c2 01             	add    $0x1,%edx
  800daa:	0f af c6             	imul   %esi,%eax
  800dad:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800daf:	eb c1                	jmp    800d72 <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800db1:	89 c1                	mov    %eax,%ecx
  800db3:	eb 02                	jmp    800db7 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800db5:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800db7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dbb:	74 05                	je     800dc2 <strtol+0xce>
		*endptr = (char *) s;
  800dbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dc0:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dc2:	89 ca                	mov    %ecx,%edx
  800dc4:	f7 da                	neg    %edx
  800dc6:	85 ff                	test   %edi,%edi
  800dc8:	0f 45 c2             	cmovne %edx,%eax
}
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <__udivdi3>:
  800dd0:	83 ec 1c             	sub    $0x1c,%esp
  800dd3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800dd7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800ddb:	8b 44 24 20          	mov    0x20(%esp),%eax
  800ddf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800de3:	89 74 24 10          	mov    %esi,0x10(%esp)
  800de7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800deb:	85 ff                	test   %edi,%edi
  800ded:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800df1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800df5:	89 cd                	mov    %ecx,%ebp
  800df7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dfb:	75 33                	jne    800e30 <__udivdi3+0x60>
  800dfd:	39 f1                	cmp    %esi,%ecx
  800dff:	77 57                	ja     800e58 <__udivdi3+0x88>
  800e01:	85 c9                	test   %ecx,%ecx
  800e03:	75 0b                	jne    800e10 <__udivdi3+0x40>
  800e05:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0a:	31 d2                	xor    %edx,%edx
  800e0c:	f7 f1                	div    %ecx
  800e0e:	89 c1                	mov    %eax,%ecx
  800e10:	89 f0                	mov    %esi,%eax
  800e12:	31 d2                	xor    %edx,%edx
  800e14:	f7 f1                	div    %ecx
  800e16:	89 c6                	mov    %eax,%esi
  800e18:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e1c:	f7 f1                	div    %ecx
  800e1e:	89 f2                	mov    %esi,%edx
  800e20:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e24:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e28:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e2c:	83 c4 1c             	add    $0x1c,%esp
  800e2f:	c3                   	ret    
  800e30:	31 d2                	xor    %edx,%edx
  800e32:	31 c0                	xor    %eax,%eax
  800e34:	39 f7                	cmp    %esi,%edi
  800e36:	77 e8                	ja     800e20 <__udivdi3+0x50>
  800e38:	0f bd cf             	bsr    %edi,%ecx
  800e3b:	83 f1 1f             	xor    $0x1f,%ecx
  800e3e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e42:	75 2c                	jne    800e70 <__udivdi3+0xa0>
  800e44:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800e48:	76 04                	jbe    800e4e <__udivdi3+0x7e>
  800e4a:	39 f7                	cmp    %esi,%edi
  800e4c:	73 d2                	jae    800e20 <__udivdi3+0x50>
  800e4e:	31 d2                	xor    %edx,%edx
  800e50:	b8 01 00 00 00       	mov    $0x1,%eax
  800e55:	eb c9                	jmp    800e20 <__udivdi3+0x50>
  800e57:	90                   	nop
  800e58:	89 f2                	mov    %esi,%edx
  800e5a:	f7 f1                	div    %ecx
  800e5c:	31 d2                	xor    %edx,%edx
  800e5e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e62:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e66:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e6a:	83 c4 1c             	add    $0x1c,%esp
  800e6d:	c3                   	ret    
  800e6e:	66 90                	xchg   %ax,%ax
  800e70:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e75:	b8 20 00 00 00       	mov    $0x20,%eax
  800e7a:	89 ea                	mov    %ebp,%edx
  800e7c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800e80:	d3 e7                	shl    %cl,%edi
  800e82:	89 c1                	mov    %eax,%ecx
  800e84:	d3 ea                	shr    %cl,%edx
  800e86:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e8b:	09 fa                	or     %edi,%edx
  800e8d:	89 f7                	mov    %esi,%edi
  800e8f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e93:	89 f2                	mov    %esi,%edx
  800e95:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e99:	d3 e5                	shl    %cl,%ebp
  800e9b:	89 c1                	mov    %eax,%ecx
  800e9d:	d3 ef                	shr    %cl,%edi
  800e9f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ea4:	d3 e2                	shl    %cl,%edx
  800ea6:	89 c1                	mov    %eax,%ecx
  800ea8:	d3 ee                	shr    %cl,%esi
  800eaa:	09 d6                	or     %edx,%esi
  800eac:	89 fa                	mov    %edi,%edx
  800eae:	89 f0                	mov    %esi,%eax
  800eb0:	f7 74 24 0c          	divl   0xc(%esp)
  800eb4:	89 d7                	mov    %edx,%edi
  800eb6:	89 c6                	mov    %eax,%esi
  800eb8:	f7 e5                	mul    %ebp
  800eba:	39 d7                	cmp    %edx,%edi
  800ebc:	72 22                	jb     800ee0 <__udivdi3+0x110>
  800ebe:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800ec2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ec7:	d3 e5                	shl    %cl,%ebp
  800ec9:	39 c5                	cmp    %eax,%ebp
  800ecb:	73 04                	jae    800ed1 <__udivdi3+0x101>
  800ecd:	39 d7                	cmp    %edx,%edi
  800ecf:	74 0f                	je     800ee0 <__udivdi3+0x110>
  800ed1:	89 f0                	mov    %esi,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	e9 46 ff ff ff       	jmp    800e20 <__udivdi3+0x50>
  800eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee0:	8d 46 ff             	lea    -0x1(%esi),%eax
  800ee3:	31 d2                	xor    %edx,%edx
  800ee5:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ee9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800eed:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ef1:	83 c4 1c             	add    $0x1c,%esp
  800ef4:	c3                   	ret    
	...

00800f00 <__umoddi3>:
  800f00:	83 ec 1c             	sub    $0x1c,%esp
  800f03:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f07:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800f0b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f0f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f13:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f17:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f1b:	85 ed                	test   %ebp,%ebp
  800f1d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f21:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f25:	89 cf                	mov    %ecx,%edi
  800f27:	89 04 24             	mov    %eax,(%esp)
  800f2a:	89 f2                	mov    %esi,%edx
  800f2c:	75 1a                	jne    800f48 <__umoddi3+0x48>
  800f2e:	39 f1                	cmp    %esi,%ecx
  800f30:	76 4e                	jbe    800f80 <__umoddi3+0x80>
  800f32:	f7 f1                	div    %ecx
  800f34:	89 d0                	mov    %edx,%eax
  800f36:	31 d2                	xor    %edx,%edx
  800f38:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f3c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f40:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f44:	83 c4 1c             	add    $0x1c,%esp
  800f47:	c3                   	ret    
  800f48:	39 f5                	cmp    %esi,%ebp
  800f4a:	77 54                	ja     800fa0 <__umoddi3+0xa0>
  800f4c:	0f bd c5             	bsr    %ebp,%eax
  800f4f:	83 f0 1f             	xor    $0x1f,%eax
  800f52:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f56:	75 60                	jne    800fb8 <__umoddi3+0xb8>
  800f58:	3b 0c 24             	cmp    (%esp),%ecx
  800f5b:	0f 87 07 01 00 00    	ja     801068 <__umoddi3+0x168>
  800f61:	89 f2                	mov    %esi,%edx
  800f63:	8b 34 24             	mov    (%esp),%esi
  800f66:	29 ce                	sub    %ecx,%esi
  800f68:	19 ea                	sbb    %ebp,%edx
  800f6a:	89 34 24             	mov    %esi,(%esp)
  800f6d:	8b 04 24             	mov    (%esp),%eax
  800f70:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f74:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f78:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f7c:	83 c4 1c             	add    $0x1c,%esp
  800f7f:	c3                   	ret    
  800f80:	85 c9                	test   %ecx,%ecx
  800f82:	75 0b                	jne    800f8f <__umoddi3+0x8f>
  800f84:	b8 01 00 00 00       	mov    $0x1,%eax
  800f89:	31 d2                	xor    %edx,%edx
  800f8b:	f7 f1                	div    %ecx
  800f8d:	89 c1                	mov    %eax,%ecx
  800f8f:	89 f0                	mov    %esi,%eax
  800f91:	31 d2                	xor    %edx,%edx
  800f93:	f7 f1                	div    %ecx
  800f95:	8b 04 24             	mov    (%esp),%eax
  800f98:	f7 f1                	div    %ecx
  800f9a:	eb 98                	jmp    800f34 <__umoddi3+0x34>
  800f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	89 f2                	mov    %esi,%edx
  800fa2:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fa6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800faa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fae:	83 c4 1c             	add    $0x1c,%esp
  800fb1:	c3                   	ret    
  800fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fb8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fbd:	89 e8                	mov    %ebp,%eax
  800fbf:	bd 20 00 00 00       	mov    $0x20,%ebp
  800fc4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  800fc8:	89 fa                	mov    %edi,%edx
  800fca:	d3 e0                	shl    %cl,%eax
  800fcc:	89 e9                	mov    %ebp,%ecx
  800fce:	d3 ea                	shr    %cl,%edx
  800fd0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fd5:	09 c2                	or     %eax,%edx
  800fd7:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fdb:	89 14 24             	mov    %edx,(%esp)
  800fde:	89 f2                	mov    %esi,%edx
  800fe0:	d3 e7                	shl    %cl,%edi
  800fe2:	89 e9                	mov    %ebp,%ecx
  800fe4:	d3 ea                	shr    %cl,%edx
  800fe6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800feb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fef:	d3 e6                	shl    %cl,%esi
  800ff1:	89 e9                	mov    %ebp,%ecx
  800ff3:	d3 e8                	shr    %cl,%eax
  800ff5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ffa:	09 f0                	or     %esi,%eax
  800ffc:	8b 74 24 08          	mov    0x8(%esp),%esi
  801000:	f7 34 24             	divl   (%esp)
  801003:	d3 e6                	shl    %cl,%esi
  801005:	89 74 24 08          	mov    %esi,0x8(%esp)
  801009:	89 d6                	mov    %edx,%esi
  80100b:	f7 e7                	mul    %edi
  80100d:	39 d6                	cmp    %edx,%esi
  80100f:	89 c1                	mov    %eax,%ecx
  801011:	89 d7                	mov    %edx,%edi
  801013:	72 3f                	jb     801054 <__umoddi3+0x154>
  801015:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801019:	72 35                	jb     801050 <__umoddi3+0x150>
  80101b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80101f:	29 c8                	sub    %ecx,%eax
  801021:	19 fe                	sbb    %edi,%esi
  801023:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801028:	89 f2                	mov    %esi,%edx
  80102a:	d3 e8                	shr    %cl,%eax
  80102c:	89 e9                	mov    %ebp,%ecx
  80102e:	d3 e2                	shl    %cl,%edx
  801030:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801035:	09 d0                	or     %edx,%eax
  801037:	89 f2                	mov    %esi,%edx
  801039:	d3 ea                	shr    %cl,%edx
  80103b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80103f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801043:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801047:	83 c4 1c             	add    $0x1c,%esp
  80104a:	c3                   	ret    
  80104b:	90                   	nop
  80104c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801050:	39 d6                	cmp    %edx,%esi
  801052:	75 c7                	jne    80101b <__umoddi3+0x11b>
  801054:	89 d7                	mov    %edx,%edi
  801056:	89 c1                	mov    %eax,%ecx
  801058:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80105c:	1b 3c 24             	sbb    (%esp),%edi
  80105f:	eb ba                	jmp    80101b <__umoddi3+0x11b>
  801061:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801068:	39 f5                	cmp    %esi,%ebp
  80106a:	0f 82 f1 fe ff ff    	jb     800f61 <__umoddi3+0x61>
  801070:	e9 f8 fe ff ff       	jmp    800f6d <__umoddi3+0x6d>
