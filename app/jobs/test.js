#!/usr/bin/env node

const Reverso = require('/Users/andreykuluev/node_modules/reverso-api/index.js');
const reverso = new Reverso();

async function reverso_translate(word, language) {
  let aPromise = reverso.getContext(word, 'English', language)

  // console.log(aPromise);

  const res = await aPromise;

  // console.log(res);

  return await res;
}

// reverso_translate('hello', "Russian")
console.log (reverso_translate('hello', "Russian"))