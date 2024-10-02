export const idlFactory = ({ IDL }) => {
  const Translation = IDL.Record({
    'translated' : IDL.Text,
    'user' : IDL.Principal,
    'language' : IDL.Text,
    'original' : IDL.Text,
  });
  return IDL.Service({
    'addTranslation' : IDL.Func([IDL.Text, IDL.Text, IDL.Text], [], []),
    'getTranslationHistory' : IDL.Func([], [IDL.Vec(Translation)], ['query']),
    'isAuthenticated' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
