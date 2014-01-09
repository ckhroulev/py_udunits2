#!python
#cython: embedsignature=True

cimport cudunits2 as u
import numbers

cimport numpy as np
import numpy as np

ctypedef np.float64_t double_t
ctypedef np.float32_t float_t

# ignore error messages:
u.ut_set_error_message_handler(u.ut_ignore)

cdef class System:
    "A unit-system corresponding to an XML file."
    cdef u.ut_system* _c_system

    def __cinit__(self, path = None, empty = False):
        """
        Creates a unit system.

        Parameters:
        ==========

        path : the path to an XML file. If 'None', the default path is used.
        empty : create an empty unit system. 'path' is ignored if 'empty' is set.
        """
        if empty == True:
            self._c_system = u.ut_new_system()
        else:
            if path is None:
                self._c_system = u.ut_read_xml(NULL)
            else:
                self._c_system = u.ut_read_xml(path)

        if self._c_system == NULL:
            err = u.ut_get_status()
            raise Exception("initialization failed: ut_get_status() returns %s" % err)

    def __dealloc__(self):
        u.ut_free_system(self._c_system)

    def get_unit_by_name(self, name):
        tmp = Unit(None)
        tmp._c_unit = u.ut_get_unit_by_name(self._c_system, name)

        return tmp

    def get_dimensionless_unit_one(self):
        tmp = Unit(None)
        tmp._c_unit = u.ut_get_dimensionless_unit_one(self._c_system)

        return tmp

    def get_unit_by_symbol(self, symbol):
        tmp = Unit(None)
        tmp._c_unit = u.ut_get_unit_by_symbol(self._c_system, symbol)

        return tmp

    def add_name_prefix(self, prefix, value):
        errcode = u.ut_add_name_prefix(self._c_system, prefix, value)

    def add_symbol_prefix(self, prefix, value):
        errcode = u.ut_add_symbol_prefix(self._c_system, prefix, value)

    def new_base_unit(self):
        tmp = Unit(None)
        tmp._c_unit = u.ut_new_base_unit(self._c_system)

        return tmp

    def new_dimensionless_unit(self):
        tmp = Unit(None)
        tmp._c_unit = u.ut_new_dimensionless_unit(self._c_system)

        return tmp

    def unmap_symbol(self, symbol):
        u.ut_unmap_symbol_to_unit(self._c_system, symbol, u.UT_ASCII)

cdef class Unit:
    "Unit class"
    cdef u.ut_unit* _c_unit

    def multiply(Unit self, Unit x):
        result = Unit(None)
        result._c_unit = u.ut_multiply(self._c_unit, x._c_unit)

        return result

    def divide(Unit self, Unit x):
        result = Unit(None)
        result._c_unit = u.ut_divide(self._c_unit, x._c_unit)

        return result

    def scale(Unit self, float x):
        result = Unit(None)
        result._c_unit = u.ut_scale(x, self._c_unit)

        return result

    def format(self, encoding = u.UT_ASCII):
        N = 2048
        tmp = ' ' * N                # buffer
        M = u.ut_format(self._c_unit, tmp, N - 1, encoding)
        return tmp[:M]

    def __cinit__(self, System sys, spec=""):
        if sys is not None:
            self._c_unit = u.ut_parse(sys._c_system, spec, u.UT_ASCII)
            if self._c_unit == NULL:
                raise ValueError("invalid unit string: '%s'" % spec)
        else:
            self._c_unit = NULL         # allow creating an empty Unit

    def __dealloc__(self):
        u.ut_free(self._c_unit)

    def __str__(self):
        tmp = <char*>u.ut_get_name(self._c_unit, u.UT_ASCII)
        if tmp:
            return tmp
        else:
            return self.format()

    def copy(self):
        tmp = Unit(None)
        tmp._c_unit = u.ut_clone(self._c_unit)
        return tmp

    def __repr__(self):
        return "<units of '%s'>" % self.__str__()

    def __mul__(self, x):
        if isinstance(self, Unit) and isinstance(x, Unit):
            return self.multiply(x)

        if isinstance(self, Unit) and isinstance(x, (int, long, float)):
            return self.scale(x)

        if isinstance(self, (int, long, float)) and isinstance(x, Unit):
            return x.scale(self)

    def __div__(self, x):
        if isinstance(self, Unit) and isinstance(x, Unit):
            return self.divide(x)

        if isinstance(self, Unit) and isinstance(x, (int, long, float)):
            return self.scale(1.0/x)

        if isinstance(self, (int, long, float)) and isinstance(x, Unit):
            return self * (x ** (-1))

    def __pow__(Unit self, int x, dummy):
        result = Unit(None)
        result._c_unit = u.ut_raise(self._c_unit, x)

        return result

    def __cmp__(Unit self, Unit other):
        return u.ut_compare(self._c_unit, other._c_unit)

    def map_symbol(self, symbol):
        u.ut_map_symbol_to_unit(symbol, u.UT_ASCII, self._c_unit)

    def map_to_symbol(self, symbol):
        u.ut_map_unit_to_symbol(self._c_unit, symbol, u.UT_ASCII)

    def map_to_name(self, name):
        u.ut_map_unit_to_name(self._c_unit, name, u.UT_ASCII)

    def unmap_to_symbol(self):
        u.ut_unmap_unit_to_symbol(self._c_unit, u.UT_ASCII)

    def unmap_to_name(self):
        u.ut_unmap_unit_to_name(self._c_unit, u.UT_ASCII)

    def is_dimensionless(self):
        return u.ut_is_dimensionless(self._c_unit)

    def offset(self, value):
        tmp = Unit(None)
        tmp._c_unit = u.ut_offset(self._c_unit, value)

        return tmp

    def offset_by_time(self, value):
        tmp = Unit(None)
        tmp._c_unit = u.ut_offset_by_time(self._c_unit, value)

        return tmp

