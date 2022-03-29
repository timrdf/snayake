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
      purr "$subject" # trims $subject and determines $iri and $alias

      stage='publish' && rpcb='publication' # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      inset="$subject.$stage.i.properties" && [ -e "$inset" ] && splash "$inset"
      outset="$subject.$stage.o" && props="$outset.properties" && log="$outset.log"
      echo -e "$div20\n$rpcb stage \"$stage\" will generate outset: $outset.*"
      if [ ! -e "$props" ] || [ ! -e "$log" ]; then
         if [ ! -e "$inset" ]; then
            # Determine necessary inputs from out-of-band.
            read -p "Configure $stage? " configure
            if [ "$configure" == 'y' ]; then
               echo "What do we say here about PHASE5? or do we pass the phrase into scowl?"
               scowl "$inset" authorized_contribution_branch submission_remote use_feature_branch
            fi
         else
            current_branch=$(git status | grep '^On branch ' | sed 's/On branch *//')
            # Act based on the given inputs.
            >&2 echo "Will look for authorized contributions in manual/ on ${authorized_contribution_branch?$err}."
            >&2 echo "If authorized contributions exist, will push back to git remote ${submission_remote?$err}."
            >&2 echo "Will use feature branch: ${use_feature_branch?$err}"
            >&2 echo "State where you are going to ${outset?$err}."

            read -p "Execute $stage? [y/N] " execute
            if [ "$execute" == 'y' ]; then
               if [ "$current_branch" == "$authorized_contribution_branch" ]; then
                  # TODO: if ?use_feature_branch then create one

                 #echo hi          | tee -a "$log"
                 #echo greeting=hi | tee -a "$props"
                  # TODO: if no paths given, then go find them.
                  while [[ $# -gt 0 ]]; do
                     # The internally-developed component that is ready to contribute back.
                     # e.g. manual/snayake/sdv/timrdf.github.com/git-repos/version/versions.md
                     contribution="$1" && shift

                     # Where we need to place so that we can commit and push it back.
                     # e.g. manual/snayake/sdv/timrdf.github.com/git-repos/version/versions.md
                     external="source${contribution#manual}"

                     # Note that we assume that NO uncommitted work is done in source/,
                     # and we intentionally overwrite whatever might happen to be there.
                     echo "$external <-- $contribution"
                     mkdir -p $(dirname "$external")
                     cp "$contribution" "$external"

                     # TODO git add "$external"
                  done

                  pushd source/snayake 2>&1>/dev/null # TODO: hard coded repo name is bad.
                     git status
                  popd 2>&1>/dev/null

                  # Leave committing, adding, and pushing to be a manual task.
               else
                  echo "WARNING: current branch ($current_branch) is not authorized to contribute back; must be $authorized_contribution_branch"
               fi
            fi
         fi
      else
         echo "Already generated at: $props"
      fi

   done
fi
