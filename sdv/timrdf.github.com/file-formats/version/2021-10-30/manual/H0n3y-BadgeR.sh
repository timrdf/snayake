#!/bin/bash
#3> <>
#3> prov:specializationOf
#3>    <https://github.com/timrdf/snayake/blob/main/sdv/timrdf.github.com/file-formats/version/2021-10-30/manual/H0n3y-BadgeR.sh>;
#3> prov:wasDerivedFrom
#3>    <https://github.com/timrdf/csv2rdf4lod-automation/wiki/H0n3y-BadgeR> .                                          # width 132

# pretty printing
div20='- - - - - - - - - -'
div40='- - - - - - - - - - - - - - - - - - - -'
div80='- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -'
div100='- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -'
div120='- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -'
div="$div80"

# TODO: determine $base and see if this parser vs. the client implementation differ.
base=$(cd `dirname "$0"` && pwd) # https://stackoverflow.com/a/2757938
# ^ i.e. 'timrdf.github.com/file-formats/version/2021-10-30/manual'

sdv () {
   # Determine the SDV IRI based on shell environment variables and the current working directory.
   #
   # Inputs:
   #   (optional) path - e.g. /Users/you/us/shadow-ops/bitbucket/otega/data/source/timrdf/sense-making/version/friday
   #                   - If omitted, uses current working directory (via pwd).
   # Returns:
   #    sdv - an IRI for the SDV dataset reflected in $path;
   #          prefers and http: -based if CSV2RDF4LOD_BASE_URI is set,
   #            e.g. https://your.org/source/timrdf/dataset/sense-making/version/friday
   #          else falls back to sdv: based.
   #            e.g. sdv:timrdf/sense-making/friday
   #
   # Side effects:
   #    global environment variable $sdv - the SDV IRI (either http or sdv: scheme)
   #
   local path="${1:-$(pwd)}"

   if [[ -z "$1" && $(which $(basename https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/cr-dataset-uri.sh)) ]]; then
      # WILL ALWAYS USE PWD REGARDLESS OF ?path.
      >&2 echo "csv2rdf4lod is installed; using default path of current working directory"
      sdv=`cr-dataset-uri.sh --uri`
      # TODO: implement this fallback in cr-dataset-uri.sh and adopt it here.
      # TODO: just make our own implementation and stop depending on such a huge repo for such simple logic.
      if [[ "$sdv" == *CSV2RDF4LOD_BASE_URI* ]]; then
         # Fall back to sdv: scheme.
         sdv=${sdv##*CSV2RDF4LOD_BASE_URI#}
         sdv=$(echo "$sdv" | sed 's/.source./sdv:/; s/.dataset//; s/.version//')
      fi
      echo "$sdv" # Return value
   elif [[ "$CSV2RDF4LOD_BASE_URI" == http* ]]; then
      # Use http-based
      echo "$CSV2RDF4LOD_BASE_URI/$(echo "$path" | awk -F\/ '{printf("source/%s/dataset/%s/version/%s",$(NF-3),$(NF-2),$(NF))}')"
   else
      >&2 echo "ERROR: need to re-implement cr-dataset-uri.sh --uri"
      echo "$CSV2RDF4LOD_BASE_URI" # TODO: implement ternary
      echo "$CSV2RDF4LOD_BASE_URI_OVERRIDE"
      #sdv=$(pwd | awk -v baseURI=${CSV2RDF4LOD_BASE_URI:"TODO fail here"} -F "/" \
      #    '{printf("%s/source/%s/dataset/%s/version/%s",baseURI,$(NF-3),$(NF-2),$NF)}')
   fi
}

# if find $samp -maxdepth $horizon -name "*.sdv.webloc" -exec false {} +; then
scratch () {
   # When no target subjects found, define one to bootstrap this SDV.
   #
   # Args:
   #    global environment variable $sdv  - used as a base IRI; prepended to $alias to identify subject.
   #    global environment variable $samp - used for file path placement (either 'manual' or 'automatic').
   #
   # Side effects:
   #    global environment variable $alias - e.g. 'texas/phil' is end of IRI identifying subject.
   #    global environment variable $iri   - $sdv/$alias
   #
   read -p "No subjects found. Define this subject? [y/N] " define
   if [ 'y' == "$define" ]; then
      sdv=$([  -n "$1" ] && echo "$1" || echo "$sdv")  # Prefer input arg over a global.
      samp=$([ -n "$2" ] && echo "$2" || echo "$samp") # Prefer input arg over a global.

      read -p "Enter an alias for the subject (may step/along/a/path/to/your/name): "  alias
      # Entered value may contain path steps e.g. 'texas/phil' ------------------------^^^^^
      alias="${alias:=subject}" # $alias is a dcterms:identifier
      iri="$sdv/$alias"
      mkdir -p "$samp/$(dirname "$alias")" #&&                         echo "(+) $samp/$alias.sdv.webloc"
      dtd='http://www.apple.com/DTDs/PropertyList-1.0.dtd'
      echo '<?xml version="1.0" encoding="UTF-8"?>'                          > "$samp/$alias.sdv.webloc"
      echo "<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" \"$dtd\">" >> "$samp/$alias.sdv.webloc"
      echo '<plist version="1.0">'                                          >> "$samp/$alias.sdv.webloc"
      echo '<dict>'                                                         >> "$samp/$alias.sdv.webloc"
      echo '   <key>URL</key>'                                              >> "$samp/$alias.sdv.webloc"
      echo "   <string>$iri</string>"                                       >> "$samp/$alias.sdv.webloc"
      echo '</dict>'                                                        >> "$samp/$alias.sdv.webloc"
      echo '</plist>'                                                       >> "$samp/$alias.sdv.webloc"
      #Failed attempt, but we're having troubles accessing it:
      #webloc="$base/../../../../../firefox.mozilla.org/webloc/version/2022-03-19/manual/webloc.webloc"
      #cat $webloc | perl -p -e "s|><|>$iri<|" > "$samp/$alias.sdv.webloc"

      # The <alias>.{sdv.webloc, properties} pair allows "drag around" citation (with the former) and
      # richer processing (with the latter).
   fi
}

# for subject in `find $samp -maxdepth $horizon -name "*.sdv.webloc"`; do
purr () {
   # Focus and orient around a single subject.
   #
   # Load the XML-based webloc at $subject if a file at the path exists.
   # Determine the URL that the webloc is referring to,
   # trim the extension '.sdv.webloc' off of the relative file path $subject (for later use),
   # Determine the "alias" of the Resource identified by the webloc based on its file path,
   # and report the expectation that any other file similar to $subject is about $iri.
   #
   # Args:
   #                              subject - relative file path to a *.sdv.webloc (often in manual/[foo]/[bar]/)
   #    global environment variable $samp - used for file path placement (either 'manual' or 'automatic').
   #
   # Side effects:
   #    global environment variable $iri declared based on contents of $subject.
   #    global environment variable $subject loses is sub-extension '.sdv.webloc'; used to resolve file paths later.
   #    global environment variable $alias declared based on path to $subject.
   #
   # TODO: rename $subject to "dossier" a kind repository that is a collection of resource representations about the subject.
   # TODO: rename $iri to $subject the resource that is being described in the $dossier file path root.
   subject="$1" # param is self-documentation; it'd do it directly to $subject anyway...
   dossier="$1" # TODO: replace $subject w/ $dossier
   if [ -e "$subject" ]; then
      subjectIRI=$(grep -A1 URL "$subject" | tail -1 | sed 's/^.*<string>//;s/<.string>*$//')
      iri="$subject" # TODO: replace $iri with $subject and stop using the stopgap $subjectIRI
      # Found a subject according to the <alias>.{sdv.webloc} naming conventions.
      # \./ is a relative base to find any number of <alias>.*.properties about the subject.
      subject=${subject%.sdv.webloc} # e.g. 'manual/texas/phil' (includes full relative path [to other common files]).
      alias=${subject#${samp}/}      # e.g.        'texas/phil' (strips away the pragmatic file path stuff)
      echo "$subject* files are about $iri:"
      find $(dirname "$subject") -name "$(basename "$subject")*"
      # Note that these ARE NOT LOADED and MUST NOT b/c the current stage should have its own scope.
   fi
}

squat () {
   # Set up a new stage with a given name and SAM(P) destination for its outset.
   #
   # TODO: how to assert an IRI for this stage that was already established?
   #
   # Note that if you want to target an outset based on properties in inset you need a different function.
   #
   # Args:
   #    stage       - name of the stage (DEPRECATED; will use ${0%.*} when stages just are in the own file.)
   #    location    - retrieval|preparation|computation|publication the type of operation (in/do/out)
   #    destination - source|automatic|manual|publish (theirs-ours, readable/writable, human/machine, third/first party)
   #
   # Side effects:
   #    inset  - the file path of where to load interview details from (properties file).
   #    outset - the file path of the stage's blob (client can append preferred file extension).
   #    props  - the file path of the stage's properties.
   #    log    - the file path of the stage's log.
   #
   # n.b. there is no blob input, only on output. Input assumes bindings (make one point to the blob?)
   # consider $(basename "${0#./}" | sed 's/.sh$//')
   stage="$(basename ${1%.*})" && rpcb="$2" && local destination="${3:automatic}" # defaults to 'automatic'.
   inset="$subject.$stage.i.properties" && splash "$inset" # <== allows us to use input values to determine $outset.
   #                        ||||||||||
   # file extension per https://github.com/timrdf/csv2rdf4lod-automation/wiki/BadgeP-Format#recommended-file-extension
   #                                                                  ||||||||||
   outset="$destination/${subject#$samp/}.$stage.o" && properties="$outset.properties" && log="$outset.log"
   # TODO: ^^^ implementation deprecated defer to glance() ! TODO TODO
   props="$properties" # TODO: replace $props with $properties and rm usage of $props.
   echo -e "$div20\n$rpcb stage \"$stage\" will generate outset: $outset.*"
   # User could append file extension to $outset e.g. $outset.csv
}

glance () {
   # Determine file paths for a stage's input/output.
   #
   # TODO: how to assert an IRI for this stage that was already established?
   #
   # Args:
   #    global environment variable 'subject' - focus of current stage.
   #
   #    stage       - name of the stage
   #    destination - source|automatic|manual|publish (theirs-ours, readable/writable, human/machine, third/first party)
   #    apsect      - 'inset', 'outset', 'properties', 'log'.
   #
   # Returns:
   #    if aspect == inset      - the file path of where to load interview details from (properties file).
   #    if aspect == outset     - the file path of the stage's blob (client can append preferred file extension).
   #    if aspect == properties - the file path of the stage's properties.
   #    if aspect == log        - the file path of the stage's log.
   #
   # n.b. there is no blob input, only on output. Input assumes bindings (make one point to the blob?)
   # TODO: if calling script does not tic that dependency then refuse.
   local stage="$1" && local destination="${2:-automatic}" && local aspect="${3:-outset}" # defaults

   local inset="$subject.$stage.i.properties"

   if [ "$aspect" == 'inset' ]; then
      echo "$inset"
   else
      # WARNING: this could replace variables of current stage w/ variables from a previous stage!
      splash "$inset" # <== allows us to use input values to determine $outset.
      #                        ||||||||||
      # file extension per https://github.com/timrdf/csv2rdf4lod-automation/wiki/BadgeP-Format#recommended-file-extension
      #                                                                  ||||||||||
      local outset="$destination/${subject#$samp/}.$stage.o" && local props="$outset.properties" && local log="$outset.log"
      # when it was squat: echo -e "$div20\n$rpcb stage \"$stage\" will generate outset: $outset.*"
      # User could append file extension to $outset e.g. $outset.csv
      if [ "$aspect" == 'outset' ]; then
         echo "$outset"

      elif [ "$aspect" == 'properties' ]; then
         echo "$outset.properties"

      elif [ "$aspect" == 'log' ]; then
         echo "$outset.log"
      else
         echo "huh?"
      fi
   fi
}

# Ensure the variable is set (by squat or splash) using ${property1?$err}
err='BadgeR did not find a value for this property; check the property file and try again.'

# Top-matter boilerplate for the file format.
# echo -e this to file so that the newline '\n' materializes.
tuft='#!/bin/bash\n#3> <> dcterms:format <https://github.com/timrdf/csv2rdf4lod-automation/wiki/H0n3y-BadgeR> .'

scowls () {
   # Determine necessary inputs from out-of-band.
   # "interview" stdin for out-of-band values for a given set of properties.
   # Called one at a time so that we can provide metadata (description, defaults, types, etc.)
   # Replaces original (singluarly-named) scowl(); plural is singular, less is more.
   #
   # Args:
   #    Of the (in focus) resource that is being processed in this workflow (determined by purr()):
   #       global environment variable $alias - ~= path/to/SAMP/local
   #       global environment variable $iri   - either http: or sdv: up through SDV/path/to/local
   #
   #    properties  - relative file path to write stdin's responses (should be $inset from squat() w/ <stage>.i.properties).
   #    [--private] - add $properties to .gitignore, or add to stage (?).
   #    property    - "label" local name part of IRI to put into $base. Will be named within sdv based on pwd.
   #    description - of the $property that will be identified through a hierarchy of IRIs.
   #
   # Each recieved value results in a fragment similar to:
   #    - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   #    #3> <#network> prov:specializationOf <todo>;
   #    #3>     rdfs:comment "The first three parts of an IP" .
   #    network=192.168.1
   #    - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   local  properties="$1"                                && shift
   [ "$1" == "--private" ] && local private='(private) ' && shift || private=''
   local    property="$1"                                && shift
   local description="$1"                                && shift
   local         egs="$1"                                && shift
   [ -n "$egs" ] && egsL=" (e.g. $egs)" || egsL=''

   read -p "Enter $alias's $private$property, $description$egsL: " value

   local subject="$subjectIRI" # Moving to replace all $iri w $subject, via stopgap $subjectIRI
   if [ ! -e "$properties" ]; then
      # Avoid establishing the file until we actually get a response.
      echo                                                                    "(+) $properties"
      echo -e $tuft                                                             > "$properties"
      echo "#3> <> rdfs:label \"$(basename "$properties")\" ."                 >> "$properties"
      echo "iri=$subject"                                                      >> "$properties"
   fi
   # Basename on the calling script is the name of the stage.
                            stage="$(basename "${0%.*}")" # Note, this does not use "local" trigger name -- could accept it as arg.
   general="$(sdv "$base")/$stage/$property"
   # ^ e.g. <https://your.org/source/timrdf/dataset/sense-making/version/friday/authorized-key/authorizations>
   echo "#3> <> dcterms:subject <#$property> ."                                >> "$properties"
   echo "#3> <#$property> prov:specializationOf <$subject/$stage/$property> ." >> "$properties"
   echo "#3> <$subject/$stage/$property>"                                      >> "$properties"
   echo "#3>    rdf:subject   <$subject>;"                                     >> "$properties"
   echo "#3>    rdf:predicate <$general>;"                                     >> "$properties"
   echo "#3>    rdf:object    \"$value\";"                                     >> "$properties"
   echo '#3> .'                                                                >> "$properties"
   echo "#3> <$general> a rdf:Property;"                                       >> "$properties"
   if [ -n "$description" ]; then
      echo "#3>     rdfs:comment \"$description\";"                            >> "$properties"
   fi
   if [ -n "$egs" ]; then
      echo "#3>     rdfs:comment \"$egsL\";"                                   >> "$properties"
   fi
   echo '#3> .'                                                                >> "$properties"
   echo "$property=$value"                                                     >> "$properties"
   echo                                                                        >> "$properties"

   if [ -n "$private" ]; then
      # Only add $properties to the .gitignore if caller indicated --private.
      [ ! -e .gitignore ] && echo "(+) .gitignore" && touch .gitignore
      if ! grep -q "$properties" .gitignore; then
         echo "(~) .gitignore" && echo "$properties" >> .gitignore
      fi
   fi
}

# if [ ! -e "$inset" ]; then
scowl () {
   # Determine necessary inputs from out-of-band.
   # "interview" stdin for out-of-band values for a given set of properties.
   # DEPRECATED; call scowls() one at a time so that we can provide metadata (description, defaults, types, etc.)
   #
   # Args:
   #    properties  - relative file path to write stdin's responses.
   #    [--private] - add $properties to .gitignore, or add to stage.
   #    $*          - list of properties for which to obtain values.
   #
   # Each recieved value results in a fragment similar to:
   #    - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   #    #3> <#network> prov:specializationOf <todo>;
   #    #3>     rdfs:comment "The first three parts of an IP" .
   #    network=192.168.1
   #    - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   local properties="$1" && shift

   private=''
   for property in $*; do
      [ "$property" == "--private" ] && private='(private) ' && shift && continue

      read -p "Enter $alias's $private$property: " value

      if [ ! -e "$properties" ]; then
         # Avoid establishing the file until we actually get a response.
         echo                         "(+) $properties"
         echo -e $tuft                  > "$properties" #!/bin/bash + #3> turtle-in-comments on following line.
         echo "iri=$iri"               >> "$properties" # Redundant w/ <alias>.sdv.webloc.
      fi

      # TODO: do the $base for $property "ontology".
      echo "#3> <#$property> prov:specializationOf <$iri/$property>;" >> "$properties"
      echo '#3>     rdfs:comment "Describe it here." .'               >> "$properties"
      echo "$property=$value"                                         >> "$properties"
      echo                                                            >> "$properties"
   done

   if [ -n "$private" ]; then
      # Only add $properties to the .gitignore if caller indicated --private.
      [ ! -e .gitignore ] && echo "(+) .gitignore" && touch .gitignore
      if ! grep -q "$properties" .gitignore; then
         echo "(~) .gitignore" && echo "$properties" >> .gitignore
      fi
   fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# scratch, purr, squat, and scowl (all defined above) are the four main pieces that a trigger implementation needs to use.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

hop () { # TODO: this is unrefined goobily and needs more exercise to anneal.
   # Permit a downstream stage from accessing details from a prior stage.
   # Avoid re-asking for the same value in a subsequent interview.
   # Args:
   #    stage

 # TODO:  stage='deauthorize' && rpcb='preparation' # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   inset="$subject.$stage.i.properties" && [ -e "$properties" ] && splash "$properties"
   outset="$subject.$stage.o" && props="$outset.properties" && log="$outset.log"
   #
   # THIS IS THE FIRST TIME that we take an IRI and find out some properites from a PREVIOUS SDV's interview.
   # https://example.org/source/example.org/dataset/some/version/2021-11-11/puns/jess
   # grep username ../2021-11-11/manual/puns/jess.account.i.properties
   # username=jess
   # Act based on the given inputs.
   rel=${iri##*version/}
   version_id=${rel%%/*}
   postrel=${rel#*/}
   filepath="../$version_id/$samp/$postrel.account.i.properties"
   cat "$filepath"
   username=$(bite "$filepath" username)
   >&2 echo "Will find out rel  ${rel}"
   >&2 echo "Will find out version ${version_id}"
   >&2 echo "Will find out filepathe  ${filepath}"
   >&2 echo "Will find out username  ${username}"
   >&2 echo "Will find out alias  ${alias}"
   >&2 echo "Will find out subject  ${subject}"
   #
   target="/home/$username/.ssh/authorized_keys"
   displaced="$subject.$stage.authorized_keys"
   echo -e "$div\n$rpcb stage \"$stage\" generates outset: $outset.*"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# squat (above) uses splash (below) to load what gnaw and bite (below) parse from H0n3y-BadgeR.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

splash () {
   # Export every declared property into the Bash execution scope.
   #
   # Effectively:
   #    select ?p ?o where { <subject> ?p ?o }
   #
   # This allows a property e.g. '^num_wires=3` to be available as $num_wires.
   # https://github.com/timrdf/csv2rdf4lod-automation/wiki/H0n3y-BadgeR
   local subject="$1"
   if [ -e "$subject" ]; then
      # ^ File path of a resource represention describing subject of interest.
      >&2 echo "\"$alias\" (according to some of the $(wc -l "$subject" | awk '{print $1}') bytes within $subject)"
      local tab=$(echo "$alias" | sed 's/./ /g')
      for predicate in $(gnaw "$subject" | grep -v '^#'); do
         # Only those that are actually declared --^^^
         object=$(bite "$subject" "$predicate")
         export $predicate="$object" # TODO: could we just have sourced the thing? :-)
         >&2 echo "$tab $predicate: $object"
      done
   fi
}

gnaw () {
   # Determine what properties are or could be declared about the subject.
   #
   # Effectively:
   #    select ?p where { <subject> ?p [] }
   #
   # Args:
   #    subject - file path of a H0n3y-BadgeR describing the subject.
   #
   # Example contents of $subject that finds both 'num_wires' and '#network':
   #    - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   #    num_wires=3
   #    #3> <#network> prov:specializationOf <todo>;
   #    #3>     rdfs:comment "The first three parts of an IP" .
   #    #network=192.168.1
   #    - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   # https://github.com/timrdf/csv2rdf4lod-automation/wiki/H0n3y-BadgeR
   local subject="$1"
   # ^ File path of a resource represention describing subject of interest.
   grep "^.*=" $subject | sed 's/=.*$//'
   # properties beginning with '#' are not declared but could be.
   # Note that finding commented out is INTENDED.
}

bite () {
   # Determine the [object] value of a given property of a given subject.
   #
   # Effectively:
   #    select ?o where { <subject> <predicate> ?o }
   #
   # Args:
   #    subject   - file path of a H0n3y-BadgeR describing the subject.
   #    predicate - the property of the subject to obtain from the H0n3y-BadgeR file.
   local subject="$1"
   # ^ File path of a resource represention describing subject of interest.
   local predicate="$2"
   # ^ Relative path within $subject to a particular [object] value to obtain.
   grep "^$predicate=" $subject | sed 's/^.*=//;s/\s*$//'
   # Note that this skips commented-out assertions.
}
