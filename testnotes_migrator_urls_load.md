Full process on test
===

You just had :
	14644 mapping created
	3 errors
	37 URLs that existed
	14684 mappings processed
rake tast completed

real	86m8.276s
user	54m3.580s
sys	1m26.130s


=== 

Test on 100

You just had :
	99 mapping created
	0 errors
	1 URLs that existed
	14684 mappings processed
rake tast completed

real	0m14.528s
user	0m7.440s
sys	0m1.170s

===

Test on 100 - skipping Mapping.create

You just had :
	0 mapping created
	0 errors
	0 URLs that existed
	14684 mappings processed
rake tast completed

real	0m9.646s
user	0m5.930s
sys	0m1.010s

===

Test on 100 - skipping the exists check

You just had :
	100 mapping created
	0 errors
	0 URLs that existed
	14684 mappings processed
rake tast completed

real	0m12.513s
user	0m7.370s
sys	0m1.220s


===

Test on 100 - as above + not setting 'title' in the Mongoid.create block

You just had :
	100 mapping created
	0 errors
	0 URLs that existed
	14684 mappings processed
rake tast completed

real	0m12.624s
user	0m7.450s
sys	0m1.110s

===




