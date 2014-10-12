var LS_PROP = "_loiterers";
var ID_PROP = "_loiterId";

var invoke = function (obj, method) {
  var args = [].slice.call(arguments, 2);
  return typeof method === "function" ?
    method.apply(obj, args) :
    obj[method].apply(obj, args);
}

function extend (target, source) {
  Object.keys(source).forEach( function (key) {
    target[key] = source[key];
  });
  return target;
}

var idCounter = 0;

function makeLoiter (config) {
  // hash config?
  // counter

  return function (model) {
    var id = ++counter;
    return extend(model, {
      loiterSave: function () {
        //
      },
      loiterClear: function () {
        //
      },
      loiterTrySend: function () {
        //
      }
    });
  }

}


function loiter (model) {
  var id = ++idCounter;

  extend(model, {
    loiterSave: function () {

    },
    loiterClear: function () {

    },
    loiterTrySend: function () {
      y
    }
  });
}



// save to local storage
// get stuff out of local storage
// clear from local storage
// send it

// localstorage


// {
//   ...
//   _loiterers: [
//     {
//       _loiterId: Number
//     }, {
//       _loiterId: Number
//     }
//     ...
//   ]
//   ...
// }