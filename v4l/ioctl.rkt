#lang racket/base
; ioctl.rkt
; wrapper to ioctl.h
(require racket/contract)
(provide (all-defined-out))

(define _IOC_NRBITS     8)
(define _IOC_TYPEBITS   8)

#|
 # Let any architecture override either of the following before
 # including this file.
 |#

(define _IOC_SIZEBITS  14)
(define _IOC_DIRBITS   2)

(define _IOC_NRMASK     (- (arithmetic-shift 1 _IOC_NRBITS) 1))
(define _IOC_TYPEMASK   (- (arithmetic-shift 1 _IOC_TYPEBITS) 1))
(define _IOC_SIZEMASK   (- (arithmetic-shift 1 _IOC_SIZEBITS) 1))
(define _IOC_DIRMASK    (- (arithmetic-shift 1 _IOC_DIRBITS) 1))

(define _IOC_NRSHIFT    0)
(define _IOC_TYPESHIFT  (+ _IOC_NRSHIFT _IOC_NRBITS))
(define _IOC_SIZESHIFT  (+ _IOC_TYPESHIFT _IOC_TYPEBITS))
(define _IOC_DIRSHIFT   (+ _IOC_SIZESHIFT _IOC_SIZEBITS))

#|
 # Direction bits, which any architecture can choose to override
 # before including this file.
 |#

(define _IOC_NONE      0)
(define _IOC_WRITE     1)
(define _IOC_READ      2)

(define/contract (_IOC dir type nr size)
  (-> integer? string? integer? integer? integer?)
  (bitwise-ior
   (arithmetic-shift dir _IOC_DIRSHIFT)
   (arithmetic-shift type _IOC_TYPESHIFT)
   (arithmetic-shift nr _IOC_NRSHIFT)
   (arithmetic-shift size _IOC_SIZESHIFT)))

; length of a list a la id->list
(define/contract (_IOC_TYPECHECK t)
  (-> list? integer?)
  (length t))

; used to create numbers
(define/contract (_IO type nr)
  (-> bytes? integer? integer?)
  (let ([type (bytes-ref type 0)])
    (_IOC _IOC_NONE type nr 0)))
(define/contract (_IOR type nr size)
  (-> bytes? integer? list? integer?)
  (let ([type (bytes-ref type 0)])
    (_IOC _IOC_READ type nr (_IOC_TYPECHECK size))))
(define/contract (_IOW type nr size)
  (-> bytes? integer? list? integer?)
  (let ([type (bytes-ref type 0)])
    (_IOC _IOC_WRITE type nr (_IOC_TYPECHECK size))))
(define/contract (_IOWR type nr size)
  (-> bytes? integer? list? integer?)
  (let ([type (bytes-ref type 0)])
    (bitwise-ior (_IOC _IOC_READ type nr (_IOC_TYPECHECK size))
                 (_IOC _IOC_WRITE type nr (_IOC_TYPECHECK size)))))
; use a list for the struct a la id->list
(define/contract (_IOR_BAD type nr size)
  (-> bytes? integer? list? integer?)
  (let ([type (bytes-ref type 0)])
    (_IOC _IOC_READ type nr (length size))))
(define/contract (_IOW_BAD type nr size)
  (-> bytes? integer? list? integer?)
  (let ([type (bytes-ref type 0)])
    (_IOC _IOC_WRITE type nr (length size))))
(define/contract (_IOWR_BAD type nr size)
  (-> bytes? integer? list? integer?)
  (let ([type (bytes-ref type 0)])
    (bitwise-ior (_IOC _IOC_READ type nr (length size))
                 (_IOC _IOC_WRITE type nr (length size)))))

; used to decode ioctl numbers...
(define (_IOC_DIR nr)
  (bitwise-and (arithmetic-shift nr (- _IOC_DIRSHIFT)) _IOC_DIRMASK))
(define (_IOC_TYPE nr)
  (bitwise-and (arithmetic-shift nr (- _IOC_TYPESHIFT)) _IOC_TYPEMASK))
(define (_IOC_NR nr)
  (bitwise-and (arithmetic-shift nr (- _IOC_NRSHIFT)) _IOC_NRMASK))
(define (_IOC_SIZE nr)
  (bitwise-and (arithmetic-shift nr (- _IOC_SIZESHIFT)) _IOC_SIZEMASK))

; ...and for the drivers/sound files...

(define IOC_IN          (arithmetic-shift _IOC_WRITE _IOC_DIRSHIFT))
(define IOC_OUT         (arithmetic-shift _IOC_READ _IOC_DIRSHIFT))
(define IOC_INOUT       (bitwise-ior (arithmetic-shift _IOC_WRITE _IOC_DIRSHIFT)
                                     (arithmetic-shift _IOC_READ _IOC_DIRSHIFT)))
(define IOCSIZE_MASK    (arithmetic-shift _IOC_SIZEMASK _IOC_SIZESHIFT))
(define IOCSIZE_SHIFT   _IOC_SIZESHIFT)
