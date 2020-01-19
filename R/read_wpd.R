#' Read WebPlotDigitizer JSON data
#' 
#' @param txt Input txt as readable by fromJSON
#' @param include_pixel Include the pixel data in the returned data frame
#' @return A data.frame with colums for \code{x}, \code{y}, and \code{DataSet}
#'   and optionally (if \code{include_pixel=TRUE}) \code{x_pixel} and
#'   \code{y_pixel}.
#' @export
#' @importFrom rjson fromJSON
read_wpd <- function(txt, include_pixel=FALSE) {
  rawdata <- rjson::fromJSON(txt)
  if (identical(names(rawdata), "wpd")) {
    if (!identical(rawdata$version, c(3, 8))) {
      warning("read_wpd has only been tested with WebPlotDigitizer version 3.8 files when data looks like WPD version 3")
    }
    read_wpd_3(rawdata$wpd, include_pixel=include_pixel)
  } else if ("version" %in% names(rawdata)) {
    if (!identical(rawdata$version, c(4, 2))) {
      warning("read_wpd has only been tested with WebPlotDigitizer version 4.2 files when data looks like WPD version 4")
    }
    read_wpd_4(rawdata, include_pixel=include_pixel)
  } else {
    stop("The input does not appear to be WebPlotDigitizer data.")
  }
}

read_wpd_3 <- function(jsondata, include_pixel=FALSE) {
  normalize_wpd_data.list(
    data=jsondata$dataSeries$data,
    data_name=jsondata$dataSeries$name,
    include_pixel=include_pixel
  )
}

read_wpd_4 <- function(jsondata, include_pixel=FALSE) {
  normalize_wpd_data.list(
    data=jsondata$datasetColl$data,
    data_name=jsondata$datasetColl$name,
    include_pixel=include_pixel
  )
}

normalize_wpd_data.list <- function(data, data_name, include_pixel=FALSE) {
  if (length(data_name) != length(data)) {
    stop("Mismatch between length of data names and data sets.")
  }
  ret <- list()
  for (idx in seq_along(data)) {
    ret[[data_name[idx]]] <-
      normalize_wpd_data.data.frame(
        data=data[[idx]],
        data_name=data_name[[idx]],
        include_pixel=include_pixel
      )
  }
  ret
}

normalize_wpd_data.data.frame <- function(data, data_name, include_pixel=FALSE) {
  if (nrow(data) > 0) {
    names(ret)[names(ret) %in% "x"] <- "x_pixel"
    names(ret)[names(ret) %in% "y"] <- "y_pixel"
    ret$x <- sapply(ret$value, FUN=function(x) x[1])
    ret$y <- sapply(ret$value, FUN=function(x) x[2])
    ret$value <- NULL
    ret$DataSet <- data_name
  } else {
    warning("Data series named '", data_name, "' has no data.")
    # Return a 0-row data.frame with the correct columns
    ret <-
      data.frame(
        x=NA_real_, y=NA_real_,
        x_pixel=NA_real_, y_pixel=NA_real_,
        DataSet=data_name,
        stringsAsFactors=FALSE
      )[-1,]
  }
  if (!include_pixel) {
    ret$x_pixel <- ret$y_pixel <- NULL
  }
  ret
}
