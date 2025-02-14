# Import necessary modules
import grpc
import math_pb2_grpc, math_pb2
from concurrent import futures

# Define a class that inherits from the CalcServicer class defined in the gRPC stubs
class MyCalc(math_pb2_grpc.CalcServicer):

    # Define a method that corresponds to the Mult method in the gRPC service
    def Mult(self, request, context):
        try: 
            print("hi")
            print(request)
            return math_pb2.MultResp(result = request.x * request.y)
        except Exception as e:
            print(e)
            return math_pb2.MultResp(result = -1)
        
    def MultMany(self, request, context):
        print("hi")
        print(request)
        total = 1
        for num in request.nums:
            total *= num
        print(total)
        return math_pb2.MultResp(result = total)

# Create a gRPC server with a ThreadPoolExecutor and a specific option
server = grpc.server(futures.ThreadPoolExecutor(max_workers=10), 
                        options=[("grpc.so_reuseport", 0)])

# Add the CalcServicer (implemented in the MyCalc class) to the server
math_pb2_grpc.add_CalcServicer_to_server(MyCalc(), server)

# Specify the address and port the server should listen on
server.add_insecure_port('0.0.0.0:5442')

# Start the server
server.start()
print("started")

# Keep the server running until it's explicitly stopped
server.wait_for_termination()
