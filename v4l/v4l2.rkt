; cameracket/v4l2.rkt
(module cameracket/v4l2
  racket/base
  (require ffi/unsafe
           ffi/unsafe/define)
  (provide (except-out (all-defined-out)
                       define-v4l2))
  
  (define-ffi-definer define-v4l2 (ffi-lib "libv4l2"))
  
  #|
   Just like your regular open/close/etc, except that format conversion is
   done if necessary when capturing. That is if you (try to) set a capture
   format which is not supported by the cam, but is supported by libv4lconvert,
   then the try_fmt / set_fmt will succeed as if the cam supports the format
   and on dqbuf / read the data will be converted for you and returned in
   the request format. enum_fmt will also report support for the formats to
   which conversion is possible.

   Another difference is that you can make v4l2_read() calls even on devices
   which do not support the regular read() method.

   Note the device name passed to v4l2_open must be of a video4linux2 device,
   if it is anything else (including a video4linux1 device), v4l2_open will
   fail.

   Note that the argument to v4l2_ioctl after the request must be a valid
   memory address of structure of the appropriate type for the request (for
   v4l2 requests which expect a structure address). Passing in NULL or an
   invalid memory address will not lead to failure with errno being EFAULT,
   as it would with a real ioctl, but will cause libv4l2 to break, and you
   get to keep both pieces.
  |#
  
  (define-v4l2 v4l2-open (_fun [file : _file] [oflag : _int] -> _int)
    #:c-id v4l2_open)
  (define-v4l2 v4l2-close (_fun [fd : _int] -> _int)
    #:c-id v4l2_close)
  (define-v4l2 v4l2-dup (_fun [fd : _int] -> _int)
    #:c-id v4l2_dup)
  (define-v4l2 v4l2-ioctl (_fun [fd : _int] [request : _ulong] -> _int)
    #:c-id v4l2_ioctl)
  (define-v4l2 v4l2-read (_fun [fd : _int] [buffer : _gcpointer] [n : _size] -> _ssize)
    #:c-id v4l2_read)
  (define-v4l2 v4l2-write (_fun [fd : _int] [buffer : _gcpointer] [n : _size] -> _ssize)
    #:c-id v4l2_write)
  (define-v4l2 v4l2-mmap (_fun [start : _gcpointer] [len : _size] [prot : _int]
                               [flags : _int] [fd : _int] [offset : _int64] -> _gcpointer)
    #:c-id v4l2_mmap)
  (define-v4l2 v4l2-munmap (_fun [_start : _gcpointer] [len : _size] -> _int)
    #:c-id v4l2_munmap)

  ; Misc utility functions
  
  #|
   This function takes a value of 0 - 65535, and then scales that range to
   the actual range of the given v4l control id, and then if the cid exists
   and is not locked sets the cid to the scaled value.

   Normally returns 0, even if the cid did not exist or was locked, returns
   non 0 when an other error occured.
  |#
  (define-v4l2 v4l2-set-control (_fun [fd : _int] [cid : _int] [value : _int] -> _int)
    #:c-id v4l2_set_control)
  
  #|
   This function returns a value of 0 - 65535, scaled to from the actual range
   of the given v4l control id. When the cid does not exist, or could not be
   accessed -1 is returned.
  |#
  (define-v4l2 v4l2-get-control (_fun [fd : _int] [cid : _int] -> _int)
    #:c-id v4l2_get_control)
  
  #|
   "low level" access functions, these functions allow somewhat lower level
   access to libv4l2 (currently there only is v4l2_fd_open here)
  |#

  ; Flags for v4l2_fd_open's v4l2_flags argument
  
  #|
   Disable all format conversion done by libv4l2, this includes the software
   whitebalance, gamma correction, flipping, etc. libv4lconvert does. Use this
   if you want raw frame data, but still want the additional error checks and
   the read() emulation libv4l2 offers.
  |#
  (define V4L2_DISABLE_CONVERSION 1) ; 0x01
  
  #|
   This flag is *OBSOLETE*, since version 0.5.98 libv4l *always* reports
   emulated formats to ENUM_FMT, except when conversion is disabled.
  |#
  (define V4L2_ENABLE_ENUM_FMT_EMULATION 2) ; 0x02
  
  #|
   v4l2_fd_open: open an already opened fd for further use through
   v4l2lib and possibly modify libv4l2's default behavior through the
   v4l2_flags argument.

   Returns fd on success, -1 if the fd is not suitable for use through libv4l2
   (note the fd is left open in this case).
  |#
  (define-v4l2 v4l2-fd-open (_fun [fd : _int] [v4l2-flags : _int] -> _int)
    #:c-id v4l2_fd_open)
)
  