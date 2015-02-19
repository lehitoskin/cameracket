; cameracket/v4l1-videodev.rkt
(module cameracket/v4l1-videodev
  racket/base
  (require ffi/unsafe
           "ioctl.rkt")
  (provide (all-defined-out))
  
  (define VID_TYPE_CAPTURE        1)       ; Can capture
  (define VID_TYPE_TUNER          2)       ; Can tune
  (define VID_TYPE_TELETEXT       4)       ; Does teletext
  (define VID_TYPE_OVERLAY        8)       ; Overlay onto frame buffer
  (define VID_TYPE_CHROMAKEY      16)      ; Overlay by chromakey
  (define VID_TYPE_CLIPPING       32)      ; Can clip
  (define VID_TYPE_FRAMERAM       64)      ; Uses the frame buffer memory
  (define VID_TYPE_SCALES         128)     ; Scalable
  (define VID_TYPE_MONOCHROME     256)     ; Monochrome only
  (define VID_TYPE_SUBCAPTURE     512)     ; Can capture subareas of the image
  (define VID_TYPE_MPEG_DECODER   1024)    ; Can decode MPEG streams
  (define VID_TYPE_MPEG_ENCODER   2048)    ; Can encode MPEG streams
  (define VID_TYPE_MJPEG_DECODER  4096)    ; Can decode MJPEG streams
  (define VID_TYPE_MJPEG_ENCODER  8192)    ; Can encode MJPEG streams
  
  ; _video-channel
  (define VIDEO-VC-TUNER 1)
  (define VIDEO-VC-AUDIO 2)
  (define VIDEO-TYPE-TV 1)
  (define VIDEO-TYPE-CAMERA 2)
  
  ; _video-tuner
  (define VIDEO_TUNER_PAL         1)
  (define VIDEO_TUNER_NTSC        2)
  (define VIDEO_TUNER_SECAM       4)
  (define VIDEO_TUNER_LOW         8)       ; Uses KHz not MHz
  (define VIDEO_TUNER_NORM        16)      ; Tuner can set norm
  (define VIDEO_TUNER_STEREO_ON   128)     ; Tuner is seeing stereo
  (define VIDEO_TUNER_RDS_ON      256)     ; Tuner is seeing an RDS datastream
  (define VIDEO_TUNER_MBS_ON      512)     ; Tuner is seeing an MBS datastream
  
  ; _video-picture
  (define VIDEO_PALETTE_GREY      1)       ; Linear greyscale
  (define VIDEO_PALETTE_HI240     2)       ; High 240 cube (BT848)
  (define VIDEO_PALETTE_RGB565    3)       ; 565 16 bit RGB
  (define VIDEO_PALETTE_RGB24     4)       ; 24bit RGB
  (define VIDEO_PALETTE_RGB32     5)       ; 32bit RGB
  (define VIDEO_PALETTE_RGB555    6)       ; 555 15bit RGB
  (define VIDEO_PALETTE_YUV422    7)       ; YUV422 capture
  (define VIDEO_PALETTE_YUYV      8)
  (define VIDEO_PALETTE_UYVY      9)       ; The great thing about standards is ...
  (define VIDEO_PALETTE_YUV420    10)
  (define VIDEO_PALETTE_YUV411    11)      ; YUV411 capture
  (define VIDEO_PALETTE_RAW       12)      ; RAW capture (BT848)
  (define VIDEO_PALETTE_YUV422P   13)      ; YUV 4:2:2 Planar
  (define VIDEO_PALETTE_YUV411P   14)      ; YUV 4:1:1 Planar
  (define VIDEO_PALETTE_YUV420P   15)      ; YUV 4:2:0 Planar
  (define VIDEO_PALETTE_YUV410P   16)      ; YUV 4:1:0 Planar
  (define VIDEO_PALETTE_PLANAR    13)      ; start of planar entries
  (define VIDEO_PALETTE_COMPONENT 7)       ; start of component entries
  
  ; _video-audio
  (define VIDEO_AUDIO_MUTE        1)
  (define VIDEO_AUDIO_MUTABLE     2)
  (define VIDEO_AUDIO_VOLUME      4)
  (define VIDEO_AUDIO_BASS        8)
  (define VIDEO_AUDIO_TREBLE      16)
  (define VIDEO_AUDIO_BALANCE     32)
  (define VIDEO_SOUND_MONO        1)
  (define VIDEO_SOUND_STEREO      2)
  (define VIDEO_SOUND_LANG1       4)
  (define VIDEO_SOUND_LANG2       8)
  
  ; _video-window
  (define VIDEO_WINDOW_INTERLACE  1)
  (define VIDEO_WINDOW_CHROMAKEY  16)      ; Overlay by chromakey
  (define VIDEO_CLIP_BITMAP       -1)
  ; bitmap is 1024x625, a '1' bit represents a clipped pixel
  (define VIDEO_CLIPMAP_SIZE      (* 128 625))
  
  ; _vbi-format
  (define VBI_UNSYNC      1)               ; can distingues between top/bottom field
  (define VBI_INTERLACED  2)               ; lines are interlaced
  
  (define-cstruct _video-capability
    ([name _string]
     [type _int]
     [channels _int]   ; num channels
     [audios _int]     ; num devices
     [maxwidth _int]   ; supported width
     [maxheight _int]  ; and height
     [minwidth _int]   ; supported width
     [minheight _int]) ; and height
    #:malloc-mode 'atomic)
  
  (define-cstruct _video-channel
    ([channel _int]
     [name _string]
     [tuners _int]
     [flags _uint32]
     [type _uint16]
     [norm _uint16])
    #:malloc-mode 'atomic)
  
  (define-cstruct _video-tuner
    ([tuner _int]
     [rangelow _ulong]  ; tuner range
     [rangehigh _ulong]
     [flags _uint32]
     [mode _uint16]     ; PAL/NTSC/SECAM/OTHER
     [signal _uint16])  ; signal strength 16bit scale
    #:malloc-mode 'atomic)
  
  (define-cstruct _video-picture
    ([brightness _uint16]
     [hue _uint16]
     [color _uint16]
     [contrast _uint16]
     [whiteness _uint16]  ; black and white only
     [depth _uint16]      ; capture depth
     [palette _uint16])   ; palette in use
    #:malloc-mode 'atomic)
  
  (define-cstruct _video-audio
    ([audio _int]      ; audio channel
     [volume _uint16]  ; if settable
     [bass _uint16]
     [treble _uint16]
     [flags _uint32]
     [name _string]
     [mode _uint16]
     [balance _uint16] ; stereo balance
     [step _uint16])   ; step actual volume uses
    #:malloc-mode 'atomic)
  
  (define-cstruct _video-clip
    ([x _int32]
     [y _int32]
     [next _video-clip-pointer]) ; for user use/driver use only
    #:malloc-mode 'atomic)
  
  (define-cstruct _video-window
    ([x _uint32]                 ; position of window
     [y _uint32]
     [width _uint32]             ; its size
     [height _uint32]
     [chromakey _uint32]
     [flags _uint32]
     [clips _video-clip-pointer] ; set only
     [clipcount _int])
    #:malloc-mode 'atomic)
  
  (define-cstruct _video-buffer
    ([base _gcpointer]
     [height _int]
     [width _int]
     [depth _int]
     [bytes-per-line _int])
    #:malloc-mode 'atomic)
  
  (define-cstruct _video-mmap
    ([frame _uint]   ; frame (0 - n) for double buffer
     [height _int]
     [width _int]
     [format _uint]) ; should be VIDEO_PALLETTE_*
    #:malloc-mode 'atomic)
  
  (define-cstruct _video-mbuf
    ([size _int]   ; total memory to map
     [frames _int] ; frames
     [offsets (_list io _int 32)])
    #:malloc-mode 'atomic)
  
  (define-cstruct _vbi-format
    ([sampling-rate _uint32]     ; in Hz
     [samples-per-line _uint32]
     [sample-format _uint32]     ; VIDEO_PALETTE_RAW only (1 byte)
     [start (_list io _int32 2)] ; starting line for each frame
     [count (_list io _int32 2)] ; count of lines for each frame
     [flags _uint32])
    #:malloc-mode 'atomic)
  
  ; Get capabilities
  (define VIDIOCGCAP              (_IOR #"v" 1 _video-capability))
  ; Get channel info (sources)
  (define VIDIOCGCHAN             (_IOWR #"v" 2 _video-channel))
  ; Set channel
  (define VIDIOCSCHAN             (_IOW #"v" 3 _video-channel))
  ; Get tuner abilities
  (define VIDIOCGTUNER            (_IOWR #"v" 4 _video-tuner))
  ; Tune the tuner for the current channel
  (define VIDIOCSTUNER            (_IOW #"v" 5 _video-tuner))
  ; Get picture properties
  (define VIDIOCGPICT             (_IOR #"v" 6 _video-picture))
  ; Set picture properties
  (define VIDIOCSPICT             (_IOW #"v" 7 _video-picture))
  ; Start, end capture
  (define VIDIOCCAPTURE           (_IOW #"v" 8 _int))
  ; Get the video overlay window
  (define VIDIOCGWIN              (_IOR #"v" 9 _video-window))
  ; Set the video overlay window - passes clip list for hardware smarts , chromakey etc
  (define VIDIOCSWIN              (_IOW #"v" 10 _video-window))
  ; Get frame buffer
  (define VIDIOCGFBUF             (_IOR #"v" 11 _video-buffer))
  ; Set frame buffer - root only
  (define VIDIOCSFBUF             (_IOW #"v" 12 _video-buffer))
  ; Set tuner
  (define VIDIOCGFREQ             (_IOR #"v" 14 _ulong))
  ; Set tuner
  (define VIDIOCSFREQ             (_IOW #"v" 15 _ulong))
  ; Get audio info
  (define VIDIOCGAUDIO            (_IOR #"v" 16 _video-audio))
  ; Audio source, mute etc
  (define VIDIOCSAUDIO            (_IOW #"v" 17 _video-audio))
  ; Sync with mmap grabbing
  (define VIDIOCSYNC              (_IOW #"v" 18 _int))
  ; Grab frames
  (define VIDIOCMCAPTURE          (_IOW #"v" 19 _video-mmap))
  ; Memory map buffer info
  (define VIDIOCGMBUF             (_IOR #"v" 20 _video-mbuf))
  ; Get VBI information
  (define VIDIOCGVBIFMT           (_IOR #"v" 28 _vbi-format))
  ; Set VBI information
  (define VIDIOCSVBIFMT           (_IOW #"v" 29 _vbi-format))
)
