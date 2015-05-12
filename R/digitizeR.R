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

wpd.settings <- list(location = '0.0.0.0', port = 8000)

wpd.launch <- function() {
    # Start httpuv based server in the background
    .wpd.serverData$serverInstance <<- httpuv::startDaemonizedServer(wpd.settings$location, wpd.settings$port, .wpd.app)
    
    # Construct the hosted URL link
    url <- 'http://'
    if (wpd.settings$location == '0.0.0.0') {
        url <- paste(url, "localhost", sep='')
    } else {
        url <- paste(url, wpd.settings$ip, sep='')
    }
    url <- paste(url, ':', wpd.settings$port, '/index.html', sep='')
    
    browseURL(url) # Launch browser with the WPD url
    
    cat('Starting WPD. If a browser window does not open, then browse to:', url, '\n')
    .wpd.serverData$isOpen <<- TRUE
}

wpd.close <- function() {
    if (wpd.isOpen()) {
        cat("Shutting down WPD server\n")
        httpuv::stopDaemonizedServer(.wpd.serverData$serverInstance)
        .wpd.serverData$isOpen <<- FALSE
    }
}

wpd.isOpen <- function() {
    return(.wpd.serverData$isOpen)
}
