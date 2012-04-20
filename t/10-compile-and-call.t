use strict;
use warnings;

use Test::More tests => 2;
use Alien::FFCall;

# Needed for decently cross-platform compile tests
use lib qw(inc);
use Devel::CheckLib;

# Retrieve the Alien::FFCall configuration:
my $alien = Alien::FFCall->new;
my $compiler_flags = $alien->cflags();
my $linker_flags = $alien->libs();

my $result;

### 1: Simply asserts that the library exists and avcall.h can be loaded
$result = check_lib(
	LIBS => $linker_flags,
	INC => $compiler_flags,
	header => 'avcall.h',
);
ok($result, 'Linked against avcall.h');

### 1: Check the ability to call a function with avcall

# Remove -lcallback from linker flags for this one:
my $avcall_linker_flags = $linker_flags;
$avcall_linker_flags =~ s/-lcallback//;

# This grossly abuses CheckLib based on inspection of the internals in order to
# inject a function definition before the definition of main(). However, I need
# such a function so that I can easily test the av functions.
$result = check_lib(
	LIBS => $avcall_linker_flags,
	INC => $compiler_flags,
	header => q{avcall.h>
		int double_it(int input) {
			return input * 2;
		}
		/* finish the injection with a #define that's never used :-) */
		#define my_foobar(value) include <value.h},
	function => q{
		/* Build an av_list to call double_it */
		int the_return;
		av_alist av;
		
		/* Start the av_list with the function pointer and the address where we
		 * want to store the return value */
		av_start_int(av, double_it, &the_return);
		av_int(av, 5);
		
		/* croak out if the call failed or if it returned the wrong value */
		if (av_call(av) != 0) return 1;
		if (the_return != 10) return 1;
		
		return 0;
	},
);

ok($result, 'Can use av_list, av_start_int, av_int, and av_call');
