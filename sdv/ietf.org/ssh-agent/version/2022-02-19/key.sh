#!/bin/bash
#
#3> @prefix doap:    <http://usefulinc.com/ns/doap#> .
#3> @prefix dcterms: <http://purl.org/dc/terms/> .
#3> @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
#3>
#3> <> dcterms:format <https://github.com/timrdf/csv2rdf4lod-automation/wiki/H0n3y-BadgeR> .
#3> <> a conversion:RetrievalTrigger, doap:Project; # Could also be conversion:Idempotent;
#3>    prov:specializationOf <sdv:timrdf.github.com/file-formats/2021-10-31>;
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
# A downstream user of otega will want to leverage the additions that OTC is contributing back to snayake.
other='timrdf.github.com/snayake/version/2021-11-05/manual/snayake/sdv'
# Whatever repo this is in could have additions that it wants to contribute back to snayake.
our_adds='timrdf.github.com/snayake/version/2021-11-05/manual/snayake/sdv' && other="$our_adds"
# This is a written once
# when installing snayake
# and is not updated \./               our copy of what's on github \\..../// ($our_adds switches to /manual/)
for path in ../../../..  \
            ../../../../timrdf.github.com/snayake/version/2021-11-05/source/snayake/sdv \
            ../../../../$our_adds \
            ../../../../$other/$other_adds; do
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

samp='manual' # Manual is used b/c subjects are predominently direct-asserted.

# TODO: find a place for 08-29's:
# if [ 'test' == "$1" ]; then

horizon=$(echo manual/some-repo/sdv/s/d/version/v/manual/distraction.sdv.webloc | awk -F "/" '{print NF - 2}') # 7
mkdir -p $samp && if find $samp -maxdepth $horizon -name "*.sdv.webloc" -exec false {} +; then
   scratch $(sdv) $samp # <- H0n3y-BadgeR.sh; ^^^ https://stackoverflow.com/a/41925756 ^^^
   find $samp -maxdepth $horizon -name "*.sdv.webloc"
else
   for subject in `find $samp -maxdepth $horizon -name "*.sdv.webloc"`; do
      purr "$subject" # trims $subject's sdv.webloc and determines $iri and $alias

      # Note that the subject.*.properties were loaded "For free" as we've progressed to this point.


      #3> <> a <Stage> .
      # 2021-10-28.1 User’s SSH Key (gdoc, account-root, prekan)
      #
      # 2021-12-26.2 SSH Key (gdoc)
      #
      squat $(basename "${0%.*}") preparation manual # --> inset - outset - props - log - - - - -
      prikey="$outset.key" && pubkey="$prikey.pub" # add-ons to the default squat.
      if [ ! -e "$pubkey" ]; then
         if [ ! -e "$inset" ]; then # TODO: reaching down to prepare to know.
            read -p "Configure $stage? [y/N] " configure
            if [ "$configure" == 'y' ]; then
               echo "TODO: What do we say here about PHASE5? or do we pass the phrase into scowl?" # TODO:
               scowls "$inset" algorithm 'cryptographic algorithm' '[rsa] dsa ecdsa ed25519' # TODO: try to log default into write?
               scowls "$inset" foo       'some fake stuff'         'who knows'
            fi
         elif [ -e "$inset" ]; then # else so that the developer can review the inputs before approving doing it by calling again.
            # Retrieval trigger (traditional)
            # Determine output:
            algorithm=${algorithm:=rsa} # auto-fill a default.

            # All properties that were defined in the .properties are now declared as bash variables.
            >&2 echo "Will generate an SSH private + public key pair using algorithm ${algorithm?$err} into file "$subject.${prikey?$err}"."
            >&2 echo "You MUST REMEMBER your SSH key passphrase. Note that your SSH key passphrase is different from the server's password."

            read -p "Execute $stage? [y/N] " execute
            if [ "$execute" == 'y' ]; then
               read -p "What passphrase do you want to use for your SSH keys? " passphrase
               date +%Y-%m-%dT%H:%M:%S%z                                    | tee    "$log"
               echo "$passphrase" | ssh-keygen -t "$algorithm" -f "$prikey" | tee -a "$log"
               echo -e "$tuft\npubkey=$pubkey"                              | tee    "$props" # to pbcopy to bitbucket.
               echo           "prikey=$prikey"                              | tee -a "$props" # for ssh-agent.
               echo "$passphrase" > "$outset.reminder"
               echo                 "$outset.reminder" >> .gitignore
               echo                 "$prikey"          >> .gitignore
            fi
         fi
      else
         echo "Already generated at: $props"
      fi

   done
fi
