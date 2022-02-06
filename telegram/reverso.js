exports = function(app, passport) {

    const Reverso = require('reverso-api');
    const reverso = new Reverso();

    function translate(word, language = 'Russian') {
        var result;
        reverso.getContext(word, 'English', language, (response) => {
            result = response;
        }).catch((err) => {
            result = err;
        });

        return result;
    }
}

//
// function test()
// {
//     console.log("hello")
// }