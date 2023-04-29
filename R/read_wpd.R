#' Read WebPlotDigitizer JSON data
#'
#' @inheritParams rjson::fromJSON
#' @param include_pixel Include the pixel data in the returned data frame
#' @return A data.frame with colums for `x`, `y`, and `DataSet`
#'   and optionally (if `include_pixel=TRUE`) `x_pixel` and
#'   `y_pixel`.
#' @export
#' @importFrom rjson fromJSON
read_wpd <- function(json_str, file, include_pixel=FALSE) {
  rawdata <-
    if (!missing(json_str) & !missing(file)) {
      stop("Must supply only one of `jsob_str` or `file`.")
    } else if (!missing(json_str)) {
      rjson::fromJSON(json_str=json_str)
    } else if (!missing(file)) {
      rjson::fromJSON(file=file)
    } else {
      stop("Must supply one of `json_str` or `file`.")
    }
  if (identical(names(rawdata), "wpd")) {
    if (!identical(rawdata$wpd$version, c(3, 8))) {
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
  if (!is.null(jsondata$distanceMeasurementData)) {
    warning("Ignoring distance data (submit an example file if this is important to you)")
  }
  if (!is.null(jsondata$angleMeasurementData)) {
    warning("Ignoring distance data (submit an example file if this is important to you)")
  }
  if (is.null(jsondata$dataSeries$name)) {
    unnamed_list_to_df_list(
      jsondata=jsondata$dataSeries,
      include_pixel=include_pixel
    )
  } else {
    normalize_wpd_data.list(
      data=jsondata$dataSeries$data,
      data_name=jsondata$dataSeries$name,
      include_pixel=include_pixel
    )
  }
}

# Convert an unnamed list to a list of data.frames
unnamed_list_to_df_list <- function(jsondata, include_pixel=FALSE) {
  ret <- list()
  for (idx in seq_along(jsondata)) {
    current_data <-
      do.call(
        rbind,
        lapply(
          X=jsondata[[idx]]$data,
          FUN=data_row_to_data_frame
        )
      )
    current_data$DataSet <- jsondata[[idx]]$name
    if (!include_pixel) {
      current_data$x_pixel <- current_data$y_pixel <- NULL
    }
    ret <- append(ret, list(current_data))
  }
  ret
}

read_wpd_4 <- function(jsondata, include_pixel=FALSE) {
  if ("datasetColl" %in% names(jsondata)) {
    if (is.null(names(jsondata$datasetColl))) {
      unnamed_list_to_df_list(
        jsondata=jsondata$datasetColl,
        include_pixel=include_pixel
      )
    } else {
      normalize_wpd_data.list(
        data=jsondata$datasetColl$data,
        data_name=jsondata$datasetColl$name,
        include_pixel=include_pixel
      )
    }
  }
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

data_row_to_data_frame <- function(x) {
  data.frame(
    x_pixel=x$x,
    y_pixel=x$y,
    x=x$value[[1]],
    y=x$value[[2]]
  )
}
