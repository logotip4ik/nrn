proc levenshtein_ratio_and_distance(s, t: string): float =
  ## This should be very similar to python implementation
  ## Calculates ratio and distance depending on `ratio_calc`
  let rows = s.len + 1
  let cols = t.len + 1
  var distance: seq[seq[int]]
  var cost: int
  distance = newSeq[seq[int]](rows)
  for i in 0 ..< rows:
    distance[i] = newSeq[int](cols)
  for i in 1 ..< rows:
    for k in 1 ..< cols:
      distance[i][0] = i
      distance[0][k] = k

  for col in 1 ..< cols:
    for row in 1 ..< rows:
      if s[row - 1] == t[col - 1]:
        cost = 0
      else:
        cost = 2
      distance[row][col] = min(min(distance[row-1][col] + 1,
                                   distance[row][col - 1] + 1),
                               distance[row-1][col - 1] + cost)
  let dst = distance[rows - 1][cols - 1]

  return ((s.len + t.len) - dst).float / (s.len + t.len).float

proc fuzzyMatch*(s1, s2: string): float =
  ## Source: https://github.com/pigmej/fuzzy/blob/master/src/fuzzy.nim
  if s1.len > s2.len:
    return levenshtein_ratio_and_distance(s2, s1)
  return levenshtein_ratio_and_distance(s1, s2)
