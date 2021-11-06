#!/bin/bash
#
#3> @prefix doap:    <http://usefulinc.com/ns/doap#> .
#3> @prefix dcterms: <http://purl.org/dc/terms/> .
#3> @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
#3>
#3> <> a conversion:RetrievalTrigger, doap:Project; # Could also be conversion:Idempotent;
#3>    prov:specializationOf <sdv:timrdf.github.com/git-repos/2021-10-28>;
#3>    dcterms:description
#3>      "Script to retrieve and convert a new version of the dataset.";
#3>    prov:wasDerivedFrom <sdv:timrdf.github.com/file-formats/2021-10-31>;
#3>    rdfs:seeAlso
#3>      <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Automated-creation-of-a-new-Versioned-Dataset>,
#3>      <https://github.com/timrdf/csv2rdf4lod-automation/wiki/tic-turtle-in-comments>;
#3> .
#
# How to use this generic behavior:
#
# 1) cd to a cr:conversion-cockpit e.g. sdv/timrdf.github.com/DataFAQs/version/2021-10-31
#    For version identifier, choose either a "created today" or, determine the repo's initial commit date and use that.
# 2) Create retrieve.sh and inside define it as a bash script and have it invoke this script that you're currently reading.
#       bash-3.2$ cat retrieve.sh
#       #!/bin/bash
#       path-to/data/source/timrdf.github.com/git-repos/version/2021-10-28/manual/retrieve.sh
# 3) Invoke it:
#       ./retrieve.sh

source ../../../file-formats/version/2021-10-30/manual/H0n3y-BadgeR.sh

