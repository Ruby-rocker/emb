Handlebars.registerHelper('each_upto', function(ary, max, options) {
    if(!ary || ary.length == 0) {
        return options.inverse(this);
    }
    var result = [ ];

    for(var i = 0; i < max && i < ary.length; ++i) {
        result.push(options.fn(ary[i]));
        console.log(result)
    }
    return result.join('');
});