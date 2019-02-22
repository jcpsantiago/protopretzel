#' Add a Protocol Buffer filter.
#'
#' @description Adds a filter for unserializing Protocol Buffer messages
#'     to your plumber API. Requires a .proto descriptor file.
#' @param api A plumber api.
#' @param name What to call the filter. Default: "protoBuf".
#' @param descriptor_path Path to the .proto descriptor file.
#'
#' @importFrom stats setNames
#' @importFrom RProtoBuf readProtoFiles read
#' @importFrom stringr str_match regex
#' @importFrom plumber forward
#' @export
addProtobufFilter <- function(api, name = "protoBuf", descriptor_path) {

  if (!("plumber" %in% class(api))) {
    stop("No plumber API provided!")
  }

  if (is.na(descriptor_path) || is.null(descriptor_path)) {
    stop("Please provide a .proto descriptor file.")
  }

  RProtoBuf::readProtoFiles(descriptor_path)

  api$filter(name, function(req) {
    protobuf_header <- stats::setNames(
      as.list(
        stringr::str_match(
          req$HEADERS["content-type"],
          stringr::regex("application/x-protobuf;\\s*messagetype=([\\w\\.]+)")
        )
      ),
      c("content-type", "message-type")
    )

    protobuf_message_type <- protobuf_header[["message-type"]]
    if (!is.na(protobuf_message_type)) {

      # rook.input contains the incoming request as a strem,
      # so we need to rewind it first to get the value
      req$rook.input$rewind()

      req$protobuf <- setNames(
        list(
          RProtoBuf::read(
            get(protobuf_message_type),
            req$rook.input$read()
          )
        ),
        protobuf_message_type
      )
    }
    plumber::forward()
  })
}
