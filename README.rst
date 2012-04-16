The ``udunits2`` module
======================

Creating and manipulating units
-------------------------

First, import the module:

    >>> from udunits2 import *

Before a unit can be created one needs to create a unit system:

    >>> sys = System()

The constructor also takes a path to an XML file with a unit database.

Now we're ready to create some units.

    >>> kg = Unit(sys, "kg")
    >>> m = Unit(sys, "meter")
    >>> s = Unit(sys, "second")
    >>> kg / m**2 / s
    <units of 'm-2.kg.s-1'>

Converting data
-------------

The ``Converter`` class is used to convert data between different units

    >>> converter = Converter((Unit(sys, "Celsius"), Unit(sys, "Fahrenheit")))
    >>> converter
    <unit converter 'y = 1.8*x + 32'>
    >>> converter(0.0)
    31.999999999999886

It is also possible to process NumPy arrays (``float32`` and ``float64``), as well as anything ``numpy.asarray`` can handle.
    
    >>> from numpy import zeros
    >>> a = zeros((3,3), dtype=np.int) + 10
    >>> converter(a)
    array([[ 50.,  50.,  50.],
           [ 50.,  50.,  50.],
           [ 50.,  50.,  50.]])

    >>> converter([0, 10, 20, 30])
    array([ 32.,  50.,  68.,  86.])


Testing this module
-------------------

You can check if this module does what is promised above by running

``python -m doctest -v README.rst``

