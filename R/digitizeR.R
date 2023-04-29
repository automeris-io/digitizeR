# This file is part of digitizeR
#
# digitizeR is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# digitizeR is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with digitizeR.  If not, see <http://www.gnu.org/licenses/>.

#' digitizeR: Tool to extract numerical data from images of plots, maps etc.
#'
#' The digitizeR package provides a web based interface (WebPlotDigitizer) to interactively extract 
#' numerical data from images of plots, maps, microscope images etc. Some tools to make simple distance
#' and angle measurements are also available. In the future, this package will also allow 
#' real-time interaction between R and the hosted web application via WebSockets.
#'
#' @section Available Functions:
#'
#' \itemize{
#'      \item [wpd_launch()]: Start HTTP server that hosts WebPlotDigitizer and 
#'      open the local URL in the browser.
#'      \item [wpd_close()]: Shutdown the HTTP server.
#'      \item [wpd_isOpen()]: Check is the HTTP server is currently running.
#' }
#'
#'
#' @docType package
#' @name digitizeR
NULL

#' Start a local HTTP server that hosts WebPlotDigitizer. 
#' This will also open a browser window pointing to the local URL.
#'
#' @param location IP address or machine name of the server. Defaults to "0.0.0.0".
#' @param port Port number of the HTTP server. Defaults to 8000.
#' @return Server handle that is later used to shutdown the server using wpd_close()
#' @export
#' @examples
#' \dontrun{
#' app <- wpd_launch()
#' app <- wpd_launch(port=8080)
#' app <- wpd_launch(location="192.168.1.100", port=8080)
#' }
wpd_launch <- function(location = '0.0.0.0', port = 8000) {

    app <- new.env()

    # Start httpuv based server in the background
    app$backend = .wpd_createBackend()
    
    app$serverInstance <- httpuv::startDaemonizedServer(location, port, app$backend)

    # Construct the hosted URL link
    url <- 'http://'
    if (location == '0.0.0.0') {
        url <- paste(url, "localhost", sep='')
    } else {
        url <- paste(url, location, sep='')
    }
    url <- paste(url, ':', port, '/index.html', sep='')

    utils::browseURL(url) # Launch browser with the WPD url

    cat('Starting WPD. If a browser window does not open, then browse to:', url, '\n')
    app$isOpen <- TRUE
    return(app)
}

#' Shutdown the HTTP server that is currently hosting WebPlotDigitizer.
#'
#' @param app Server handle that was obtained by executing wpd_launch()
#' @export
#' @examples
#' \dontrun{
#' wpd_close(app)
#' }
wpd_close <- function(app) {
    if (app$isOpen) {
        cat("Shutting down WPD server\n")
        httpuv::stopDaemonizedServer(app$serverInstance)
        app$isOpen <- FALSE
    }
}

#' Check if the HTTP server is currently running.
#' 
#' @param app Server handle that was obtained by executng wpd_launch()
#' @export
wpd_isOpen <- function(app) {
    return(app$isOpen)
}
