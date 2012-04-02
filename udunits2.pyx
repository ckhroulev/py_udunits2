cimport cudunits2 as u

cdef class System:
    cdef u.ut_system* _c_system

    def __cinit__(self, path = None, empty = False):

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

cdef class Unit:
    cdef u.ut_unit* _c_unit
    cdef u.ut_system* _c_system

    def __cinit__(self, System sys, spec=""):
        self._c_system = sys._c_system
        self._c_unit = u.ut_parse(self._c_system, spec, u.UT_UTF8)

    def __dealloc__(self):
        u.ut_free(self._c_unit)

    def __str__(self):
        return u.ut_get_name(self._c_unit, u.UT_ASCII)

    def __repr__(self):
        return "<units of '%s'>" % self.__str__()
