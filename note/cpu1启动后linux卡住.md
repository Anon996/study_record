```
Nasty bug but trivial fix for this.  What happens here is RAX (nsecs)
gets set to a huge value (RAX = 0x17AE7F57C671EA7D) and passed through
a bunch of macros to __iter_div_u64_rem().  It doesn't loop infinitely
with a number that big, just for about 4 minutes but long enough for
the hard lockup detector to fire off.  Setting RAX=0 when this bug
occurs clears the problem from the debugger console when this function
gets stuck in this loop and the system recovers fine.

The problem code is in:

include/linux/math64.h:117
static __always_inline u32
__iter_div_u64_rem(u64 dividend, u32 divisor, u64 *remainder)
{
	u32 ret = 0;

	while (dividend >= divisor) {
		/* The following asm() prevents the compiler from
		   optimising this loop into a modulo operation.  */
		asm("" : "+rm"(dividend));

		dividend -= divisor;
		ret++;
	}
	*remainder = dividend;

	return ret;
}

which is called by
include/linux/time.h:233
static __always_inline void timespec_add_ns(struct timespec *a, u64 ns)
{
	a->tv_sec += __iter_div_u64_rem(a->tv_nsec + ns, NSEC_PER_SEC, &ns);
	a->tv_nsec = ns;
}

it's defined so that timespec64_add_ns just points to this function
which is called by ktime_get_ts64.  tv_nsec + ns gets passed as a huge
number (RAX = 0x17AE7F57C671EA7D) with a very small divisor and just
sits there and loops.

Submitting a patch to fix this after I regress and test it.   Since it
makes no sense to loop on a simple calculation, fix should be:

static __always_inline void timespec_add_ns(struct timespec *a, u64 ns)
{
	a->tv_sec += div64_u64_rem(a->tv_nsec + ns, NSEC_PER_SEC, &ns);
	a->tv_nsec = ns;
}

Jeff
```