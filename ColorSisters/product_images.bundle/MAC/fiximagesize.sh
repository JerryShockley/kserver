#! /bin/sh
# This command will clip all the images supplied on the command line to the same
# dimensions; this is appropriate for MAC liquid foundation images downloaded
# from their web site. Tested on images for "Pro Longwear Foundation" and also
# "Studio Fix Fluid".
mogrify -density 72 -crop 150x315+30 $*
