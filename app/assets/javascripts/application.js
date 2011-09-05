// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

Array.prototype.remove=function(s){
  var index = this.indexOf(s);
  if(this.indexOf(s) != -1) this.splice(index, 1);
}

// http://stackoverflow.com/questions/246193/how-do-i-round-a-number-in-javascript
function roundNumber(number, digits) {
  var multiple = Math.pow(10, digits);
  return Math.round(number * multiple) / multiple;
}
