/*
 * Grammar to generate an S-Expressions parser for Javascript using http://pegjs.majda.cz/
 */
{
  function makeFloat(sign, num, matinssa) {
    return parseFloat(sign + num + '.' + matinssa);
  }
}
 
start
= _ exps:Expression* { return exps; }

Expression
= quoted:QuotedExp _ { return quoted; }
/ quoted:QuasiquotedExp _ { return quoted; }
/ n:Number _ { return n; }
/ str:String _ { return str; }
/ sym:Symbol _ { return sym; }
/ l:List _ { return l; }

QuotedExp
// inside quoted exp there cannot be unquoted text. so this is correct.
= "'" _ exp:Expression _ { return {quoted: exp }; }

QuasiquotedExp
// inside quasiquoted expression we can unquote
= "`" _ exp:quasiExpression _ { return {quasi: exp}; }

quasiExpression
= exp:unquotedExpression _ { return exp; }
/ exp:quasiList _ { return exp; }
/ exp:Expression _ { return exp; }

unquotedExpression
= ',@' _ exp:Expression _ { return {unquoteSplicing: exp }; }
/ ',' _ exp:Expression _ { return {unquote: exp}; }

quasiList
= '(' _  exps:quasiExpression* _ ')' _ { return exps; }

/* === Symbol === */
Symbol 
= s1:symbol1stChar rest:symbolRestChar* { return {symbol: s1 + rest.join('')}; }

symbol1stChar
= [^0-9\(\)\;\ \"\'\,\`]

symbolRestChar
= [^\(\)\;\ \"\'\,\`]

/* === STRING === */
List 
= '(' _  exps:Expression* _ ')' _ { return exps; }

/* === STRING === */

String
  = '"' chars:doubleQuoteChar* '"' _ { return chars.join(''); }

singleQuoteChar
  = '"'
  / char

doubleQuoteChar
  = "'"
  / char

char
  // In the original JSON grammar: "any-Unicode-character-except-"-or-\-or-control-character"
  = [^"'\\\0-\x1F\x7f]
  / '\\"'  { return '"';  }
  / "\\'"  { return "'"; }
  / "\\\\" { return "\\"; }
  / "\\/"  { return "/";  }
  / "\\b"  { return "\b"; }
  / "\\f"  { return "\f"; }
  / "\\n"  { return "\n"; }
  / "\\r"  { return "\r"; }
  / "\\t"  { return "\t"; }
  / whitespace 
  / "\\u" digits:hexDigit4 {
      return String.fromCharCode(parseInt("0x" + digits));
    }

/* ==== NUMBERS ==== */

hexDigit4
  = h1:hexDigit h2:hexDigit h3:hexDigit h4:hexDigit { return h1+h2+h3+h4; }

Number
  = int:int frac:frac exp:exp _ { return parseFloat([int,frac,exp].join('')); }
  / int:int frac:frac _     { return parseFloat([int,frac].join('')); }
  / '-' frac:frac _ { return parseFloat(['-',frac].join('')); }
  / frac:frac _ { return parseFloat(frac); }
  / int:int exp:exp _      { return parseFloat([int,exp].join('')); }
  / int:int _          { return parseFloat(int); }

int
  = digits:digits { return digits.join(''); }
  / "-" digits:digits { return ['-'].concat(digits).join(''); }

frac
  = "." digits:digits { return ['.'].concat(digits).join(''); }

exp
  = e digits:digits { return ['e'].concat(digits).join(''); }

digits
  = digit+

e
  = [eE] [+-]?

digit
  = [0-9]

digit19
  = [1-9]

hexDigit
  = [0-9a-fA-F]



  _ "whitespace"
    = whitespace*

  // Whitespace is undefined in the original JSON grammar, so I assume a simple
  // conventional definition consistent with ECMA-262, 5th ed.
  whitespace
    = comment
    / [ \t\n\r]


  lineTermChar
    = [\n\r\u2028\u2029]

  lineTerm "end of line"
    = "\r\n"
    / "\n"
    / "\r"
    / "\u2028" // line separator
    / "\u2029" // paragraph separator

  sourceChar
    = .

  // should also deal with comment.
  comment
    = multiLineComment
    / singleLineComment

  singleLineCommentStart
    = '//' // c style

  singleLineComment
    = singleLineCommentStart chars:(!lineTermChar sourceChar)* lineTerm? { 
      return {comment: chars.join('')}; 
    }

  multiLineComment
    = '/*' chars:(!'*/' sourceChar)* '*/' { return {comment: chars.join('')}; }
