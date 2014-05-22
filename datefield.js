var setupDateField = function(datefield) {

  var daysInMonth = function(month) {
    if (month == 2) return 29;
    if (month == 4 || month == 6 || month == 9 || month == 11) return 30;
    return 31;
  }

  var validChar = function(text, position, code) {
    code = (96 <= code && code <= 105)? code - 48 : code; // Fix numpad
    var character = String.fromCharCode(code);

    switch (position) {
      case 0:
        return character.match(/[0-9]/) != null
      case 1:
        if (text[0] == 0) {
          return character.match(/[1-9]/) != null
        } else {
          return character.match(/[0-2]/) != null // Don't allow higher than 12
        }
      case 5:
        return character.match(/[0-9]/) != null;
      case 6:
        if (text[5] == 0) {
          return character.match(/[1-9]/) != null;
        }
        var ct = parseInt(text[5]) * 10;
        if (ct + parseInt(character) > daysInMonth(parseInt(text.substring(0,2)))) {
          return false;
        }
      case 10:
        return character.match(/[0-9]/) != null
      case 11:
        return character.match(/[0-9]/) != null
    }
    return false;
  }

  var backspace = function(input) {
    var cursorPos = input.prop("selectionStart");

    // Handle backspace over slash between MM and DD
    if ((cursorPos == 3) || (cursorPos == 4)) {
      input.val(input.val().substring(0, 1));
    } 

    // Handle backspace over slash between DD and YY
    if ((cursorPos == 9) || (cursorPos == 8)) {
      input.val(input.val().substring(0, 6));
    }
  }

  var slash = function(input) {
    var position = input.prop("selectionStart");
    if (position == 1 && input.val()[0] != "0") {
      input.val("0" + input.val());
    } else if (position == 6 && input.val()[5] != "0") {
      var character = input.val()[5];
      input.val(input.val().substring(0, 5) + "0" + character);
    }
    return false;
  }

  datefield.bind('input', function() {
    self = $(this);
    text = self.val();
    if (text.length == 1) {
      if (!text.match("^0") && !text.match("^1")) {
        self.val("0" + text);
      } 
    } else if (text.length == 6) {
      var maxFirstChar = daysInMonth(parseInt(text.substring(0, 2))).toString()[0];
      char = text[5];
      if (parseInt(char) > parseInt(maxFirstChar)) {
        self.val(text.substring(0, 5) + "0" + char);
      }
    }
  });

  datefield.bind('keydown', function(e) {
    self = $(this);

    // Prevent unwanted inputs
    var code = e.keyCode;
    if (code == 8) return true; // Backspace
    if (code >= 35 && code <= 40) return true; // Arrow keys, home, end

    if (code == 111 || code == 191) {
      return slash(self);
    }

    // Check valid code at position
    var position = self.prop("selectionStart");
    return validChar(self.val(), position, code);
  });

  datefield.bind('keyup', function(e) {
    self = $(this);
    if (e.keyCode == 8) {   // Backspace
      backspace(self);
    }

    var cursorPos = self.prop("selectionStart");
    if (cursorPos == 2 || cursorPos == 7) {
      self.val(self.val() + " / ");
    }

  });
}

window.onload = function() {
  (function($) {
    $.fn.dateify = function() {
      setupDateField($(this));
    };
  })(jQuery);
}
