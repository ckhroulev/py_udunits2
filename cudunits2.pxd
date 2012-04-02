# -*- mode: cython -*-

cdef extern from "udunits2/udunits2.h":
    ctypedef struct ut_system:
        pass

    ctypedef struct ut_unit:
        pass

    cdef enum ut_status:
        UT_SUCCESS = 0
        UT_BAD_ARG
        UT_EXISTS
        UT_NO_UNIT
        UT_OS
        UT_NOT_SAME_SYSTEM
        UT_MEANINGLESS
        UT_NO_SECOND
        UT_VISIT_ERROR
        UT_CANT_FORMAT
        UT_SYNTAX
        UT_UNKNOWN
        UT_OPEN_ARG
        UT_OPEN_ENV
        UT_OPEN_DEFAULT
        UT_PARSE

    cdef enum ut_encoding:
        UT_ASCII = 0
        UT_ISO_8859_1 = 1
        UT_LATIN1 = UT_ISO_8859_1
        UT_UTF8 = 2

    cdef enum:
        UT_NAMES = 4
        UT_DEFINITION = 8

    ut_system* ut_new_system()

    ut_system* ut_read_xml(char* path)

    ut_unit* ut_parse(ut_system* system, char* string, ut_encoding encoding)

    void ut_free_system(ut_system* system)

    void ut_free(ut_unit* unit)

    char* ut_get_name(ut_unit* unit, ut_encoding encoding)

    ut_status ut_get_status()