cdef class Converter:
    "Unit converter class."
    cdef u.cv_converter* _c_converter

    cdef u.cv_converter* _get_converter(self, Unit u1, Unit u2):
        return u.ut_get_converter(u1._c_unit, u2._c_unit)

    cdef u.cv_converter* _combine(self, Converter c1, Converter c2):
        return u.cv_combine(c1._c_converter, c2._c_converter)

    cdef _convert(self, float x):
        return u.cv_convert_double(self._c_converter, x)

    cdef _convert_doubles(self, np.ndarray[dtype=double_t] x):
        cdef np.ndarray[dtype=double_t] output = np.zeros_like(x)

        u.cv_convert_doubles(self._c_converter, <double*>x.data, x.size, <double*>output.data)

        return output

    cdef _convert_floats(self, np.ndarray[dtype=float_t] x):
        cdef np.ndarray[dtype=float_t] output = np.zeros_like(x)

        u.cv_convert_floats(self._c_converter, <float*>x.data, x.size, <float*>output.data)

        return output

    def __cinit__(self, arg = None, **kwargs):
        if isinstance(arg, tuple):
            arg1 = arg[0]
            arg2 = arg[1]

            if isinstance(arg1, Unit) and isinstance(arg2, Unit):
                self._c_converter = self._get_converter(arg1, arg2)
            elif isinstance(arg1, Converter) and isinstance(arg2, Converter):
                self._c_converter = self._combine(arg1, arg2)
        else:
            if 'log' in kwargs:
                self._c_converter = u.cv_get_log(float(kwargs['log']))
            elif 'pow' in kwargs:
                self._c_converter = u.cv_get_pow(float(kwargs['pow']))
            elif 'inverse' in kwargs and kwargs['inverse']:
                self._c_converter = u.cv_get_inverse()
            elif 'scale' in kwargs:
                self._c_converter = u.cv_get_scale(float(kwargs['scale']))
            elif 'offset' in kwargs:
                self._c_converter = u.cv_get_offset(float(kwargs['offset']))
            elif 'trivial' in kwargs and kwargs['trivial']:
                self._c_converter = u.cv_get_trivial()
            elif 'scale' in kwargs and 'intercept' in kwargs:
                self._c_converter = u.cv_get_galilean(kwargs['slope'], kwargs['intercept'])

    def __dealloc__(self):
        u.cv_free(self._c_converter)

    def __repr__(self):
        return "<unit converter 'y = %s'>" % self.__str__()

    def __str__(self):
        N = 2048
        tmp = ' ' * N                # buffer
        M = u.cv_get_expression(self._c_converter, tmp, N - 1, "x")
        return tmp[:M]

    def __call__(self, x):
        if isinstance(x, numbers.Number):
            return self._convert(x)
        # use cv_convert_floats for speed (if possible), convert everything else into doubles
        elif isinstance(x, np.ndarray) and x.dtype == np.float32:
            return self._convert_floats(x.reshape(x.size)).reshape(x.shape)
        else:
            tmp = np.asarray(x, dtype=np.float64)
            return self._convert_doubles(tmp.reshape(tmp.size)).reshape(tmp.shape)

# Helper functions:
def encode_date(int year, int month, int day):
    return u.ut_encode_date(year, month, day)

def encode_clock(int hour, int minute, float second):
    return u.ut_encode_clock(hour, minute, second)

def encode_time(int year, int month, int day, int hour, int minute, float second):
    return u.ut_encode_time(year, month, day, hour, minute, second)

def decode_time(float value):
    "Decodes a time from a double-precision value."
    cdef int year = 0, month = 0, day = 0, hour = 0, minute = 0
    cdef double second = 0, resolution = 0

    u.ut_decode_time(value, &year, &month, &day, &hour, &minute, &second, &resolution)

    return (year, month, day, hour, minute, second, resolution)

def same_system(Unit u1, Unit u2):
    "Returns True if u1 and u2 belong to the same system."
    return u.ut_same_system(u1._c_unit, u2._c_unit)

def log(float base, Unit u1):
    "Returns log (base 'base') of u1."
    result = Unit(None)
    result._c_unit = u.ut_log(base, u1._c_unit)

    return result

def root(Unit u1, int power):
    "Returns u1**(1/power)."
    result = Unit(None)
    result._c_unit = u.ut_root(u1._c_unit, power)

    return result

def are_convertible(Unit u1, Unit u2):
    "Returns True if u1 and u2 are convertible."
    return u.ut_are_convertible(u1._c_unit, u2._c_unit) != 0
