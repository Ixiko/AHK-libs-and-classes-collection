# quickTimer

Fast timer, recommended only for callbacks which needs to be called very frequently and completes quickly.

Basic usage:

        qt := new quickTimer(callback)
        f1::qt.start()
        f2::qt.stop()
        
This is experimental.