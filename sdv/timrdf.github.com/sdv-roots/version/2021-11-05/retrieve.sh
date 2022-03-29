#!/bin/bash




# TODO: this was stubbed in but NOT implemented; see #comment-269871028 and #comment-260771032 on PR 399.
# key implementation element: pushd $(readlink $(find source -type l -name "*.sdv" | head -1)) 






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
