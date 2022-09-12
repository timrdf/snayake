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

target='timrdf.github.com/file-formats/version/2021-10-30/manual/H0n3y-BadgeR.sh'

# TODO: replace this loop with .well-known/sdv's multi-root access.
# What is available at https://github.com/timrdf/snayake/tree/main/sdv
pub_orig='timrdf.github.com/snayake/version/2021-11-05/source/snayake/sdv'
# Whatever repo this is in could have additions that it wants to contribute back to snayake.
our_adds='timrdf.github.com/snayake/version/2021-11-05/manual/snayake/sdv'
# This is a written once
# when installing snayake
# and is not updated \./               our copy of what's on github \\..../// ($our_adds switches to /manual/)
for path in ../../../..  \
            ../../../../$pub_orig \
            ../../../../$our_adds; do
   parser="$path/$target"
   if [ -e "$parser" ]; then
      root=$(pushd $(dirname "$parser") 2>&1>/dev/null && pwd)
      echo "Loading $(basename "$parser") from $root"
      source "$parser"
   else
      if [ -e "$path" ]; then
         root=$(pushd "$path" && pwd)
         echo "WARNING: did not find $target from $root"
      else
         echo "WARNING: $path does not exist to find $target."
      fi
   fi
done
echo "$div100"

# TODO: implement this fallback in cr-dataset-uri.sh and adopt it here.
iri=`cr-dataset-uri.sh --uri`
if [[ "$iri" == *CSV2RDF4LOD_BASE_URI* ]]; then
   # Fall back to sdv: scheme.
   iri=${iri##*CSV2RDF4LOD_BASE_URI#}
   iri=$(echo "$iri" | sed 's/.source./sdv:/; s/.dataset//; s/.version//')
fi
version_id=$(basename `pwd`)

samp='manual' # Manual is used b/c SUBJECTs are predominently direct-asserted.
horizon=$(echo manual/some-repo/sdv/s/d/version/v/manual/distraction.sdv.webloc | awk -F "/" '{print NF - 2}') # 7
mkdir -p $samp && if find $samp -maxdepth $horizon -name "*.sdv.webloc" -exec false {} +; then
   scratch $(sdv) $samp # <- H0n3y-BadgeR.sh; ^^^ https://stackoverflow.com/a/41925756 ^^^
   find $samp -maxdepth $horizon -name "*.sdv.webloc"
else
   for subject in `find $samp -maxdepth $horizon -name "*.sdv.webloc"`; do
      # Did not find any target repositories defined; define one to bootstrap this SDV.
      purr "$subject" # trims $subject's sdv.webloc and determines $iri and $alias

      squat remote retrieve manual # inset, outset, properties, and log
      if [ ! -e "$props" ] || [ ! -e "$log" ]; then
         if [ ! -e "$inset" ]; then
            read -p "Configure $stage? [y/N] " configure
            if [ "$configure" == 'y' ]; then
               echo "What do we say here about PHASE5? or do we pass the phrase into scowl?"
               # Preferred approach is to in richer metadata about the properties:
               scowls "$inset" homepage 'Git Repository homepage on the Web'      'http*'
               scowls "$inset" http     'The HTTP-based clone URL'                'http*'
               scowls "$inset" ssh      'a random thing that is also your choice' 'git@*'
            fi
         else
            #>&2 echo "Make a clear and concise statement that states all required properties ${property1?$err}."
            #>&2 echo "Multiple statements is okay, so that you can also mention how you'll use ${property2?$err}."
            #>&2 echo "Multiple statements is okay, so that you can also mention that last property ${property3?$err}."
            #>&2 echo "State where you are going to ${outset?$err}." # Determined by squat() above.

            #read -p "Execute $stage? [y/N] " execute
            #if [ "$execute" == 'y' ]; then
            #   >&2 echo "Oh, bugger."
            #       date +%Y-%m-%dT%H:%M:%S%z           | tee -a "$log"
            #       echo "A thing should be done here." | tee -a "$log"
            #       echo -e "$tuft\greeting=hi"         | tee -a "$props"
            #       #    ^^ https://stackoverflow.com/a/8467448
            #fi
            echo "MAKING LINK" | tee "$log"
            ln -sf "$(basename $inset)" "$properties"
         fi
         exit # TODO figure out how to encapsulate each stage and let them all run w/o this hard coded logic.
      else
         echo "Already generated at: $props"
      fi

      squat working-copy retrieve source # inset, outset, properties, and log
      if [ ! -e "$props" ] || [ ! -e "$log" ]; then
         if [ ! -e "$inset" ]; then
            read -p "Configure $stage? [y/N] " configure
            if [ "$configure" == 'y' ]; then
               http=$(bite $(glance remote manual properties) http)
               ssh=$(bite  $(glance remote manual properties) ssh)
               if [ -n "$http" ]; then
                  remote="$http"
               elif [ -n "$ssh" ]; then
                  remote="$ssh"
               fi
               echo "What do we say here about PHASE5? or do we pass the phrase into scowl?"
               scowls "$inset" remote 'Choose SSH or HTTP-based' "$http or $ssh"
               scowls "$inset" local  'Local name of working copy' "basename of $http or $ssh"
            fi
         else

            >&2 echo "State where you are going to ${outset?$err}." # Determined by squat() above.
            >&2 echo "Cloning ${remote?$err} to local working copy named ${local?$err}"

            read -p "Execute $stage? [y/N] " execute
            if [ "$execute" == 'y' ]; then
               #>&2 echo "Oh, bugger."
               #    date +%Y-%m-%dT%H:%M:%S%z           | tee -a "$log"
               #    echo "A thing should be done here." | tee -a "$log"
               #    echo -e "$tuft\greeting=hi"         | tee -a "$props"
                   #    ^^ https://stackoverflow.com/a/8467448

               dir=`basename ${remote%.git}`

               mkdir -p source && pushd source 2>&1 > /dev/null
                  dir=`basename ${remote%.git}`
                  echo "$dir"
                  if [ ! -e $dir ]; then

                     # https://stackoverflow.com/a/29754018
                     # export GIT_SSH_COMMAND='ssh -i private_key_file -o IdentitiesOnly=yes'
                     # git clone user@host:repo.git
                     # (will require password for the key file each time)

                     # https://stackoverflow.com/a/4565746
                     # ssh-agent $(ssh-add "$key"; git clone "$repo")
                     # (will only require the password for the key file the first time)

                     # https://stackoverflow.com/a/38474137
                     # A new configuration variable core.sshCommand has been added to specify what value for GIT_SSH_COMMAND to use per repository.
                     # cd /path/to/my/repo/already/cloned
                     # git config core.sshCommand 'ssh -i private_key_file'
                     #
                     # git -c core.sshCommand="ssh -i private_key_file" clone host:repo.git
                     # followed by the config set:
                     # git config core.sshCommand 'ssh -i private_key_file'

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
            fi # end if user confirm to execute
         fi # end if no inset
      else
         echo "Already generated at: $props"
      fi # end applicability on working-copy (props and log)
   done
fi

exit # TODO: port below up above.

if [ $# -gt 0 ]; then
   tag="$1"
   version_id="${tag#v}"
fi
