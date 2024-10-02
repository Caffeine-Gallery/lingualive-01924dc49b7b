import Func "mo:base/Func";

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

actor {
  // Define the Translation type
  type Translation = {
    original: Text;
    translated: Text;
    language: Text;
  };

  // Create a stable variable to store translations
  stable var translationsEntries : [(Text, Translation)] = [];

  // Create a HashMap to store translations
  var translations = HashMap.HashMap<Text, Translation>(10, Text.equal, Text.hash);

  // Initialize the HashMap with stable data
  public func init() : async () {
    translations := HashMap.fromIter<Text, Translation>(translationsEntries.vals(), 10, Text.equal, Text.hash);
  };

  // Function to add a translation
  public func addTranslation(original: Text, translated: Text, language: Text) : async () {
    let key = original # language;
    let translation : Translation = {
      original = original;
      translated = translated;
      language = language;
    };
    translations.put(key, translation);
  };

  // Function to get translation history
  public query func getTranslationHistory() : async [Translation] {
    let buffer = Buffer.Buffer<Translation>(translations.size());
    for ((_, translation) in translations.entries()) {
      buffer.add(translation);
    };
    Buffer.toArray(buffer)
  };

  // Pre-upgrade hook to save the state
  system func preupgrade() {
    translationsEntries := Iter.toArray(translations.entries());
  };

  // Post-upgrade hook to restore the state
  system func postupgrade() {
    translations := HashMap.fromIter<Text, Translation>(translationsEntries.vals(), 10, Text.equal, Text.hash);
  };
}
