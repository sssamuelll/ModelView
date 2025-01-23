enum ParserState {
  normal,
  inObject,
  inArray,
  inKey,
  afterKey,
  inValue,
  inString,
  inNumber,
  inTrue,
  inFalse,
  inNull,
}
