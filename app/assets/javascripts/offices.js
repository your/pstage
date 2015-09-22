jQuery(function() {
  var completer;

  completer = new GmapsCompleter({
    inputField: '#gmaps-input-address',
    errorField: '#gmaps-error'
  });

  completer.autoCompleteInit({
	  autoFocus: true,
	region: "IT",
    country: "it",
	autocomplete: {
	  minLength: 4
	}
  });
});