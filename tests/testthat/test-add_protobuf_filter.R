context("test-add_protobuf_filter")

test_api <- plumber$new()

test_that("stops with incorrect inputs", {
  expect_error(addProtobufFilter(api = data.frame(), descriptor_path = "."))
  expect_error(addProtobufFilter(api = test_api))
})
