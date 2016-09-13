unit role NA::ReleaseScript;

method prefix { … }
method steps  { … }
method available-steps { self.steps».keys.map: self.prefix ~ *; }
multi method step ($name where .starts-with: self.prefix) {
    nextwith $name.subst: self.prefix, '';
}
multi method step ($name) { self.steps.Hash{$name} // fail "No step $name"; }
