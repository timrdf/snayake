#!/bin/bash
# Note that the subject.*.properties were loaded "For free" as we've progressed to this point.
# huh
target='timrdf.github.com/file-formats/version/2021-10-30/manual/H0n3y-BadgeR.sh'

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

# https://neutronstars.utk.edu/info/ssh.shtml
samp='manual' # Manual is used b/c subjects are predominently direct-asserted.
horizon=$(echo manual/some-repo/sdv/s/d/version/v/manual/distraction.sdv.webloc | awk -F "/" '{print NF - 2}') # 7
for subject in `find $samp -maxdepth $horizon -name "*.sdv.webloc"`; do
   purr "$subject" # trims $subject's sdv.webloc and determines $iri and $alias
   # TODO: how to assert an IRI for this stage that was already established?
   squat "$0" publish manual # --> inset - outset - props - log - - - - -
   # TODO: choosing automatic/ the dir does not exist and needs to be created.
 
   #
   # d.b.a "Fhase5" -- "ya heard it here first, folks!"
   # Then you heard it [here](https://discord.com/channels/725148039647592544/725148775865385041/908350107529932811).
     #stage='STAGE5' && rpcb='retrieval|preparation|computation|publication' # - - - - - - - - - - - - - - - - - - - - -
   # Properties contains all *additional* information needed to conduct this stage. (~= inset and Function Parameters)
   # All prior properties from previous stages are still in scope (thx to sdv:/turbines/version/2021-11-11/turbine.sh)
   # (so it's important to use distinct property names in each stage).
     #inset="$subject.$stage.i.properties" && splash "$inset"
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
            prikey=$(bite $(glance key manual properties) prikey)
            echo "Found previous stage's output: $prikey"
            echo "What do we say here about PHASE5? or do we pass the phrase into scowl?"
            # Preferred approach is to in richer metadata about the properties:
            scowls "$inset" prikey 'The key that will be added to ssh-agent' "$prikey"
         fi
      else
         >&2 echo "Your current ssh-agent has the following identities:"
          ssh-add -l | tee -a "$log"
         >&2 echo
         >&2 echo "This stage will add ${prikey?$err} to your local ssh-agent so that it will be able to use it when connecting to remote servers."
         >&2 echo "State where you are going to ${outset?$err}." # Determined by squat() above.

         read -p "Execute $stage? [y/N] " execute
         if [ "$execute" == 'y' ]; then
                date +%Y-%m-%dT%H:%M:%S%z         | tee -a "$log"
                echo "Adding $prikey to ssh-add." | tee -a "$log"
            ssh-add "$prikey" | tee -a "$log"
            ssh-add -l | tee -a "$log"
           #>&2 echo "Oh, bugger."
           #    echo -e "$tuft\greeting=hi"         | tee -a "$props"
                #    ^^ https://stackoverflow.com/a/8467448
         fi
      fi
   else
      echo "Already generated at: $props"
   fi
done
