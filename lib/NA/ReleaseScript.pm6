unit role NA::ReleaseScript;

method prefix { … }
method steps  { … }
method available-steps { self.steps».keys.map: self.prefix ~ *; }
method step ($name where .starts-with: self.prefix) {
    self.steps.Hash{$name.subst: self.prefix, ''} //
        fail "No such step $name";
}
