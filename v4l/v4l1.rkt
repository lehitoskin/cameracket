; cameracket/v4l1.rkt
(module cameracket/v4l1
  racket/base
  (require ffi/unsafe
           ffi/unsafe/define
           "v4l1-videodev.rkt")
  (provide (except-out (all-defined-out)
                       define-v4l1))
  
  (define-ffi-definer define-v4l1 (ffi-lib "libv4l1"))
  
  #|
   Just like your regular open/close/etc, except that when opening a v4l2
   capture only device, full v4l1 emulation is done including emulating the
   often not implemented in v4l2 drivers CGMBUF ioctl and v4l1 style mmap call
   in userspace.

   Format conversion is done if necessary when capturing. That is if you
   (try to) set a capture format which is not supported by the cam, but is
   supported by libv4lconvert then SPICT will succeed and on SYNC / read the
   data will be converted for you and returned in the request format.

   Note that currently libv4l1 depends on the kernel v4l1 compatibility layer
   for: 1) Devices which are not capture only, 2) Emulation of many basic
   v4l1 ioctl's which require no driver specific handling.

   Note that no functionality is added to v4l1 devices, so if for example an
   obscure v4l1 device is opened which only supports some weird capture format
   then libv4l1 will not be of any help (in this case it would be best to get
   the driver converted to v4l2, as v4l2 has been designed to include weird
   capture formats, like hw specific bayer compression methods).
  |#
  
  (define-v4l1 v4l1-open (_fun [file : _string] [oflag : _int] -> _int)
    #:c-id v4l1_open)
  (define-v4l1 v4l1-close (_fun [fd : _int] -> _int)
    #:c-id v4l1_close)
  (define-v4l1 v4l1-dup (_fun [fd : _int] -> _int)
    #:c-id v4l1_dup)
  (define-v4l1 v4l1-ioctl (_fun [fd : _int] [request : _ulong] -> _int)
    #:c-id v4l1_ioctl)
  (define-v4l1 v4l1-read (_fun [fd : _int] [buffer : _gcpointer] [n : _size] -> _ssize)
    #:c-id v4l1_read)
  (define-v4l1 v4l1-mmap (_fun [start : _gcpointer] [len : _size] [prot : _int] [flags : _int]
                               [fd : _int] [offset : _int64] -> _pointer)
    #:c-id v4l1_mmap)
  (define-v4l1 v4l1-munmap (_fun [_start : _pointer] [len : _size] -> _int)
    #:c-id v4l1_munmap)
)
