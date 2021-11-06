#!/bin/bash
#
#3> @prefix doap:    <http://usefulinc.com/ns/doap#> .
#3> @prefix dcterms: <http://purl.org/dc/terms/> .
#3> @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
#3>
#3> <> a conversion:RetrievalTrigger, doap:Project; # Could also be conversion:Idempotent;
#3>    prov:specializationOf <https://github.com/timrdf/snayake/blob/main/sdv/timrdf.github.com/snayake/version/2021-11-05/retrieve.sh>;
#3>    dcterms:description
#3>      "Script to retrieve and convert a new version of the dataset.";
#3>    rdfs:seeAlso
#3>      <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Automated-creation-of-a-new-Versioned-Dataset>,
#3>      <https://github.com/timrdf/csv2rdf4lod-automation/wiki/tic-turtle-in-comments>;
#3> .

f='../../..' # as in (local) 'file' as opposed to 'http'.
if [ ! -e /dev/null ]; then # always false; self-documentation for how to use this script as a bootstrap.

   # If you do not have https://github.com/timrdf/snayake.git,
   # then make sure that you're in a working directory such as:
   #    timrdf.github.com/snayake/version/<version-id> (default: 2021-11-05)
   # then run this:                                                   $h=$f/
   bash <(curl -s https://raw.githubusercontent.com/timrdf/snayake/main/sdv/timrdf.github.com/snayake/version/2021-11-05/retrieve.sh)
   # ^^^^^ thx, https://stackoverflow.com/a/5735767

elif [ -e $f/git-repos/version/2021-10-28/manual/retrieve.sh -a -e manual/snayake.sdv.webloc \
                                                             -a -e manual/snayake.properties ]; then
   $f/git-repos/version/2021-10-28/manual/retrieve.sh # Bootstrap is not needed.
else
   trigger='git-repos/version/2021-10-28/manual/retrieve.sh'
   for dependency in file-formats/version/2021-10-30/manual/H0n3y-BadgeR.sh \
                     $trigger; do
      if [ ! -e $f/$dependency ]; then
         mkdir -p $(dirname $f/$dependency)
         h='https://raw.githubusercontent.com/timrdf/snayake/main/sdv/timrdf.github.com' # as in 'http' as opposed to 'f'.
         echo $h/$dependency
         curl $h/$dependency > $f/$dependency && chmod +x $f/$dependency
      fi
   done

   mkdir -p manual
   curl $h/snayake/version/2021-11-05/manual/snayake.sdv.webloc > manual/snayake.sdv.webloc
   curl $h/snayake/version/2021-11-05/manual/snayake.properties > manual/snayake.properties
   echo -e "#!/bin/bash\n$f/$trigger" > retrieve.sh && chmod +x retrieve.sh # < reads ^

   h='https://raw.githubusercontent.com/timrdf/snayake/main/sdv/timrdf.github.com/git-repos/version/2021-10-28/manual/retrieve.sh'
   echo "$h"  #      \\         ||           //
   runit='no' #       \\        ||          //
   verified='a2125778d330b074e1cce21a284bdb71'
   if [ `md5 -q $f/$trigger` == $verified ]; then
      read -p 'Retrieval digest matches, run it? [y/N] ' runit
   else
      echo
      echo    ' * *   * * ***   * * * * * * * *   *** * **** **'
      echo    ' *  **  ** * *   *  **   ***  *  *  ***  **'
      echo    "$f/$trigger is $(md5 -q $f/$trigger) but expected $verified"
      echo    'WARNING:'
      read -p 'WARNING: Retrieval digest - DOES - NOT - match. Run it anyway? [y/N] ' runit
      echo
   fi

   if [ "$runit" == 'y' ]; then
      ./retrieve.sh
   fi
fi
