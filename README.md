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

    app <- wpd.launch()
    
This starts a httpuv based server on your machine. This should also open the local URL in a browser window.

Close server instance:

    wpd.close(app)

Change default server location and port:

    app <- wpd.launch(location="192.168.1.100", port=8080) # for example

Goals
-----

At the moment, this package only lets you start (and stop) WebPlotDigitizer, but eventually, I would like to add R functions that can communicate with the app in real-time (using WebSockets). A few examples of what is possible in the future are as follows:

    ds <- wpd.getDatasets(app)                  # fetch all digitized data as a data frame.
    wpd.loadImage(app, 'my_plot.jpg')           # load an image file programmatically.
    wpd.loadPDF(app, 'thesis.pdf', page=5)      # load a specific page from a PDF file.
    wpd.calibrate(app, 'calibration_data.json') # align the axes to pixels using some calibration data.
    
    # and so on.

Contact
-------

Ankit Rohatgi <ankitrohatgi@hotmail.com>
