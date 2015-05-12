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


wpd.launch <- function(location = '0.0.0.0', port = 8000) {
        
    app <- new.env()
    
    # Start httpuv based server in the background
    app$backend = wpd.createBackend()
    
    app$serverInstance <- httpuv::startDaemonizedServer(location, port, app$backend)
    
    # Construct the hosted URL link
    url <- 'http://'
    if (location == '0.0.0.0') {
        url <- paste(url, "localhost", sep='')
    } else {
        url <- paste(url, location, sep='')
    }
    url <- paste(url, ':', port, '/index.html', sep='')
    
    browseURL(url) # Launch browser with the WPD url
    
    cat('Starting WPD. If a browser window does not open, then browse to:', url, '\n')
    app$isOpen <- TRUE
    return(app)
}


wpd.close <- function(app) {
    if (app$isOpen) {
        cat("Shutting down WPD server\n")
        httpuv::stopDaemonizedServer(app$serverInstance)
        app$isOpen <- FALSE
    }
}

wpd.isOpen <- function(app) {
    return(app$isOpen)
}
