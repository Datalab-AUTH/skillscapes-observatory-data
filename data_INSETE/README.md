# INSETE Data

These data are from [INSETE https://insete.gr/districts/?lang=en].

There are 13 xlsx files, one for each region, download them all. Then run
the `data_INSETE_preprocess.py` script. This will create respective
csv files in the same directory.

The `data_INSETE_preprocess.py` script should be somewhat future-proof, but
the formatting may change, so it may need some fixing. Already, some of the
sheet names are not consistent between regions, eg:
* "Short stay_Arriv-overnights"
* "Short stay_ Arriv-Overnights"
* "Short stay_Arriv-Overnights"
etc...

The `data_prep/INSETE.R` file further processes these csv files and adds
the final data in the sqlite database.
