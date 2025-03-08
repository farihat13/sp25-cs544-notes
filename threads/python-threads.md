# Threads and Locks in Python


## Basic threads


```python
lock = threading.Lock()
total = torch.tensor(0, dtype=torch.int32)

def inc(count):
    global total
    for i in range(count):
        lock.acquire()
        total += 1
        lock.release()

# inc(1000)
t1 = threading.Thread(target=inc, args=[100_000])
t2 = threading.Thread(target=inc, args=[100_000])
t1.start()
t2.start()
t1.join()
t2.join()
print(total)
```


## Basic locks


```python
bank_accounts = {"x": 25, "y": 100, "z": 200} 
lock = threading.Lock() # protects bank_accounts

def transfer(src, dst, amount):
    with lock: # lock will be released even if there was an exception
        success = False
        if bank_accounts[src] >= amount:
            bank_accounts[src] -= amount
            bank_accounts[dst] += amount
            success = True
        print("transferred" if success else "denied")
```


## Global Interpreter Lock (GIL)

- Only one thread can be running Python code in a process at once
- Python threads are bad for using multiple cores
- They're still useful for threads blocked on I/O
- Some Python libraries using other languages allow parallelism

Why GIL?
cpython (main Python interpreter) uses reference counting internally to know when it can free objects
implication: multiple threads modifying same integer
If we use lock to update references, then single threaded programs will become slow. That's why each python process has one GIL, which a thread needs to acquire before running. 


## Instruction Reordering and Caching

```python
import threading
y = 0
ready = True
def task(x):
 global y
 y = x ** 2 #l1
 ready = True #l2

t = threading.Thread(target=task, args=[5])
t.start()
while not ready:
 pass
print(y) # want 25 (not 0)
```
Two challenges:
- If l1 and l2 gets switched, then this code will not work.
- If y and ready is cached, and thread t is in cpu 0 and main thread is in cpu 1, and when updating cache, `ready` is updated first, then the code will fail.