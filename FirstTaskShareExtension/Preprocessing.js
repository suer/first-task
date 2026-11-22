var Preprocessing = function () {};

Preprocessing.prototype = {
    run: function (arguments) {
        arguments.completionFunction({ title: document.title, url: document.URL });
    },
};

var ExtensionPreprocessingJS = new Preprocessing();
