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

    >>> converter = Converter((Unit(sys, "Celsius"), Unit(sys, "Kelvin")))
    >>> converter
    <unit converter 'y = x + 273.15'>
    >>> converter(0.0)
    273.15

It is also possible to process lists and NumPy arrays (``float32`` and ``float64``).

    >>> converter([0, 10, 20, 30])
    [273.15, 283.15, 293.15, 303.15]

    >>> from numpy import zeros
    >>> a = zeros((3,3)) + 10
    >>> converter(a)
    array([[ 283.15,  283.15,  283.15],
           [ 283.15,  283.15,  283.15],
           [ 283.15,  283.15,  283.15]])

