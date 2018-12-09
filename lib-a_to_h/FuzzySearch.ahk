/**
 * https://github.com/bartlb/AHK_Libraries
 * Creates an array of match objects using a custom search technique based on a mix of
 * fuzzy search and LCS algoritms. 
 * 
 * Before the search is initiated the query is split into individual characters, and then
 * joined again by a regex wildcard -- though if query is blank or 'dict' is not an array
 * the function will fail, returning 0. The search then begins by looping through the
 * array of strings and attempting to validate a match by using a basic fuzzy search. If
 * a match is found, the function will attempt to locate the best match for the query,
 * rather than just submitting the first match (left-to-right); the 'best match' is
 * determined by a weight system which holds matches at the begining of a string, new 
 * words (seen as characters separated by a standard word boundary '\b' or an underscore)
 * and capitals as identifiers of a better match. The weight system is fairly basic. In
 * order, matches are weighted as follows:
 * 1. The percent of characters in the string that the query covers, as a whole number.
 *    i.e. Round((QUERY_LENGTH / STRING_LENGTH) * 100)
 * 2. The first character in the query matches the first character in a string (+50).
 * 3. A character in the query matches the first letter of a new word in a string (+25).
 * 4. A character in the quert matches any uppercase letter in a given string (+10).
 * 5. Any other match (+1).
 *
 * @function  FuzzySearch
 * @param     [in]      dict    An array of strings to query against.
 * @param     [in]      query   Any query in the form of a string.
 * @returns   {object}          An array of match objects consisting of the matched
 *                              string and information pertaining to where the match
 *                              occured within the string.
 */
FuzzySearch(dict, query) {
  if (! IsObject(dict) || query == "")
    return 0

  matches := []

  for each, token in StrSplit(query)
  {
    re_string .= (re_string ? ".*?" : "") "(" token ")"
  }

  for each, string in dict
  {
    if (RegExMatch(string, "Oi)" re_string, re_obj)) {
      _match := {
      (Join
        "string": string,
        "tokens": [],
        "weight": Round((re_obj.Count() / StrLen(string)) * 100)  
      )}

      loop % re_obj.Count()
      {
        m_offset    := re_obj.Pos(A_Index)
        m_restring  := (A_Index == 1 ? re_string : SubStr(m_restring, 7))
        _token      := { "id": "", "position": 0, "weight": 0 }
        
        while (RegExMatch(string, "Oi)" m_restring, m_obj, m_offset)) {
          _weight := m_obj.Pos(1) == 1 ? 50
                   : RegExMatch(SubStr(string, m_obj.Pos(1) - 1, 2)
                              , "i)(\b|(?<=_))" m_obj[1]) ? 25 
                   : RegExMatch(SubStr(string, m_obj.Pos(1), 1), "\p{Lu}") ? 10 : 01

          if (_weight > _token.weight)
            _token.id := m_obj[1]
            , _token.weight   := _weight
            , _token.position := m_obj.Pos(1)
          
          m_offset := m_obj.Pos(1) + 1
        }

        _match.tokens.Insert(_token.position, _token.id)
        _match.weight += _token.weight
      }

      matches.Insert(_match)
    }
  }
  
  return matches
}

FuzzySearchMin(a,b){
if(!IsObject(a)||b=="")
return 0
c:=[]
for d,e in StrSplit(b)
f.=(f?".*?":"")"(" e ")"
for d,g in a{
if(RegExMatch(g,"Oi)"f,h)){
i:={"string":g,"tokens":[],"weight":Round((h.Count()/StrLen(g))*100)}
loop % h.Count(){
j:=h.Pos(A_Index),k:=(A_Index==1?f:SubStr(k,7)),l:={"m":"","n":0,"o":0}
while(RegExMatch(g,"Oi)"k,p,j)){
q:=p.Pos(1)==1?50:RegExMatch(SubStr(g,p.Pos(1)-1,2),"i)(\b|(?<=_))"p[1])?25:RegExMatch(SubStr(g,p.Pos(1),1),"\p{Lu}")?10:01
if(q>l.o)
l.m:=p[1],l.o:=q,l.n:=p.Pos(1)
j:=p.Pos(1)+1
}i.tokens.Insert(l.n,l.m),i.weight+=l.o
}c.Insert(i)
}}return c
}