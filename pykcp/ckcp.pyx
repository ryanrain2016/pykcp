from ckcp cimport *

cdef int BUFFER_LEN = 4*1024*1024

cdef class Kcp:
    cdef IKCPCB* _c_ikcpcb
    _ckcps = {}
    cdef char* _c_buffer

    def __cinit__(self, int conv, user, cb):
        self._c_ikcpcb = ikcp_create(conv, <void*>user)
        self._c_ikcpcb.output = _kcp_callback
        if self._c_ikcpcb is NULL:
            raise MemoryError
        self._c_buffer = <char *>PyMem_Malloc((BUFFER_LEN + 1) * sizeof(char))
        if self._c_buffer is NULL:
            raise MemoryError
        self.__class__._ckcps[<int><void*>self._c_ikcpcb] = cb

    def __dealloc__(self):
        if self._c_ikcpcb is not NULL:
            ikcp_release(self._c_ikcpcb)
        if self._c_buffer is not NULL:
            PyMem_Free(self._c_buffer)
        cdef int ptr = <int><void*>self._c_ikcpcb
        if ptr in self.__class__._ckcps:
            del self.__class__._ckcps[ptr]

    cpdef bytes recv(self, int n=BUFFER_LEN):
        cdef int32_t size = ikcp_recv(self._c_ikcpcb, self._c_buffer, n)
        if size <= 0:
            return b''
        return self._c_buffer[:size]


    cpdef int send(self, bytes buffer, int32_t size=-1):
        if size != -1:
            buffer = buffer[:size]
        else:
            size = len(buffer)
        return ikcp_send(self._c_ikcpcb, buffer, size)

    cpdef void update(self, int32_t current):
        ikcp_update(self._c_ikcpcb, current)

    cpdef int32_t check(self, int32_t current):
        return ikcp_check(self._c_ikcpcb, current)

    cpdef int input(self, bytes buffer, int32_t size=-1):
        if size != -1:
            buffer = buffer[:size]
        else:
            size = len(buffer)
        return ikcp_input(self._c_ikcpcb, buffer, size)

    cpdef void flush(self):
        ikcp_flush(self._c_ikcpcb)

    cpdef int wndsize(self, int sndwnd, int rcvwnd):
        cdef int32_t i_nsndwnd = sndwnd
        cdef int32_t i_nrcvwnd = rcvwnd
        return ikcp_wndsize(self._c_ikcpcb, i_nsndwnd, i_nrcvwnd)

    cpdef nodelay(self, int nodelay, int interval, int resend, int nc):
        cdef int32_t i_nodelay = nodelay
        cdef int32_t i_interval = interval
        cdef int32_t i_resend = resend
        cdef int32_t i_nc = nc
        return ikcp_nodelay(self._c_ikcpcb, i_nodelay, i_interval, i_resend, i_nc)


cdef int _kcp_callback(const char *buf, int len, IKCPCB *kcp, void *user):
    _kcp_cb = Kcp._ckcps[<int><void*>kcp]
    cdef bytes py_string = buf[:len]
    _kcp_cb(py_string)