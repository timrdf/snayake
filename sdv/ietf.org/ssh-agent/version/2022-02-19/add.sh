#!/bin/bash
#
#3> @prefix doap:    <http://usefulinc.com/ns/doap#> .
#3> @prefix dcterms: <http://purl.org/dc/terms/> .
#3> @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
#3>
#3> <> dcterms:format <https://github.com/timrdf/csv2rdf4lod-automation/wiki/H0n3y-BadgeR> .
#3> <> a conversion:RetrievalTrigger, doap:Project; # Could also be conversion:Idempotent;
#3>    prov:specializationOf <sdv:timrdf.github.com/file-formats/2021-10-31>;
#3>                          <sdv:synology.com/DS1618+/2020-08-29>;
#3>    prov:hadDerivation  <sdv:timrdf.github.com/git-repos/2021-10-28>;
#3>    dcterms:description
#3>      "Script to retrieve and convert a new version of the dataset.";
#3>    rdfs:seeAlso
#3>      <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Automated-creation-of-a-new-Versioned-Dataset>,
#3>      <https://github.com/timrdf/csv2rdf4lod-automation/wiki/tic-turtle-in-comments>;
#3> .                                                                                                                    # width 132
# duck (water) => dodge (ball) => bounce

# TODO: determine $base and see if this parser vs. the client implementation differ.

# To install snayake, use:
# bash <(curl -s https://raw.githubusercontent.com/timrdf/snayake/main/sdv/timrdf.github.com/snayake/version/2021-11-05/retrieve.sh)
# per https://github.com/timrdf/snayake/blob/main/sdv/timrdf.github.com/snayake/version/2021-11-05/retrieve.sh#L23
#
# Whatever repo this is in could have additions that it wants to contribute back to snayake.
our_adds='timrdf.github.com/snayake/version/2021-11-05/manual/snayake/sdv'
# This is a written once
# when installing snayake
# and is not updated \./               our copy of what's on github \\..../// ($our_adds switches to /manual/)
for path in ../../../..  \
            ../../../../timrdf.github.com/snayake/version/2021-11-05/source/snayake/sdv \
            ../../../../$our_adds ; do
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

horizon=$(echo manual/some-repo/sdv/s/d/version/v/manual/distraction.sdv.webloc | awk -F "/" '{print NF - 2}') # 7
mkdir -p $samp && if find $samp -maxdepth $horizon -name "*.sdv.webloc" -exec false {} +; then
   scratch $sdv $samp # <- H0n3y-BadgeR.sh; ^^^ https://stackoverflow.com/a/41925756 ^^^
