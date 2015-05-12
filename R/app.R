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


wpd.serverData <- list(
        serverInstance = NULL,
        isOpen = FALSE,
        connectedClients = 0
    )

wpd.app <- list(
    call = function(req) {                
        # Handle HTTP requests       
        
        # Host files from checked out WebPlotDigitizer
        reqFile <- req$PATH_INFO
        packagePath <- system.file(package="digitizeR")        
        filepath <- paste(packagePath, "tools/WebPlotDigitizer-3.8", reqFile, sep="/")
        
        # If the file is not found, then return a 404 code.
        message <- list(status = 404L, headers = list('Content-Type' = 'text/html'), body = 'error!')
        
        if (file.exists(filepath)) {            
            # if this is a PHP script, then we probably got a POST request to generate a CSV or JSON file
            # Maybe we can even run R scripts in the future?
            # TODO: Use tryCatch here:            
            if (grepl("json.php$", reqFile)) {
                # Generate JSON file
                
                # Read POST data
                postVariables <- list(data = "", filename = "")
                
                postInput <- req[["rook.input"]]
                postData <- postInput$read_lines()
                postData <- Rook::Utils$unescape(postData)
                
                # There's probably a better way to do this:                
                postRegexPattern <- "^data=(\\{.*)\\&filename=(.*)"
                if(grepl(postRegexPattern, postData)) { 
                    postVariables$data <- gsub(postRegexPattern, "\\1", postData)
                    postVariables$filename <- gsub(postRegexPattern, "\\2", postData)
                    message <- list(status = 200L,
                                    headers = list('Content-Type' = 'application/json',
                                                   'Content-disposition' = paste('attachment; filename="', postVariables$filename, '.json"', sep='')),
                                    body = postVariables$data
                    )
                } else {
                    cat("ERROR: Invalid POST data sent for", reqFile, "\n")                    
                }                                                                                
            } else if (grepl("csvexport.php$", reqFile)) {
                # Generate CSV file
                
                # Read POST data
                postVariables <- list(data = "", filename = "")
                
                postInput <- req[["rook.input"]]
                postData <- postInput$read_lines()                                
                postData <- Rook::Utils$unescape(postData)
                
                # There's probably a better way to do this:                
                postRegexPattern <- "^data=(.*)\\&filename=(.*)"
                if(grepl(postRegexPattern, postData)) { 
                    postVariables$data <- gsub(postRegexPattern, "\\1", postData)
                    postVariables$filename <- gsub(postRegexPattern, "\\2", postData)
                    csvData <- rjson::fromJSON(postVariables$data)
                    message <- list(status = 200L,
                                    headers = list('Content-Type' = 'text/csv',
                                                   'Content-disposition' = paste('attachment; filename="', postVariables$filename, '.csv"', sep='')),
                                    body = csvData
                    )
                } else {
                    cat("ERROR: Invalid POST data sent for", reqFile, "\n")                    
                }          
                
            } else {
                # if this is not a PHP file, then just determine the mime type and return
                mimetype <- mime::guess_type(filepath)
                message <- list(status = 200L,
                                headers = list('Content-Type' = mimetype),
                                body = list(file = filepath))                    
            }            
        }
        
        return(message)
    },
    onWSOpen = function(ws) {
        # Handle WebSocket communication in the future        
    }
    
    )