# TODO: implement this fallback in cr-dataset-uri.sh and adopt it here.
iri=`cr-dataset-uri.sh --uri`
if [[ "$iri" == *CSV2RDF4LOD_BASE_URI* ]]; then
   # Fall back to sdv: scheme.
   iri=${iri##*CSV2RDF4LOD_BASE_URI#}
   iri=$(echo "$iri" | sed 's/.source./sdv:/; s/.dataset//; s/.version//')
fi
version_id=$(basename `pwd`)

samp='manual' # Manual is used b/c SUBJECTs are predominently direct-asserted.
mkdir -p $samp && if find $samp -name "*.sdv.webloc" -exec false {} +; then # <= https://stackoverflow.com/a/41925756
   # Did not find any target repositories defined; define one to bootstrap this SDV.

   # TODO: search+replace 'repository' with the type of thing that you're processing (e.g. user, repository, device, etc.).

   read -p "No repositories found. Define this repository? [y/N] " define
   if [ 'y' == "$define" ]; then
      read -p "Enter alias for repository (or hit return to default to repository): " alias
      alias="${alias:='repository'}"

      echo                         "(+) $samp/$alias.sdv.webloc"
      echo '<?xml version="1.0" encoding="UTF-8"?>'                                                                  > "$samp/$alias.sdv.webloc"
      echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> "$samp/$alias.sdv.webloc"
      echo '<plist version="1.0">'                                                                                  >> "$samp/$alias.sdv.webloc"
      echo '<dict>'                                                                                                 >> "$samp/$alias.sdv.webloc"
      echo '   <key>URL</key>'                                                                                      >> "$samp/$alias.sdv.webloc"
      echo "   <string>$iri</string>"                                                                               >> "$samp/$alias.sdv.webloc"
      echo '</dict>'                                                                                                >> "$samp/$alias.sdv.webloc"
      echo '</plist>'                                                                                               >> "$samp/$alias.sdv.webloc"
      # The <alias>.{sdv.webloc, properties} pair allows "drag around" citation (with the former) and richer processing (with the latter).
      echo                         "(+) $samp/$alias.properties"
      echo -e $tuft                  > "$samp/$alias.properties" #!/bin/bash + #3> turtle-in-comments on following line.
      echo "iri=$iri"               >> "$samp/$alias.properties" # Redundant w/ <alias>.sdv.webloc.
      read -p "Enter \"$alias\"'s homepage: "           homepage
      read -p "Enter \"$alias\"'s http: "               http
      read -p "Enter \"$alias\"'s ssh (or hit enter): " ssh
      echo "homepage=$homepage" >> "$samp/$alias.properties"
      echo "http=$http"         >> "$samp/$alias.properties"
      echo "ssh=$ssh"           >> "$samp/$alias.properties"

      [ ! -e .gitignore ] && echo "(+) .gitignore" && touch .gitignore
      if ! grep -q "$samp/$alias.properties" .gitignore; then
         # Assume that some details should be left private,
         # and only way that we recognize localhost as the target
         # is if we have these properties defined AND they match.
         echo "(~) .gitignore"
         echo "$samp/$alias.properties" >> .gitignore
      fi
   fi
else
   for repository in `find $samp -name "*.sdv.webloc"`; do
      # Found a repository according to the <alias>.{sdv.webloc, properties} naming conventions.
      alias=${repository%.sdv.webloc} && properties="$alias.properties"
      splash "$properties" # This calls the https://github.com/timrdf/csv2rdf4lod-automation/wiki/H0n3y-BadgeR parser.
      foo=${foo:=7006}     # auto-fill a default.
      # All properties that were defined in the .properties are now declared as bash variables.
      >&2 echo "Make a clear and concise statement that states all required properties ${homepage?$err}@${http?$err}."
      >&2 echo "Multiple statements is okay, so that you can also mention that last property ${ssh?$err}."

      if [ -n "$http" ]; then
         remote="$http"
      elif [ -n "$ssh" ]; then
         remote="$ssh"
      fi

      if [ -n "$remote" ]; then
         dir=`basename ${remote%.git}`

         mkdir -p source && pushd source 2>&1 > /dev/null
            dir=`basename ${remote%.git}`
            echo "$dir"
            if [ ! -e $dir ]; then
               git clone "$remote" "$dir"
               echo "source/$(dirname "$dir")" >> .gitignore
            else
               pushd "$dir" 2>&1 > /dev/null # https://stackoverflow.com/a/23245064 showed the %02i trick to zero-pad.
                  initial_date=$(git log | grep "^Date:" | tail -1 | awk '{num["Jan"]="01";num["Feb"]="02";num["Mar"]="03";num["Apr"]="04";num["May"]="05";num["Jun"]="06";num["Jul"]="07";num["Aug"]="08";num["Sep"]="09";num["Oct"]="10";num["Nov"]="11";num["Dec"]="12";printf("%s-%s-%02i\n",$6,num[$3],$4)}')
                  # Date:   Mon Oct 31 15:21:31 2011 -0400
                  initial_commit=$(git log | grep "^commit" | tail -1 | awk '{print $2}')
                  # commit 3f2781b671535e111beba3c884361e5aa4c92db2
                  echo "Initial commit $initial_commit was on $initial_date."

                  main=$(git status | grep 'On branch' | awk '{print $3}')
                  # On branch master
                  echo "Main branch from commit was \"$main\"."

                  latest_date=$(git log | grep "^Date:" | head -1 | awk '{num["Jan"]="01";num["Feb"]="02";num["Mar"]="03";num["Apr"]="04";num["May"]="05";num["Jun"]="06";num["Jul"]="07";num["Aug"]="08";num["Sep"]="09";num["Oct"]="10";num["Nov"]="11";num["Dec"]="12";printf("%s-%s-%02i\n",$6,num[$3],$4)}')
                  echo "Lateest commit was on $latest_date."

                  echo "Current SDV version identifier: $version_id."

                  if [ ! -e ../../$initial_date ]; then
                     echo "SDV does not exist for initial commit $initial_date."
                     # TODO: offer to establish
                  fi

                  if [ ! -e ../../$latest_date ]; then
                     echo "SDV does not exist for initial commit $latest_date."
                     # TODO: offer to establish
                  fi

                  if [ -z "$main_branch" ]; then
                     read -p  "\"$alias\" has not defined its main branch in $properties, set it to $main? [y/N] " define
                     if [ 'y' == "$define" ]; then
                        echo "okay"
                     fi
                  else
                     git checkout $main_branch
                     git pull
                     git log | head -10
                  fi

                  if [ ! -z "$tag" ]; then
                     echo "I want $tag"
                     git rev-parse --verify $tag
                     if [ $? ]; then
                        git checkout                "$tag"
                     else
                        git checkout tags/"$tag" -b "$tag"
                     fi

                     # TODO: generalize view-making.
                     #echo "looking at:"
                     #ls ../../../
                     #base="../../../$version_id/source"
                     #for ttl in `find .  -name "*.ttl" | sed 's/^\.\///'`; do
                     #   to="$base/`basename $dir`/`dirname "$ttl" | sed 's/\.$//'`"
                     #   mkdir -p "$to"
                     #   echo cp $ttl "$to" # NOTE: a trailing newline kills MD5s in Windows land.
                     #        cp $ttl "$to"
                     #done
                  else
                     echo
                     echo "# # Select a tag to form a version out of: # #"
                     echo
                     git tag
                  fi
               popd 2>&1 > /dev/null
            fi
         popd 2>&1 > /dev/null

         [ ! -e .gitignore ] && echo "(+) .gitignore" && touch .gitignore
         if ! grep -q "source/$dir" .gitignore; then
            # Avoid committing the git repo into our own.
            echo "(~) .gitignore"
            echo "source/$dir" >> .gitignore
         fi

      else
         # TODO: adopt this boilerplate or throw it away.
         outset="automatic/${repository#[^/]*/}" && outset=${outset%.properties} # => automatic/basement/nas
         mkdir -p "$outset" && rm -f $outset/attribute4s
         tally=0 # of num_wires plugged into NAS interfaces.
         host=0  # 4th quad of IP to probe within $network's first 3 quads.
         error=$CURLE_COUNDT_CONNECT # Anything but CURLE_PEER_FAILED_VERIFICATION
         until [ "$tally" -eq "${num_wires:=1}" ]; do
            ip="$network.$host" && addr="$ip:$dsm" && url="https://$addr"
            curl -s --max-time 1 "$url" 2>&1 > /dev/null
            error=$?
            >&2 echo "$host -> $error" # https://stackoverflow.com/a/23550347
            if [ "$CURLE_PEER_FAILED_VERIFICATION" -eq "$error" ]; then
               ((tally=tally+1))
               >&2 echo "$url"                                  # For human staring at console.
                   echo              "$ip" | tee -a $outset/attribute4s # For machine
                   echo -e "$tuft\nip=$ip" > $outset/$tally.properties  # and archival.
                   echo -e "$tuft\nip=$ip" > $outset.properties         # and archival.
                   #    ^^ https://stackoverflow.com/a/8467448
            fi
            ((host=host+1))
         done

      fi
   done
fi

exit # TODO: port below up above.

if [ $# -gt 0 ]; then
   tag="$1"
   version_id="${tag#v}"
fi
