#! /bin/csh -f
#
#

@ number = 0
while ($number <= 99)
    damage_test -b2.0 -c14.81 -d642 -e850 -m355 -p9040 -r124 -t2.5
    sleep 1
    @ number++
end
