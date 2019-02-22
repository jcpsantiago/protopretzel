#' Protocol Buffer serializer.
#'
#' @description Serializes Protocol Buffer messages, and adds the message type
#'     to the response header.
#'
#' @importFrom RProtoBuf serialize
#' @import plumber
#' @export
protobuf_serializer <- function() {
  function(val, req, res, errorHandler) {
    tryCatch({
      res$setHeader(
        "Content-Type",
        paste0("application/x-protobuf; messagetype=", val@type)
      )
      res$body <- RProtoBuf::serialize(val, NULL)
      return(res$toResponse())
    }, error = function(e) {
      errorHandler(req, res, e)
    })
  }
}

#' Add a Protocol Buffer serializer.
#'
#' @description This is a convenience wrapper for plumber::addSerializer.
#'
#' @param name The name of the serializer (character string). Default: "ProtoBuf"
#' @param serializer The serializer to be added. Default: protobuf_serializer
#'
#' @importFrom plumber addSerializer
#' @export
addProtobufSerializer <- function(name = "protoBuf",
                                  serializer = protobuf_serializer) {
  plumber::addSerializer(name, serializer)
}
