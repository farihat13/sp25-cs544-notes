# gRPC 

https://github.com/cs544-wisc/f23/tree/main/lec/13-grpc-compose

https://mediaspace.wisc.edu/media/Tyler%20Caraza-Harter-Noland%20132-10_04_23-13%3A20%3A02/1_bu99brbq

https://grpc.io/docs/languages/python/basics/


| Protocol         |                 |
|------------------|--------------------------|
| gRPC             | Methods                  |
| HTTP             | URL (domain/IP + port + resource) |
| TCP or UDP       | IP addresses + ports     |
| Internet Protocol| IP addresses             |
| Ethernet or Wi-Fi| MAC addresses            |

By default, gRPC uses Protocol Buffers, Google’s mature open source mechanism for serializing structured data (although it can be used with other data formats such as JSON).

## Serialization/deserialization (Protobufs)

*How do we represent arguments and return values as bytes in a request/response body?*

 Challenges:

 1. every language has different types and we want cross-lang calls
 2. different CPUs order bytes differently

 gRPC uses Googl's **Protocol Buffers** for uniform types across systems and languages.

### What are the Benefits of Using Protocol Buffers? 

https://protobuf.dev/overview/ 

https://protobuf.dev/programming-guides/proto3/

## Workflow

0. install gRPC library
$ `pip3 install grpcio==1.58.0 grpcio-tools==1.58.0`

1. write `math.proto`

    ```proto
    // messages (protocol buffers, aka "protobufs")
    message MultReq {
        int32 x = 1;
        int32 y = 2;
    }
    message MultResp { 
        int32 result = 1;
    }

    // services (RPC functions)
    service Calc {
        rpc Mult(MultReq) returns (MultResp);
    }
    ```

2. compile `math.proto`

    $ `python3 -m grpc_tools.protoc -I=. --python_out=. --grpc_python_out=. math.proto`

    This will create two files `math_pb2.py` and `math_pb2_grpc.py`

    `math_pb2_grpc.py` will contain a class `CalcServicer`. This class contain  `def Mult(self, request, context)` (notice `service` in our `math.proto`)

3. test `math_pb2.py`

    ```python
    import math_pb2
    pb = math_pb2.MultReq(x=3, y=4)
    s = pb.SerializePartialToString()
    print(s, len(s))
    ```

4. write `server.py`

    ```python
    import grpc
    import math_pb2_grpc, math_pb2
    from concurrent import futures
    # Inherit CalcServicer and implement Mult
    class MyCalc(math_pb2_grpc.CalcServicer):
        def Mult(self, request, context):
            return math_pb2.MultResp(result = request.x * request.y)

    # Create a gRPC server
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10), 
                            options=[("grpc.so_reuseport", 0)])
    # Add CalcServicer to the server
    math_pb2_grpc.add_CalcServicer_to_server(MyCalc(), server)
    # Specify the address and port the server should listen on
    server.add_insecure_port('0.0.0.0:5442')
    server.start()
    print("started")
    server.wait_for_termination()
    ```

5. run server in the background and forward stdout and stderr to log.txt
$ `python3 server.py &> log.txt &`

    for debug purpose, to avoid buffering in log.txt
    $ `python3 -u server.py &> log.txt &`

    in case of port collision

    $ `lsof -i tcp` 

    $ `kill 32423`
    or `pkill python3` (risky)

6. write `client.py`

    ```python
    import math_pb2_grpc, math_pb2
    import grpc
    # Create a channel to the server
    channel = grpc.insecure_channel('localhost:5442')
    # Create a stub (client) for the Calc service defined in the Protocol Buffers file
    stub = math_pb2_grpc.CalcStub(channel)
    # Call the Mult method on the stub
    resp = stub.Mult(math_pb2.MultReq(x=2, y=3))
    ```


