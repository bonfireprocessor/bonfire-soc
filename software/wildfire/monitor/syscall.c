// See LICENSE for license details.

#include "bonfire.h"
#include <sys/errno.h>
#include "syscall.h"
#include "file.h"
#include "monitor.h"
#include "uart.h"
#include "console.h"
#include <string.h>



typedef long (*syscall_t)(long, long, long, long, long, long, long);

uint32_t  brk_address = (uint32_t) LOAD_BASE;

#define BRK_MAX  (DRAM_TOP-(256*1024))// reserve 256KB as stackspace

void sys_exit(int code)
{
void (*reboot)()=(void*)SRAM_BASE;
  
   reboot();

}


ssize_t sys_read(int fd, char* buf, size_t n)
{
   
  if (fd!=0) return -EBADF; 
  if (n==1) {
     *buf=readchar();
     return 1;
  }  else
    return readBuffer(buf,n);
  
}



ssize_t sys_write(int fd, const char* buf, size_t n)
{
const char *p;    
  if (fd!=1) return -EBADF;
  
  p=buf;
  while (*p && p < (buf+n)) {
    if (*p=='\n') writechar('\r');   
    writechar(*p);
    p++;
  } 
  return n;
  
}





int sys_open(const char* name, int flags, int mode)
{
   return -ENOSYS;
}

int sys_close(int fd)
{
  return 0;
}



int sys_fstat(int fd, void* st)
{
  int r = -EBADF;
 
  return r;
}

int sys_fcntl(int fd, int cmd, int arg)
{
  int r = -EBADF;
 

  return r;
}




size_t sys_brk(size_t pos)
{
size_t newbrk;
    
 // printk("sys_brk with arg %x\n",pos); 
 // readchar(); 
  if (pos>0)
  {
    newbrk=pos;
    if (newbrk>BRK_MAX)
      return -1;
    else
      brk_address=newbrk;
  }    
 // printk("new brk address %x\n:",brk_address);  
  return brk_address; 
}

int sys_uname(void* buf)
{
  const int sz = 65;
  strcpy(buf + 0*sz, "Bonfire Monitor");
  strcpy(buf + 1*sz, "");
  strcpy(buf + 2*sz, "0.1.g");
  strcpy(buf + 3*sz, "");
  strcpy(buf + 4*sz, "");
  strcpy(buf + 5*sz, "");
  return 0;
}

pid_t sys_getpid()
{
  return 0;
}

int sys_getuid()
{
  return 0;
}

uintptr_t sys_mmap(uintptr_t addr, size_t length, int prot, int flags, int fd, off_t offset)
{
 
  return  -EBADF;
}

int sys_munmap(uintptr_t addr, size_t length)
{
  return 0;
}

uintptr_t sys_mremap(uintptr_t addr, size_t old_size, size_t new_size, int flags)
{
   return  -EBADF;
}

uintptr_t sys_mprotect(uintptr_t addr, size_t length, int prot)
{
   return  -EBADF;
}

uint64_t get_timer_value()
{
#if __riscv_xlen == 32
  while (1) {
    uint32_t hi = read_csr(mcycleh);
    uint32_t lo = read_csr(mcycle);
    if (hi == read_csr(mcycleh))
      return ((uint64_t)hi << 32) | lo;
  }
#else
  return read_csr(mcycle);
#endif
}


long sys_time(long* loc)
{
  long t = get_timer_value() / SYSCLK;
  if (loc) *loc = t;
 
  return t;
}

int sys_times(long* loc)
{
  uint64_t t=get_timer_value();
  loc[0] = t / (SYSCLK / 1000000);
  loc[1] = 0;
  loc[2] = 0;
  loc[3] = 0;
  
  return 0;
}

int sys_gettimeofday(long* loc)
{
uint64_t t=get_timer_value();
  loc[0]  = t / SYSCLK;
  loc[1] = (t % SYSCLK) / (SYSCLK / 1000000);
  
  return 0;
}



int sys_getdents(int fd, void* dirbuf, int count)
{
  return 0; //stub
}

