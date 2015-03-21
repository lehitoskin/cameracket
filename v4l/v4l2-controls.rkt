; cameracket/v4l2-controls.rkt
(module cameracket/v4l2-controls
  r6rs
  (library (cameracket v4l2-controls)
           (export)
           (import (rnrs))
           
           ; Control classes
           (define V4L2-CTRL-CLASS-USER            #x00980000)      ; Old-style 'user' controls
           (define V4L2-CTRL-CLASS-MPEG            #x00990000)      ; MPEG-compression controls
           (define V4L2-CTRL-CLASS-CAMERA          #x009a0000)      ; Camera class controls
           (define V4L2-CTRL-CLASS-FM-TX           #x009b0000)      ; FM Modulator controls
           (define V4L2-CTRL-CLASS-FLASH           #x009c0000)      ; Camera flash controls
           (define V4L2-CTRL-CLASS-JPEG            #x009d0000)      ; JPEG-compression controls
           (define V4L2-CTRL-CLASS-IMAGE-SOURCE    #x009e0000)      ; Image source controls
           (define V4L2-CTRL-CLASS-IMAGE-PROC      #x009f0000)      ; Image processing controls
           (define V4L2-CTRL-CLASS-DV              #x00a00000)      ; Digital Video controls
           (define V4L2-CTRL-CLASS-FM-RX           #x00a10000)      ; FM Receiver controls
           (define V4L2-CTRL-CLASS-RF-TUNER        #x00a20000)      ; RF tuner controls
           (define V4L2-CTRL-CLASS-DETECT          #x00a30000)      ; Detection controls
           
           ; User-class control IDs
           
           (define V4L2-CID-BASE                   (bitwise-ior V4L2-CTRL-CLASS-USER #x900))
           (define V4L2-CID-USER-BASE              V4L2-CID-BASE)
           (define V4L2-CID-USER-CLASS             (bitwise-ior V4L2-CTRL-CLASS-USER 1))
           (define V4L2-CID-BRIGHTNESS             (+ V4L2-CID-BASE 0))
           (define V4L2-CID-CONTRAST               (+ V4L2-CID-BASE 1))
           (define V4L2-CID-SATURATION             (+ V4L2-CID-BASE 2))
           (define V4L2-CID-HUE                    (+ V4L2-CID-BASE 3))
           (define V4L2-CID-AUDIO-VOLUME           (+ V4L2-CID-BASE 5))
           (define V4L2-CID-AUDIO-BALANCE          (+ V4L2-CID-BASE 6))
           (define V4L2-CID-AUDIO-BASS             (+ V4L2-CID-BASE 7))
           (define V4L2-CID-AUDIO-TREBLE           (+ V4L2-CID-BASE 8))
           (define V4L2-CID-AUDIO-MUTE             (+ V4L2-CID-BASE 9))
           (define V4L2-CID-AUDIO-LOUDNESS         (+ V4L2-CID-BASE 10))
           (define V4L2-CID-BLACK-LEVEL            (+ V4L2-CID-BASE 11)) ; Deprecated
           (define V4L2-CID-AUTO-WHITE-BALANCE     (+ V4L2-CID-BASE 12))
           (define V4L2-CID-DO-WHITE-BALANCE       (+ V4L2-CID-BASE 13))
           (define V4L2-CID-RED-BALANCE            (+ V4L2-CID-BASE 14))
           (define V4L2-CID-BLUE-BALANCE           (+ V4L2-CID-BASE 15))
           (define V4L2-CID-GAMMA                  (+ V4L2-CID-BASE 16))
           (define V4L2-CID-WHITENESS              V4L2-CID-GAMMA) ; Deprecated
           (define V4L2-CID-EXPOSURE               (+ V4L2-CID-BASE 17))
           (define V4L2-CID-AUTOGAIN               (+ V4L2-CID-BASE 18))
           (define V4L2-CID-GAIN                   (+ V4L2-CID-BASE 19))
           (define V4L2-CID-HFLIP                  (+ V4L2-CID-BASE 20))
           (define V4L2-CID-VFLIP                  (+ V4L2-CID-BASE 21))
           
           (define V4L2-CID-POWER-LINE-FREQUENCY   (+ V4L2-CID-BASE 24))
           
           (define (v4l2-power-line-frequency sym)
             (let ([enum (make-enumeration (list 'DISABLED
                                                 '50HZ
                                                 '60HZ
                                                 'AUTO))])
               (if (enum-set-member? sym enum)
                   (let ([i (enum-set-indexer enum)])
                     (i sym))
                   #f)))
           
           (define V4L2-CID-HUE-AUTO                       (+ V4L2-CID-BASE 25))
           (define V4L2-CID-WHITE-BALANCE-TEMPERATURE      (+ V4L2-CID-BASE 26))
           (define V4L2-CID-SHARPNESS                      (+ V4L2-CID-BASE 27))
           (define V4L2-CID-BACKLIGHT-COMPENSATION         (+ V4L2-CID-BASE 28))
           (define V4L2-CID-CHROMA-AGC                     (+ V4L2-CID-BASE 29))
           (define V4L2-CID-COLOR-KILLER                   (+ V4L2-CID-BASE 30))
           (define V4L2-CID-COLORFX                        (+ V4L2-CID-BASE 31))
           
           (define (v4l2-colorfx sym)
             (let ([enum (make-enumeration (list 'NONE
                                                 'BW
                                                 'SEPIA
                                                 'NEGATIVE
                                                 'EMBOSS
                                                 'SKETCH
                                                 'SKY-BLUE
                                                 'GRASS-GREEN
                                                 'SKIN-WHITEN
                                                 'VIVID
                                                 'AQUA
                                                 'ART-FREEZE
                                                 'SILHOUETTE
                                                 'SOLARIZATION
                                                 'ANTIQUE
                                                 'SET-CBCR))])
               (if (enum-set-member? sym enum)
                   (let ([i (enum-set-indexer enum)])
                     (i sym))
                   #f)))
           
           (define V4L2-CID-AUTOBRIGHTNESS                 (+ V4L2-CID-BASE 32))
           (define V4L2-CID-BAND-STOP-FILTER               (+ V4L2-CID-BASE 33))
           
           (define V4L2-CID-ROTATE                         (+ V4L2-CID-BASE 34))
           (define V4L2-CID-BG-COLOR                       (+ V4L2-CID-BASE 35))
           
           (define V4L2-CID-CHROMA-GAIN                    (+ V4L2-CID-BASE 36))
           
           (define V4L2-CID-ILLUMINATORS-1                 (+ V4L2-CID-BASE 37))
           (define V4L2-CID-ILLUMINATORS-2                 (+ V4L2-CID-BASE 38))
           
           (define V4L2-CID-MIN-BUFFERS-FOR-CAPTURE        (+ V4L2-CID-BASE 39))
           (define V4L2-CID-MIN-BUFFERS-FOR-OUTPUT         (+ V4L2-CID-BASE 40))
           
           (define V4L2-CID-ALPHA-COMPONENT                (+ V4L2-CID-BASE 41))
           (define V4L2-CID-COLORFX-CBCR                   (+ V4L2-CID-BASE 42))
           
           ; last CID + 1
           (define V4L2-CID-LASTP1                         (+ V4L2-CID-BASE 43))
           
           ; USER-class private control IDs
           )
  )
