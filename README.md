digitizeR
---------

WebPlotDigitizer powered R package for data extraction from images of plots, maps etc.

Install
-------

This package is under heavy development, but uses a stable version of WebPlotDigitizer. If you want to give this a try, then follow these instructions:


1) If you don't already have devtools, then install using:

        install.packages("devtools")
    
2) Install digitizeR (Linux/Mac/Windows):
    
        devtools::install_github("ankitrohatgi/digitizeR")
        
Use
---

No real-time communication has been implemented at the moment, but you can launch and close WPD using the following:

Launch a local instance of WebPlotDigitizer:

    app = wpd.launch()
    
This starts a httpuv based server on your machine. This should also open the local URL in a browser window.

Close server instance:

    wpd.close(app)

Change default server location and port:

    app = wpd.launch(location="192.168.1.100", port=8080) # for example


Contact
-------

Ankit Rohatgi <ankitrohatgi@hotmail.com>
