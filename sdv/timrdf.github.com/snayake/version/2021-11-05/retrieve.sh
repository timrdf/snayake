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

if [ -e ../../../git-repos/version/2021-10-28/manual/retrieve.sh -a -e manual/snayake.sdv.webloc \
                                                                 -a -e manual/snayake.properties ]; then
   ../../../git-repos/version/2021-10-28/manual/retrieve.sh
else
   mkdir -p manual && s='https://raw.githubusercontent.com/timrdf/snayake/main/sdv/timrdf.github.com'
   parser='../../../file-formats/version/2021-10-30/manual/H0n3y-BadgeR.sh'
   if [ ! -e $parser ]; then
      mkdir -p $(dirname $parser)
      echo $s/file-formats/version/2021-10-30/manual/H0n3y-BadgeR.sh
      curl $s/file-formats/version/2021-10-30/manual/H0n3y-BadgeR.sh > $parser
   fi

   curl $s/snayake/version/2021-11-05/manual/snayake.sdv.webloc > manual/snayake.sdv.webloc
   curl $s/snayake/version/2021-11-05/manual/snayake.properties > manual/snayake.properties
   curl $s/git-repos/version/2021-10-28/manual/retrieve.sh > retrieve.sh && chmod +x retrieve.sh

   h='https://raw.githubusercontent.com/timrdf/snayake/main/sdv/timrdf.github.com/git-repos/version/2021-10-28/manual/retrieve.sh'
   runit='no' #                 \\             ||               //
   if [ `md5 -q retrieve.sh` == 'c8d381b70dc09f08fcc1736243974ee1' ]; then
      read -p 'Retrieval digest matches, run it? [y/N] ' runit
   else
      echo && echo
      echo    ' * *   * * ***   * * * * * * * *   *** * **** **'
      echo    "   $h"
      echo    ' *  **  ** * *   *  **   ***  *  *  ***  **'
      echo    'WARNING:'
      read -p 'WARNING: Retrieval digest - DOES - NOT - match. Run it anyway? [y/N] ' runit
      echo
   fi

   if [ "$runit" == 'y' ]; then
      ./retrieve.sh
   fi
fi
