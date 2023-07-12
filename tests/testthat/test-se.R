test_that("se works", {
  expect_equal(se(c(1,2,3,4)), sd(c(1,2,3,4)/sqrt(length(c(1,2,3,4)))))
})
