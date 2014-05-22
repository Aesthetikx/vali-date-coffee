setupDateField = (datefield) ->

  daysInMonth = (month) ->
    return 29  if month is 2
    return 30  if month is 4 or month is 6 or month is 9 or month is 11
    31

  # Returns true if the entered character is valid at this position, false otherwise
  validChar = (text, position, code) ->
    code = (if (96 <= code and code <= 105) then code - 48 else code) # Fix numpad
    character = String.fromCharCode(code)

    switch position
      when 0
        return character.match(/[0-9]/)? # First MM character can be 0-9
      when 1
        if text[0] is 0
          return character.match(/[1-9]/)? # First MM is a 0, only available months 01-09
        else
          return character.match(/[0-2]/)? # First MM is a 1, only available months 10-12
      when 5
        return character.match(/[0-9]/)? # First DD character can be 0-9
      when 6
        return character.match(/[1-9]/)?  if text[5] is 0 # First DD is a 0, only available days 01-09
        # Assert that the second character in DD does not exceed days in current month
        ct = parseInt(text[5]) * 10
        return ct + parseInt(character) <= daysInMonth(parseInt(text.substring(0, 2)))
      when 10
        return character.match(/[0-9]/)? # First YY can be 0-9
      when 11
        return character.match(/[0-9]/)? # Second YY can be 0-9

    false # Invalid character at this position

  # Called when the user hits backspace
  backspace = (input) ->
    position = input.prop("selectionStart")

    # Handle backspace over slash between MM and DD
    input.val input.val().substring(0, 1)  if (position is 3) or (position is 4)

    # Handle backspace over slash between DD and YY
    input.val input.val().substring(0, 6)  if (position is 9) or (position is 8)

    return

  # Called when the user enters a /
  slash = (input) ->
    position = input.prop("selectionStart")

    # Determine if the current field needs to be 0 padded 
    if position is 1 and input.val()[0] isnt "0"
      input.val "0" + input.val() # User has entered a single, non-zero month, zero pad
    else if position is 6 and input.val()[5] isnt "0"
      # User has entered a single character, non-zero day
      character = input.val()[5]
      input.val input.val().substring(0, 5) + "0" + character # Insert 0 before single day character

    false # Do not insert the /

  datefield.bind "input", ->
    self = $(this)
    text = self.val()
    
    if text.length is 1
      self.val "0" + text  if not text.match("^0") and not text.match("^1") # 0 pad single character month
    else if text.length is 6
      # Zero pad single character day if it is definately not the first char of a two char month
      maxFirstChar = daysInMonth(parseInt(text.substring(0, 2))).toString()[0]
      char = text[5]
      self.val text.substring(0, 5) + "0" + char  if parseInt(char) > parseInt(maxFirstChar)
    return

  datefield.bind "keydown", (e) ->
    self = $(this)

    # Immediately allow certain keys
    code = e.keyCode
    return true  if code is 8 # Backspace
    return true  if code >= 35 and code <= 40 # Arrow keys, home, end

    # The user has entered a slash
    return slash(self)  if code is 111 or code is 191

    # Check valid code at position
    position = self.prop("selectionStart")
    validChar self.val(), position, code

  datefield.bind "keyup", (e) ->
    self = $(this)
    # Backspace
    backspace self if e.keyCode is 8
    cursorPos = self.prop("selectionStart")

    # Automatically insert " / " between fields
    self.val self.val() + " / "  if cursorPos is 2 or cursorPos is 7
    return

  return

window.onload = ->
  (($) ->
    $.fn.dateify = ->
      setupDateField $(this)
      return

    return
  ) jQuery
  return
