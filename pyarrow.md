# PyArrow, MMap and Swap files


## PyArrow


## MMap

makes handling more memory easy through page caching.

for example, suppose i have 512 MB RAM and `test.arrow` file is 1.4 GB. 


The following code is trying to read the whole file into memory, so it will crash due to lack of memory.
```python
with pa.ipc.open_file("test.arrow") as f:
    tbl = f.read_all()
```


When we use filebacked mmap and read the whole file through the mmap, mmap caches pages as it sees fit to avoid overstressing the memory. So, the following code will work perfectly fine. 
```python
import mmap
import pyarrow as pa

with open("test.arrow", "rb") as f:
    mm = mmap.mmap(f.fileno(), 0, access = mmap.ACCESS_READ)

with pa.ipc.open_file(mm) as f:
    tbl = f.read_all() 
```

$ `ps ax`

$ `cd /proc`

$ `ls`

$ `cd 102`

$ `cat maps`

$ `cat maps | grep test.arrow`