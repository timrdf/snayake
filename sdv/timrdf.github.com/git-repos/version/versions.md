SD Dataset: timrdf.github.com/git-repos ([github](https://github.com/timrdf/snayake/tree/main/sdv/timrdf.github.com/git-repos/version/versions.md))

# 2021-11-05
* version identifier chosen to follow suit with [sdv:./snayake/2021-11-05](../../snayake/version/2021-11-05) ([timrdf](https://github.com/timrdf/snayake/tree/main/sdv/timrdf.github.com/git-repos/version/2021-11-05)).
* Established 2021-10-28's prepare.sh and publish.sh
* First application of 10-28's sam(p) triggers to contributing back to some git repo (and happened to choose to contribute into snayake).
* note that this could have (should have?) been done in sdv:timrdf.github.com/snayake/2021-11-05 to "do it [most minimally] to itself", but that was only clear in retrospect.
   * TODO: try this out to clean it up.

```
publish.sh -> manual/snayake/sdv/timrdf.github.com/git-repos/version/2021-10-28/publish.sh
prepare.sh -> manual/snayake/sdv/timrdf.github.com/git-repos/version/2021-10-28/prepare.sh
```

# 2021-10-28
* version identifier chosen to follow suit with ancecdent SDV.
* generic software SDV that can be applied to any git repo.
* TODO: consider going "singular ontology SD" timrdf.github.com/git-repo.
* retrieve.sh - git clones a repository.
* prepare.sh - establishes internal trigger for contribution back.
* compute.sh - provides overview of internal <\> contribution status.
* publish.sh - contributes it back.