static int sys_stub_success()
{
  return 0;
}

static int sys_stub_nosys()
{
  return -ENOSYS;
}

#define ARRAY_SIZE(x) (sizeof(x)/sizeof((x)[0]))

long do_syscall(long a0, long a1, long a2, long a3, long a4, long a5, unsigned long n)
{
  const static void* syscall_table[] = {
    [SYS_exit] = sys_exit,
    [SYS_exit_group] = sys_exit,
    [SYS_read] = sys_read,
    [SYS_pread] = sys_stub_nosys,
    [SYS_write] = sys_write,
    [SYS_openat] = sys_stub_nosys,
    [SYS_close] = sys_close,
    [SYS_fstat] = sys_fstat,
    [SYS_lseek] = sys_stub_nosys,
    [SYS_fstatat] = sys_stub_nosys,
    [SYS_linkat] = sys_stub_nosys,
    [SYS_unlinkat] = sys_stub_nosys,
    [SYS_mkdirat] = sys_stub_nosys,
    [SYS_renameat] = sys_stub_nosys,
    [SYS_getcwd] = sys_stub_nosys,
    [SYS_brk] = sys_brk,
    [SYS_uname] = sys_uname,
    [SYS_getpid] = sys_getpid,
    [SYS_getuid] = sys_getuid,
    [SYS_geteuid] = sys_getuid,
    [SYS_getgid] = sys_getuid,
    [SYS_getegid] = sys_getuid,
    [SYS_mmap] = sys_mmap,
    [SYS_munmap] = sys_munmap,
    [SYS_mremap] = sys_stub_nosys,
    [SYS_mprotect] = sys_stub_nosys,
    [SYS_rt_sigaction] = sys_stub_nosys,
    [SYS_gettimeofday] = sys_gettimeofday,
    [SYS_times] = sys_times,
    [SYS_writev] = sys_stub_nosys,
    [SYS_faccessat] = sys_stub_nosys,
    [SYS_fcntl] = sys_fcntl,
    [SYS_ftruncate] = sys_stub_nosys,
    [SYS_getdents] = sys_stub_nosys,
    [SYS_dup] = sys_stub_nosys,
    [SYS_readlinkat] = sys_stub_nosys,
    [SYS_rt_sigprocmask] = sys_stub_success,
    [SYS_ioctl] = sys_stub_nosys,
    [SYS_clock_gettime] = sys_stub_nosys,
    [SYS_getrusage] = sys_stub_nosys,
    [SYS_getrlimit] = sys_stub_nosys,
    [SYS_setrlimit] = sys_stub_nosys,
    [SYS_chdir] = sys_stub_nosys,
  };

  const static void* old_syscall_table[] = {
    [-OLD_SYSCALL_THRESHOLD + SYS_open] = sys_stub_nosys,
    [-OLD_SYSCALL_THRESHOLD + SYS_link] = sys_stub_nosys,
    [-OLD_SYSCALL_THRESHOLD + SYS_unlink] = sys_stub_nosys,
    [-OLD_SYSCALL_THRESHOLD + SYS_mkdir] = sys_stub_nosys,
    [-OLD_SYSCALL_THRESHOLD + SYS_access] = sys_stub_nosys,
    [-OLD_SYSCALL_THRESHOLD + SYS_stat] = sys_stub_nosys,
    [-OLD_SYSCALL_THRESHOLD + SYS_lstat] = sys_stub_nosys,
    [-OLD_SYSCALL_THRESHOLD + SYS_time] = sys_time,
  };

  syscall_t f = 0;

  if (n < ARRAY_SIZE(syscall_table))
    f = syscall_table[n];
  else if (n - OLD_SYSCALL_THRESHOLD < ARRAY_SIZE(old_syscall_table))
    f = old_syscall_table[n - OLD_SYSCALL_THRESHOLD];

  if (!f)
    printk("bad syscall #%ld!\n",n);

  return f(a0, a1, a2, a3, a4, a5, n);
}
