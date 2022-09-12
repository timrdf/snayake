#!/bin/bash
#3> <> prov:wasInformedBy <key.sh> .

source ../../../../../turbines/version/2021-11-11/manual/turbine.sh

# TODO: just accept one argument for it, and use engine to find and feed.
for subject in `find $samp -maxdepth $horizon -name "*.sdv.webloc"`; do
   purr "$subject" # trims $subject's sdv.webloc and determines $iri and $alias

   # Note that the subject.*.properties were loaded "For free" as we've progressed to this point.

   # TODO: how to assert an IRI for this stage that was already established?
   # TODO: update squat to just use $(basename "$0") like scowls() does.
   #      \./
   # TODO Choose a class name for the name of this stage, based on the type of thing that invoking the stage generates.
   #      \./    TODO: pick 1 \./        \./         \./         \./
   squat $0 publication manual # --> inset - outset - props - log - - - - -
   echo "$inset $outset $props $log"
   #     ^^^^^
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
      # Dependencies, Input Semantics.
      #                      Stage                    Output Variable
      remote=$(bite $(glance remote manual properties) ssh)   # /remote/out/md5(q)/?ssh owl:Class
      pubkey=$(bite $(glance key    manual properties) pubkey)

      if [ ! -e "$inset" ]; then
         read -p "Configure $stage? [y/N] " configure
         if [ "$configure" == 'y' ]; then

            authorizations=''
            if [[ "$remote" == *bitbucket* ]]; then
               authorizations="https://bitbucket.org/account/settings/ssh-keys/"
            elif [[ "$remote" == *github* ]]; then
               authorizations="https://github.com/"
            else
               authorizations="You figure it out, weirdo; what sort of animal uses the service $remote?"
            fi

            # ?remote is just catalyst to determining ?authorizations (web page).
            # ?pubkey is copied and transfered to ?authorizations, but we should be citing it by reference.
            scowls "$inset" authorizations 'The web page that lists your SSH-Key authorizations'    "$authorizations"
            scowls "$inset" label          "The SSH key's label within the authorization page entry" "$subjectIRI"
           #scowls "$inset" authorized     "Did you add the public ssh key (which is in your clipboard) to $authorizations?"
         fi
      else
         >&2 echo "Add the public SSH key ${pubkey?$err} with label \"${label?$err}\" to authorizations at ${authorizations?$err}."
         >&2 echo "State where you are going to ${outset?$err}." # Determined by squat() above.

         echo
         echo "We want the following key from $pubkey to get authorized to access $remote:"
         echo
         cat "$pubkey"
         echo
         echo "To authorize that key, it must be added to your user page $authorizations, which we can open for you."
         echo
         if [ -n "$authorizations" ]; then
            read -p "Open this page in your browser? $authorizations [y/N] " load
            if [ "$load" == 'y' ]; then
               open "$authorizations"
            fi
         fi

         pbcopy < "$pubkey"
         echo "The public SSH key above should be in your clipboard; click Add Key and include $subjectIRI in the label."

         read -p "Did you execute $stage? [y/N] " execute
         if [ "$execute" == 'y' ]; then
            >&2 echo "Good job."
                date +%Y-%m-%dT%H:%M:%S%z           | tee -a "$log"
               #echo "A thing should be done here." | tee -a "$log"
               #echo -e "$tuft\greeting=hi"         | tee -a "$props"
                #    ^^ https://stackoverflow.com/a/8467448
         fi
      fi
   else
      echo "Already generated at: $props"
   fi
done
