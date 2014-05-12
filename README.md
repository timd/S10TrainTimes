### A Cowardly Test-o-phobe's Guide To Test-Driven Development With iOS
### S10 Train Times

#### Being an example from a presentation given at iOSCon London, May 2014

This example demonstrates the use of OHHTTPStubs to simulate a network connection.

The app puports to retrieve the time of the next S10 train between Uitikon Waldegg and Zürich Hauptbahnhof.  In normal circumstances, this data would be available through the magic of the transport.opendata.ch API.

In this example, the network request is mocked out by OHHTTPStubs, and loads the data from a JSON file in the app bundle.  It also simulates a slow network response to force the activity indicator to turn red (indicating a long-running request).

#### Prerequistes

1. Xcode 5.1 or later
1. [Kiwi](https://github.com/allending/Kiwi)
1. [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs)

### Licensing

This project is licensed under Creative Commons Attribution NonCommercial ShareAlike 3.0 Unported terms.  Feel free to use noncommercially as you see fit; if you include it in teaching materials or similar, then a link back to my site [http://adoptioncurve.net](http://adoptioncurve.net) would be appreciated.

Copyright (cc) 2014 Tim Duckett