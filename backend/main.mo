import Bool "mo:base/Bool";

import Text "mo:base/Text";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";

actor {
  type Translation = {
    original: Text;
    translated: Text;
    language: Text;
    user: Principal;
  };

  stable var translationsEntries : [(Text, Translation)] = [];
  var translations = HashMap.HashMap<Text, Translation>(10, Text.equal, Text.hash);

  public shared({ caller }) func addTranslation(original: Text, translated: Text, language: Text) : async () {
    let key = original # language;
    let translation : Translation = {
      original = original;
      translated = translated;
      language = language;
      user = caller;
    };
    translations.put(key, translation);
  };

  public shared query({ caller }) func getTranslationHistory() : async [Translation] {
    let buffer = Buffer.Buffer<Translation>(translations.size());
    for ((_, translation) in translations.entries()) {
      if (translation.user == caller) {
        buffer.add(translation);
      };
    };
    Buffer.toArray(buffer)
  };

  public shared query func isAuthenticated(p : Principal) : async Bool {
    not Principal.isAnonymous(p)
  };

  system func preupgrade() {
    translationsEntries := Iter.toArray(translations.entries());
  };

  system func postupgrade() {
    translations := HashMap.fromIter<Text, Translation>(translationsEntries.vals(), 10, Text.equal, Text.hash);
  };
}
