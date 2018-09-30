from pykcp import Kcp
from threading import Thread
from time import sleep as _sleep, time as _time


def time():
    t = int(_time()*1000) % 100000000
    return t

def sleep(ms):
    _sleep(ms/1000)


def recv_callback(buf):
    global send_kcp
    #print('buffer to send to sendkcp:', buf)
    send_kcp.input(buf)

recv_kcp = Kcp(1, 2, recv_callback)
recv_kcp.nodelay(1, 10, 2, 1)
recv_kcp.wndsize(128,128)

def send_callback(buf):
    global recv_kcp
    #print('buffer to send to recvkcp:', buf)
    recv_kcp.input(buf)

send_kcp = Kcp(1, 2, send_callback)
send_kcp.nodelay(0, 10, 2, 1)
send_kcp.wndsize(128,128)

first = True

cnt = 100

while cnt >=0 :
    current = time()
    next1 = recv_kcp.check(current)
    next2 = send_kcp.check(current)
    nextt = min(next1, next2)
    diff = nextt - current
    if diff > 0:
        sleep(diff)
        current = time()

    send_kcp.update(current)
    recv_kcp.update(current)
    if first:
        send_kcp.send(b'x'*1024)
        first = not first

    while True:
        buf = recv_kcp.recv()
        if not buf:
            break
        print('recv recvd:', buf)
        recv_kcp.send(buf)
        cnt -= 1

    while True:
        buf = send_kcp.recv()
        if not buf:
            break
        print('send recvd:', buf)
        send_kcp.send(buf)
        cnt -= 1

