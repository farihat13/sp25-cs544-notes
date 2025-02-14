# PyTorch basics


## References
[cs544/f23/lec/05](https://tyler.caraza-harter.com/cs544/f23/lec/05-pytorch-basics/slides.pdf)


## Types

integers: `uint8`, `int8`, `int16`, `int32`, `int64`

floats: `float16`, `float32`, `float64`

```python
import torch
x = torch.tensor(3.14, dtype=torch.float16)
```

common to have one type for computation, another for storage.

Scenario: all the ints in your dataset fit nicely in 3 bytes. Should you come up with a new integer byte representation?