else
   for subject in `find $samp -maxdepth $horizon -name "*.sdv.webloc"`; do
      purr "$subject" # trims $subject's sdv.webloc and determines $iri and $alias

      # PHASE1 (a [Meta-] Retrieve)
      if [ ! -e "$properties" ]; then
         # Meta-Retrieve (this was always done out of band)
         echo                         "(+) $samp/$alias.properties"
         echo -e $tuft                  > "$samp/$alias.properties" #!/bin/bash + #3> turtle-in-comments on following line.
         echo "iri=$iri"               >> "$samp/$alias.properties" # Redundant w/ <alias>.sdv.webloc.
         for property in attribute1 attribute2 attribute3 attribute4; do
            # TODO: draw from an existing properties file to use the TiC to drive better dialog.
            read -p "Enter \"${alias#$samp/}\"'s $property: " value
            echo "#3> <#$property> prov:specializationOf <$iri/$property>;" >> "$samp/$alias.properties"
            echo '#3>     rdfs:comment "Describe it here." .'               >> "$samp/$alias.properties"
            echo "$property=$value"                                         >> "$samp/$alias.properties"
            echo                                                            >> "$samp/$alias.properties"
         done

         [ ! -e .gitignore ] && echo "(+) .gitignore" && touch .gitignore
         if ! grep -q "$samp/$alias.properties" .gitignore; then
            # Assume that some details should be left private,
            # and only way that we recognize localhost as the target
            # is if we have these properties defined AND they match.
            echo "(~) .gitignore"
            echo "$samp/$alias.properties" >> .gitignore
         fi
      elif [ -e "$properties" ]; then # else so that the developer can review the inputs before approving doing it by calling again.
         # TODO: inspect the "$alias.properties" for what properties it defines,
         # and if it's any more than what this script would auto-fill as a boilerplate,
         # re-write this script to add the variables to its interview for loop.

         # Retrieval trigger (traditional)
         splash "$properties" # This calls the https://github.com/timrdf/csv2rdf4lod-automation/wiki/H0n3y-BadgeR parser.
         # Determine output:
         outset="automatic/${subject#[^/]*/}" && outset=${outset%.properties} # => automatic/basement/nas
         # Auto-fill default inputs:
         foo=${foo:=7006}
         # All properties that were defined in the .properties are now declared as bash variables.
         >&2 echo "Make a clear and concise statement that states all required properties ${attribute1?$err}."
         >&2 echo "Multiple statements is okay, so that you can also mention that last property ${attribute3?$err}."
         >&2 echo "State where you are going to ${outset?$err}."

         if [ -n "${directory}" ]; then
            echo "do a thing"
         else
            echo "do different thing"

            # TODO: generalize this a little more.
            outset="automatic/${subject#[^/]*/}" && outset=${outset%.properties} # => automatic/basement/nas
            mkdir -p "$outset" && rm -f $outset/attribute9s
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
                      echo              "$ip" | tee -a $outset/attribute9s # For machine
                      echo -e "$tuft\nip=$ip" > $outset/$tally.properties  # and archival.
                      echo -e "$tuft\nip=$ip" > $outset.properties         # and archival.
                      #    ^^ https://stackoverflow.com/a/8467448
               fi
               ((host=host+1))
            done
         fi
      fi

      # Note that the subject.*.properties were loaded "For free" as we've progressed to this point.

	# TODO: this is all cargo cult.
	# TODO: this is all cargo cult.
	# TODO: this is all cargo cult.
	# TODO: this is all cargo cult.

      # TODO Choose a class name for the name of this stage, based on the type of thing that invoking the stage generates.
      #      \./    TODO: pick 1 \./        \./         \./         \./
      squat STAGE5 retrieval|preparation|computation|publication automatic # --> inset - outset - props - log - - - - -
      # d.b.a "Fhase5" -- "ya heard it here first, folks!"
      # Then you heard it [here](https://discord.com/channels/725148039647592544/725148775865385041/908350107529932811).
     #stage='STAGE5' && rpcb='retrieval|preparation|computation|publication' # - - - - - - - - - - - - - - - - - - - - -
      # Properties contains all *additional* information needed to conduct this stage. (~= inset and Function Parameters)
      # All prior properties from previous stages are still in scope
      # (so it's important to use distinct property names in each stage).
     #inset="$subject.$stage.i.properties" && splash "$inset"
      #                      ^^^^^^^^^^
      # file extension per https://github.com/timrdf/csv2rdf4lod-automation/wiki/BadgeP-Format#recommended-file-extension
      #                                                ||
      # Note that we want to be able to support knowing where $outset is (or should be) based on value(s) of $properties.
      # \./                                            \/
     #outset="$subject.$stage.o" && props="$outset.properties" && log="$outset.log"
     #echo -e "$div20\n$rpcb stage \"$stage\" will generate outset: $outset.*"
      if [ ! -e "$props" ] || [ ! -e "$log" ]; then
         if [ ! -e "$inset" ]; then
            read -p "Configure $stage? " configure
            if [ "$configure" == 'y' ]; then
               echo "What do we say here about PHASE5? or do we pass the phrase into scowl?"
               scowl "$inset" property1 property2 property3
            fi # TODO: pass in $base for ontology of these properties.
         else
            >&2 echo "Make a clear and concise statement that states all required properties ${property1?$err}."
            >&2 echo "Multiple statements is okay, so that you can also mention how you'll use ${property2?$err}."
            >&2 echo "Multiple statements is okay, so that you can also mention that last property ${property3?$err}."
            >&2 echo "State where you are going to ${outset?$err}." # Determined by squat() above.

            read -p "Execute $stage? [y/N] " execute
            if [ "$execute" == 'y' ]; then
               >&2 echo "Oh, bugger."
                   echo "A thing should be done here." | tee -a "$log"
                   echo -e "$tuft\greeting=hi"         | tee -a "$props"
                   #    ^^ https://stackoverflow.com/a/8467448
            fi
         fi
      else
         echo "Already generated at: $props"
      fi

   done
fi
