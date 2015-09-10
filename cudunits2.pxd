# -*- mode: cython -*-

cdef extern from "udunits2.h":
    # fake va_list:
    ctypedef struct va_list:
        pass

    # define UDUNITS-2 types:
    ctypedef struct ut_system:
        pass

    ctypedef struct ut_unit:
        pass

    ctypedef struct cv_converter:
        pass

    ctypedef int (*ut_error_message_handler)(char* fmt, va_list args)

    ctypedef enum ut_status:
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

    ctypedef enum ut_encoding:
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

    ut_unit* ut_clone(ut_unit* unit)

    ut_system* ut_get_system(ut_unit* unit)

    ut_unit* ut_get_dimensionless_unit_one(ut_system* system)

    ut_unit* ut_get_unit_by_name(ut_system* system, char* name)

    ut_unit* ut_get_unit_by_symbol(ut_system* system, char* symbol)

    ut_status ut_set_second(ut_unit* second)

    ut_status ut_add_name_prefix(ut_system* system, char* name, double value)

    ut_status ut_add_symbol_prefix(ut_system* system, char* symbol, double value)

    ut_unit* ut_new_base_unit(ut_system* system)

    ut_unit* ut_new_dimensionless_unit(ut_system* system)

    void ut_free_system(ut_system* system)

    void ut_free(ut_unit* unit)

    char* ut_get_name(ut_unit* unit, ut_encoding encoding)

    char* ut_get_symbol(ut_unit* unit, ut_encoding encoding)

    ut_status ut_map_symbol_to_unit(char* symbol, ut_encoding encoding, ut_unit* unit)

    ut_status ut_unmap_symbol_to_unit(ut_system* system, char* symbol, ut_encoding encoding)

    ut_status ut_map_unit_to_symbol(ut_unit* unit, char* symbol, ut_encoding encoding)

    ut_status ut_unmap_unit_to_symbol(ut_unit* unit, ut_encoding encoding)

    int ut_is_dimensionless(ut_unit* unit)

    int ut_same_system(ut_unit* unit1, ut_unit* unit2)

    ut_status ut_map_name_to_unit(char* name, ut_encoding encoding, ut_unit* unit)

    ut_status ut_unmap_name_to_unit(ut_system* system, char* name, ut_encoding encoding)

    ut_status ut_map_unit_to_name(ut_unit* unit, char* name, ut_encoding encoding)

    ut_status ut_unmap_unit_to_name(ut_unit* unit, ut_encoding encoding)

    int ut_format(ut_unit* unit, char* buf, size_t size, unsigned opts)

    ut_unit* ut_multiply(ut_unit* unit1, ut_unit* unit2)

    ut_unit* ut_divide(ut_unit* unit1, ut_unit* unit2)

    ut_unit* ut_scale(double factor, ut_unit* unit)

    ut_unit* ut_offset(ut_unit* unit, double offset)

    ut_unit* ut_offset_by_time(ut_unit* unit, double origin)

    ut_unit* ut_invert(ut_unit* unit)

    ut_unit* ut_raise(ut_unit* unit, int power)

    ut_unit* ut_log(double base, ut_unit* reference)

    ut_unit* ut_root(ut_unit* unit, int	root)

    int ut_compare(ut_unit* unit1, ut_unit* unit2)

    int ut_are_convertible(ut_unit* unit1, ut_unit* unit2)

    cv_converter* ut_get_converter(ut_unit* u1, ut_unit* u2)

    double ut_encode_date(int year, int month, int day)

    double ut_encode_clock(int hours, int minutes, double seconds)

    double ut_encode_time(int year, int month, int day, int hour, int minute, double second)

    void ut_decode_time(double value, int *year, int *month, int *day,
                        int *hour, int *minute, double *second, double *resolution)

    ut_error_message_handler ut_set_error_message_handler(ut_error_message_handler handler)

    int ut_ignore(char* fmt, va_list args)

    ut_status ut_get_status()


cdef extern from "converter.h":
    cv_converter* cv_get_trivial()

    cv_converter* cv_get_inverse()

    cv_converter* cv_get_scale(double slope)

    cv_converter* cv_get_offset(double intercept)

    cv_converter* cv_get_galilean(double slope, double intercept)

    cv_converter* cv_get_log(double base)

    cv_converter* cv_get_pow(double base)

    cv_converter* cv_combine(cv_converter* first, cv_converter* second)

    void cv_free(cv_converter* conv)

    float cv_convert_float(cv_converter* converter, float value)

    double cv_convert_double(cv_converter* converter, double value)

    float* cv_convert_floats(cv_converter* converter, float* input, size_t count, float* out)

    double* cv_convert_doubles(cv_converter* converter, double* input, size_t count, double* out)

    int cv_get_expression(cv_converter* conv, char* buf, size_t max, char* variable)
