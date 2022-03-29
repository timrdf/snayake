#!/bin/bash
#
#3> @prefix doap:    <http://usefulinc.com/ns/doap#> .
#3> @prefix dcterms: <http://purl.org/dc/terms/> .
#3> @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
#3>
#3> <> dcterms:format <https://github.com/timrdf/csv2rdf4lod-automation/wiki/H0n3y-BadgeR> .
#3> <> a conversion:RetrievalTrigger, doap:Project; # Could also be conversion:Idempotent;
#3>    prov:specializationOf <sdv:timrdf.github.com/file-formats/2021-10-31>;
#3>    prov:wasDerivedFrom <sdv:onthecurb.io/sdv-roots/2020-08-23>,
#3>                        <sdv:onthecurb.io/sdv-roots/2020-08-28>,
#3>                        <sdv:synology.com/DS1618+/2020-08-29>;
#3>    prov:hadDerivation  <sdv:timrdf.github.com/git-repos/2021-10-28>;
#3>    dcterms:description
#3>      "Script to retrieve and convert a new version of the dataset.";
#3>    rdfs:seeAlso
#3>      <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Automated-creation-of-a-new-Versioned-Dataset>,
#3>      <https://github.com/timrdf/csv2rdf4lod-automation/wiki/tic-turtle-in-comments>;
#3> .

# To install snayake, use:
# bash <(curl -s https://raw.githubusercontent.com/timrdf/snayake/main/sdv/timrdf.github.com/snayake/version/2021-11-05/retrieve.sh)
# per https://github.com/timrdf/snayake/blob/main/sdv/timrdf.github.com/snayake/version/2021-11-05/retrieve.sh#L23
#
# This is a written once
# when installing snayake
# and is not updated \./                                                                                    and this \./ gets updates via git pulls (retrieval trigger?).
for path in ../../../..  \
            ../../../../timrdf.github.com/snayake/version/2021-11-05/source/snayake/sdv/ \
            ../../../../timrdf.github.com/snayake/version/2021-11-05/manual/snayake/sdv/; do
   rel=timrdf.github.com/file-formats/version/2021-10-30/manual/H0n3y-BadgeR.sh
   parser=$path/$rel
   if [ -e $parser ]; then
      root=$(pushd $(dirname "$parser") 2>&1>/dev/null && pwd)
      echo "Loading $(basename "$parser") from $root"
      source $parser
   else
      if [ -e "$path" ]; then
         root=$(pushd "$path" && pwd)
         echo "WARNING: did not find $rel from $root"
      else
         echo "WARNING: $path does not exist to find $rel."
      fi
   fi
done
echo "$div100"

