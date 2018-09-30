from cpython.pycapsule cimport *
from libc.stdint cimport uint32_t, int32_t
from cpython.mem cimport PyMem_Malloc, PyMem_Free
from cpython.object cimport PyObject


cdef extern from "ikcp.h":
    ctypedef uint32_t ISTDUINT32;
    ctypedef int32_t ISTDINT32; 
    ctypedef ISTDINT32 IINT32;
    ctypedef ISTDUINT32 IUINT32;

    struct IQUEUEHEAD:
        IQUEUEHEAD *next
        IQUEUEHEAD *prev

    struct IKCPCB:
        IUINT32 conv, mtu, mss, state;
        IUINT32 snd_una, snd_nxt, rcv_nxt;
        IUINT32 ts_recent, ts_lastack, ssthresh;
        IINT32 rx_rttval, rx_srtt, rx_rto, rx_minrto;
        IUINT32 snd_wnd, rcv_wnd, rmt_wnd, cwnd, probe;
        IUINT32 current, interval, ts_flush, xmit;
        IUINT32 nrcv_buf, nsnd_buf;
        IUINT32 nrcv_que, nsnd_que;
        IUINT32 nodelay, updated;
        IUINT32 ts_probe, probe_wait;
        IUINT32 dead_link, incr;
        IQUEUEHEAD snd_queue;
        IQUEUEHEAD rcv_queue;
        IQUEUEHEAD snd_buf;
        IQUEUEHEAD rcv_buf;
        IUINT32 *acklist;
        IUINT32 ackcount;
        IUINT32 ackblock;
        void *user;
        char *buffer;
        int fastresend;
        int nocwnd;
        int logmask;
        int (*output)(const char *buf, int len, IKCPCB *kcp, void *user);
        void (*writelog)(const char *log, IKCPCB *kcp, void *user);

    ctypedef IKCPCB ikcpcb;
    ikcpcb* ikcp_create(IUINT32 conv, void *user);
    void ikcp_release(ikcpcb *kcp);
    int ikcp_recv(ikcpcb *kcp, char *buffer, int len);
    int ikcp_send(ikcpcb *kcp, const char *buffer, int len);
    void ikcp_update(ikcpcb *kcp, IUINT32 current);
    IUINT32 ikcp_check(const ikcpcb *kcp, IUINT32 current);
    int ikcp_input(ikcpcb *kcp, const char *data, long size);
    void ikcp_flush(ikcpcb *kcp);
    int ikcp_wndsize(ikcpcb *kcp, int sndwnd, int rcvwnd);
    int ikcp_nodelay(ikcpcb *kcp, int nodelay, int interval, int resend, int nc);
