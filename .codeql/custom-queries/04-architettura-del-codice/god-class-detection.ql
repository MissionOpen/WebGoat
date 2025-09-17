// by copilot (GPT 5 mini)

/**
 * @name God class detection
 * @description Find classes that are likely "god classes" based on number of methods, fields and aggregated LOC.
 * @kind problem
 * @id java/god-class
 * @problem.severity warning
 * @tags architecture
 *       design
 *
 * Notes:
 * - Thresholds are conservative defaults; tune per project:
 *   methodsThreshold = 50, fieldsThreshold = 30, totalLocThreshold = 2000
 */

import java

private int methodsThreshold() { result = 10 }
private int fieldsThreshold() { result = 10 }
private int totalLocThreshold() { result = 200 }

private int numMethods(Class c) {
  result = count(Method m | m.getDeclaringType() = c)
}

private int numFields(Class c) {
  result = count(Field f | f.getDeclaringType() = c)
}

private int totalLoc(Class c) {
  result = sum(int loc |
  exists(Method m |
    m.getDeclaringType() = c and
    loc = m.getNumberOfLinesOfCode()
  )
)
}

from Class c


where
  numMethods(c) > methodsThreshold() or
  numFields(c) > fieldsThreshold() or
  totalLoc(c) > totalLocThreshold()
select c, "God class heuristic: methods=" + numMethods(c) +
          ", fields=" + numFields(c) +
          ", summed LOC=" + totalLoc(c) +
          ". Consider decomposition."