# TODO: implement this fallback in cr-dataset-uri.sh and adopt it here.
sdv=`cr-dataset-uri.sh --uri`
if [[ "$sdv" == *CSV2RDF4LOD_BASE_URI* ]]; then
   # Fall back to sdv: scheme.
   sdv=${sdv##*CSV2RDF4LOD_BASE_URI#}
   sdv=$(echo "$sdv" | sed 's/.source./sdv:/; s/.dataset//; s/.version//')
fi
#sdv=$(pwd | awk -v baseURI=${CSV2RDF4LOD_BASE_URI:"TODO fail here"} -F "/" \
#    '{printf("%s/source/%s/dataset/%s/version/%s",baseURI,$(NF-3),$(NF-2),$NF)}')

samp='manual' # Manual is used b/c subjects are predominently direct-asserted.

# TODO: find a place for 08-29's:
# if [ 'test' == "$1" ]; then

horizon=7 # avoids manual/some-repo/sdv/source-id/dataset-id/version/version-id/manual/distraction.sdv.webloc
mkdir -p $samp && if find $samp -maxdepth $horizon -name "*.sdv.webloc" -exec false {} +; then # <= https://stackoverflow.com/a/41925756
   # Did not find any target subjects defined; define one to bootstrap this SDV.
   read -p "No subjects found. Define this subject? [y/N] " define
   if [ 'y' == "$define" ]; then
      read -p "Enter alias for subject (or hit return to default to subject.{sdv.webloc, properties}): " alias
      # Entered value may contain path steps e.g. 'texas/phil' ------------------------------------------^^^^^
      alias="${alias:=subject}"
      iri="$sdv/$alias"
      mkdir -p "$samp/$(dirname "$alias")" &&                                                                 echo "(+) $samp/$alias.sdv.webloc"
      echo '<?xml version="1.0" encoding="UTF-8"?>'                                                                  > "$samp/$alias.sdv.webloc"
      echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> "$samp/$alias.sdv.webloc"
      echo '<plist version="1.0">'                                                                                  >> "$samp/$alias.sdv.webloc"
      echo '<dict>'                                                                                                 >> "$samp/$alias.sdv.webloc"
      echo '   <key>URL</key>'                                                                                      >> "$samp/$alias.sdv.webloc"
      echo "   <string>$iri</string>"                                                                               >> "$samp/$alias.sdv.webloc"
      echo '</dict>'                                                                                                >> "$samp/$alias.sdv.webloc"
      echo '</plist>'                                                                                               >> "$samp/$alias.sdv.webloc"
      # The <alias>.{sdv.webloc, properties} pair allows "drag around" citation (with the former) and richer processing (with the latter).
   fi
else
   for subject in `find $samp -maxdepth $horizon -name "*.sdv.webloc"`; do
      iri=$(grep -A1 URL "$subject" | tail -1 | sed 's/^.*<string>//;s/<.string>*$//')
      # Found a subject according to the <alias>.{sdv.webloc} naming conventions.
      # \./ is a relative base to find any number of <alias>.*.properties about the subject.
      subject=${subject%.sdv.webloc} # e.g. 'manual/texas/phil' (includes full relative path [to other common files]).
      alias=${subject#${samp}/}      # e.g.        'texas/phil' (strips away the pragmatic file path stuff)
      echo "$subject* files are about \"$alias\" i.e. $iri:"
      find $(dirname "$subject") -name "$(basename "$subject")*"

      stage='internal' && rpcb='preparation' # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      inset="$subject.$stage.i.properties" && [ -e "$inset" ] && splash "$inset"
      outset="$subject.$stage.o" && props="$outset.properties" && log="$outset.log"
      echo -e "$div20\n$rpcb stage \"$stage\" generates outset: $outset.*"
      if [ ! -e "$outset.properties" ]; then
         if [ ! -e "$inset" ]; then
            # Determine necessary inputs from out-of-band.
            read -p "Configure $stage? " configure
            if [ "$configure" == 'y' ]; then
               echo "What do we say here about PHASE5? or do we pass the phrase into scowl?"
               scowl "$inset" template
            fi
         else
            # Act based on the given inputs.
            >&2 echo "Establish an internal development of a trigger for each file path provided as an argument."
            >&2 echo "If that path exists, that will be used as the template; o/w ${template?$err} will be used."
           #>&2 echo "State where you are going to ${outset?$err}."

            read -p "Execute $stage? [y/N] " execute
            if [ "$execute" == 'y' ]; then
               #   echo hi          | tee -a "$log"
               #   echo greeting=hi | tee -a "$props"

               # Reference something within source/ (whether it's there or not) and establish it within manual/.
               # If it's there, just copy it over and if it's not there then copy the H0n3y-BadgeR template
               # to the corresponding path in manual/.
               #
               # Usage:
               # ./prepare.sh source/snayake/sdv/timrdf.github.com/git-repos/version/2021-10-28/prepare.sh
               #          ==> manual/snayake/sdv/timrdf.github.com/git-repos/version/2021-10-28/prepare.sh
               while [[ $# -gt 0 ]]; do
                  # Where we are planning to place it once we publish it back to snayake's Github.
                  # This reference can exist or be hypothetical (as it'll exist eventually).
                  # e.g. source/snayake/sdv/timrdf.github.com/git-repos/version/2021-10-28/prepare.sh
                  contribution="$1" && shift

                  # Where we are going to develop it for our purposes before we contribute it back.
                  # e.g. manual/snayake/sdv/timrdf.github.com/git-repos/version/2021-10-28/prepare.sh
                  internal="manual${contribution#source}"
                  if [ ! -e "$internal" ]; then
                     [ -e "$contribution" ] && template="$contribution" # Overrides .properties

                     echo "$internal <-- $template"
                     mkdir -p $(dirname "$internal")
                     cp   "$template"   "$internal"
                  else
                     echo "$internal"
                  fi

                  # publish.sh will copy manual/ back to source/ and push a feature branch for review
                  # and acceptance within https://github.com/timrdf/snayake/pulls.
               done
            fi
         fi
      else
         echo "Already generated at: $props"
      fi

   done
fi
