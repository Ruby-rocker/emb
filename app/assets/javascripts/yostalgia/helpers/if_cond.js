Ember.Handlebars.registerHelper('ifCond', function(v1, operator, v2, options) {
    switch (operator) {
        case '==':
            return (parseInt(v1) == parseInt(v2)) ? options.fn(this) : options.inverse(this);
        case '===':
            return (parseInt(v1) === parseInt(v2)) ? options.fn(this) : options.inverse(this);
        case '<':
//            alert(eval(v1))
            return (parseInt(v1) < parseInt(v2)) ? options.fn(this) : options.inverse(this);
        case '<=':
            return (parseInt(v1) <= parseInt(v2)) ? options.fn(this) : options.inverse(this);
        case '>':
            return (parseInt(v1) > parseInt(v2)) ? options.fn(this) : options.inverse(this);
        case '>=':
            return (parseInt(v1) >= parseInt(v2)) ? options.fn(this) : options.inverse(this);
        case '&&':
            return (parseInt(v1) && parseInt(v2)) ? options.fn(this) : options.inverse(this);
        case '||':
            return (parseInt(v1) || parseInt(v2)) ? options.fn(this) : options.inverse(this);
        default:
            return options.inverse(this);
    }
});