#include <math.h>
#include <stdio.h>

// Defined by the LLVM IR emitted from numeric_smoke.mlir.
extern float aioptima_check(void);

int main(void) {
  const float actual = aioptima_check();
  const float expected = 24.0f;

  printf("AI-Optima native smoke-test result: %.1f\n", actual);
  if (fabsf(actual - expected) > 0.0001f) {
    fprintf(stderr, "FAIL: expected %.1f\n", expected);
    return 1;
  }

  puts("PASS: result matches the expected value (24.0).");
  return 0;
}
