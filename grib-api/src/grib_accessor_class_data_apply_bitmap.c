/*
 * Copyright 2005-2014 ECMWF.
 *
 * This software is licensed under the terms of the Apache Licence Version 2.0
 * which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
 *
 * In applying this licence, ECMWF does not waive the privileges and immunities granted to it by
 * virtue of its status as an intergovernmental organisation nor does it submit to any jurisdiction.
 */

#include "grib_api_internal.h"

/*
   This is used by make_class.pl

   START_CLASS_DEF
   CLASS      = accessor
   SUPER      = grib_accessor_class_gen
   IMPLEMENTS = init
   IMPLEMENTS = unpack_double;unpack_double_element
   IMPLEMENTS = pack_double
   IMPLEMENTS = value_count
   IMPLEMENTS = dump;get_native_type
   MEMBERS=const char*  coded_values
   MEMBERS=const char*  bitmap
   MEMBERS=const char*  missing_value
   MEMBERS=const char*  number_of_data_points
   MEMBERS=const char*  number_of_values
   MEMBERS=const char*  binary_scale_factor
   END_CLASS_DEF
 */

/* START_CLASS_IMP */

/*

Don't edit anything between START_CLASS_IMP and END_CLASS_IMP
Instead edit values between START_CLASS_DEF and END_CLASS_DEF
or edit "accessor.class" and rerun ./make_class.pl

*/

static int  get_native_type(grib_accessor*);
static int pack_double(grib_accessor*, const double* val,size_t *len);
static int unpack_double(grib_accessor*, double* val,size_t *len);
static long value_count(grib_accessor*);
static void dump(grib_accessor*, grib_dumper*);
static void init(grib_accessor*,const long, grib_arguments* );
static void init_class(grib_accessor_class*);
static int unpack_double_element(grib_accessor*,size_t i, double* val);

typedef struct grib_accessor_data_apply_bitmap {
    grib_accessor          att;
/* Members defined in gen */
/* Members defined in data_apply_bitmap */
	const char*  coded_values;
	const char*  bitmap;
	const char*  missing_value;
	const char*  number_of_data_points;
	const char*  number_of_values;
	const char*  binary_scale_factor;
} grib_accessor_data_apply_bitmap;

extern grib_accessor_class* grib_accessor_class_gen;

static grib_accessor_class _grib_accessor_class_data_apply_bitmap = {
    &grib_accessor_class_gen,                      /* super                     */
    "data_apply_bitmap",                      /* name                      */
    sizeof(grib_accessor_data_apply_bitmap),  /* size                      */
    0,                           /* inited */
    &init_class,                 /* init_class */
    &init,                       /* init                      */
    0,                  /* post_init                      */
    0,                    /* free mem                       */
    &dump,                       /* describes himself         */
    0,                /* get length of section     */
    0,              /* get length of string      */
    &value_count,                /* get number of values      */
    0,                 /* get number of bytes      */
    0,                /* get offset to bytes           */
    &get_native_type,            /* get native type               */
    0,                /* get sub_section                */
    0,               /* grib_pack procedures long      */
    0,               /* grib_pack procedures long      */
    0,                  /* grib_pack procedures long      */
    0,                /* grib_unpack procedures long    */
    &pack_double,                /* grib_pack procedures double    */
    &unpack_double,              /* grib_unpack procedures double  */
    0,                /* grib_pack procedures string    */
    0,              /* grib_unpack procedures string  */
    0,                 /* grib_pack procedures bytes     */
    0,               /* grib_unpack procedures bytes   */
    0,            /* pack_expression */
    0,              /* notify_change   */
    0,                /* update_size   */
    0,            /* preferred_size   */
    0,                    /* resize   */
    0,      /* nearest_smaller_value */
    0,                       /* next accessor    */
    0,                    /* compare vs. another accessor   */
    &unpack_double_element,     /* unpack only ith value          */
    0,     /* unpack a subarray         */
    0,             		/* clear          */
};


grib_accessor_class* grib_accessor_class_data_apply_bitmap = &_grib_accessor_class_data_apply_bitmap;


static void init_class(grib_accessor_class* c)
{
	c->next_offset	=	(*(c->super))->next_offset;
	c->string_length	=	(*(c->super))->string_length;
	c->byte_count	=	(*(c->super))->byte_count;
	c->byte_offset	=	(*(c->super))->byte_offset;
	c->sub_section	=	(*(c->super))->sub_section;
	c->pack_missing	=	(*(c->super))->pack_missing;
	c->is_missing	=	(*(c->super))->is_missing;
	c->pack_long	=	(*(c->super))->pack_long;
	c->unpack_long	=	(*(c->super))->unpack_long;
	c->pack_string	=	(*(c->super))->pack_string;
	c->unpack_string	=	(*(c->super))->unpack_string;
	c->pack_bytes	=	(*(c->super))->pack_bytes;
	c->unpack_bytes	=	(*(c->super))->unpack_bytes;
	c->pack_expression	=	(*(c->super))->pack_expression;
	c->notify_change	=	(*(c->super))->notify_change;
	c->update_size	=	(*(c->super))->update_size;
	c->preferred_size	=	(*(c->super))->preferred_size;
	c->resize	=	(*(c->super))->resize;
	c->nearest_smaller_value	=	(*(c->super))->nearest_smaller_value;
	c->next	=	(*(c->super))->next;
	c->compare	=	(*(c->super))->compare;
	c->unpack_double_subarray	=	(*(c->super))->unpack_double_subarray;
	c->clear	=	(*(c->super))->clear;
}

/* END_CLASS_IMP */

static void init(grib_accessor* a,const long v, grib_arguments* args)
{
    int n=0;
    grib_accessor_data_apply_bitmap *self =(grib_accessor_data_apply_bitmap*)a;

    self->coded_values  = grib_arguments_get_name(a->parent->h,args,n++);
    self->bitmap        = grib_arguments_get_name(a->parent->h,args,n++);
    self->missing_value = grib_arguments_get_name(a->parent->h,args,n++);
    self->binary_scale_factor = grib_arguments_get_name(a->parent->h,args,n++);
    self->number_of_data_points = grib_arguments_get_name(a->parent->h,args,n++);
    self->number_of_values = grib_arguments_get_name(a->parent->h,args,n++);

    a->length = 0;
}
static void dump(grib_accessor* a, grib_dumper* dumper)
{
    grib_dump_values(dumper,a);
}

static long value_count(grib_accessor* a)
{
    grib_accessor_data_apply_bitmap *self =(grib_accessor_data_apply_bitmap*)a;
    size_t len = 0;
    int ret = 0;

    if(grib_find_accessor(a->parent->h,self->bitmap))
        ret =  grib_get_size(a->parent->h,self->bitmap,&len);
    else
        ret =  grib_get_size(a->parent->h,self->coded_values,&len);

    if(ret == GRIB_SUCCESS)
        return len;
    grib_context_log(a->parent->h->context, GRIB_LOG_DEBUG,
            "grib_accessor_data_simple_packing_bitmap : value_count : cannot get number of values %s",
            a->name);
    return 0;
}

static int  unpack_double(grib_accessor* a, double* val, size_t *len)
{
    grib_accessor_data_apply_bitmap* self =  (grib_accessor_data_apply_bitmap*)a;

    size_t i = 0;
    size_t j = 0;
    size_t n_vals = grib_value_count(a);
    size_t coded_n_vals = 0;

    int err = 0;
    double* coded_vals = NULL;

    double missing_value = 0;

    if(!grib_find_accessor(a->parent->h,self->bitmap))
        return grib_get_double_array_internal(a->parent->h,self->coded_values,val,len);

    if((err = grib_get_size(a->parent->h,self->coded_values,&coded_n_vals)) != GRIB_SUCCESS)
        return err;

    if((err = grib_get_double_internal(a->parent->h,self->missing_value,&missing_value))
            != GRIB_SUCCESS)  return err;

    if(*len < n_vals) {
        *len = n_vals;
        return GRIB_ARRAY_TOO_SMALL;
    }

    if (coded_n_vals==0) {
        for(i=0;i < n_vals;i++)
            val[i] = missing_value;

        *len=n_vals;
        return GRIB_SUCCESS;
    }

    if((err = grib_get_double_array_internal(a->parent->h,self->bitmap,val,&n_vals))
            != GRIB_SUCCESS)
        return err;

    coded_vals = grib_context_malloc(a->parent->h->context,coded_n_vals*sizeof(double));
    if(coded_vals == NULL) return GRIB_OUT_OF_MEMORY;

    if((err = grib_get_double_array_internal(a->parent->h,self->coded_values,coded_vals,&coded_n_vals))
            != GRIB_SUCCESS)
    {
        grib_context_free(a->parent->h->context,coded_vals);
        return err;
    }

    grib_context_log(a->parent->h->context, GRIB_LOG_DEBUG,
            "grib_accessor_class_data_apply_bitmap: unpack_double : creating %s, %d values",
            a->name, n_vals);

    for(i=0;i < n_vals;i++)
    {
        if(val[i] == 0 ){
            val[i] = missing_value;
        }
        else
        {
            val[i] = coded_vals[j++];
            if(j>coded_n_vals)
            {
                grib_context_free(a->parent->h->context,coded_vals);
                grib_context_log(a->parent->h->context, GRIB_LOG_ERROR,
                        "grib_accessor_class_data_apply_bitmap [%s]:"
                        " unpack_double :  number of coded values does not match bitmap %ld %ld",
                        a->name,coded_n_vals,n_vals);

                return GRIB_ARRAY_TOO_SMALL;
            }
        }
    }

    *len =  n_vals;

    grib_context_free(a->parent->h->context,coded_vals);
    return err;
}

static int  unpack_double_element(grib_accessor* a, size_t idx,double* val)
{
    grib_accessor_data_apply_bitmap* self =  (grib_accessor_data_apply_bitmap*)a;
    int err = 0,i=0;
    size_t cidx=0;
    double missing_value = 0;
    double* bvals=NULL;
    size_t n_vals = grib_value_count(a);

    if(!grib_find_accessor(a->parent->h,self->bitmap))
        return grib_get_double_element_internal(a->parent->h,self->coded_values,idx,val);

    if((err = grib_get_double_internal(a->parent->h,self->missing_value,&missing_value)) != GRIB_SUCCESS)
        return err;

    if((err = grib_get_double_element_internal(a->parent->h,self->bitmap,idx,val)) != GRIB_SUCCESS)
        return err;

    if (*val == 0) {*val=missing_value;return GRIB_SUCCESS;}

    bvals = grib_context_malloc(a->parent->h->context,n_vals*sizeof(double));
    if(bvals == NULL) return GRIB_OUT_OF_MEMORY;

    if((err = grib_get_double_array_internal(a->parent->h,self->bitmap,bvals,&n_vals)) != GRIB_SUCCESS)
        return err;

    cidx=0;
    for (i=0;i<idx;i++) {cidx+=bvals[i];}

    grib_context_free(a->parent->h->context,bvals);

    return grib_get_double_element_internal(a->parent->h,self->coded_values,cidx,val);
}

static int pack_double(grib_accessor* a, const double* val, size_t *len)
{
    grib_accessor_data_apply_bitmap* self =  (grib_accessor_data_apply_bitmap*)a;
    int err = 0;
    size_t bmaplen = *len;
    long coded_n_vals = 0;
    double* coded_vals = NULL;
    long i = 0;
    long j = 0;
    double missing_value = 0;

    if (*len ==0) return GRIB_NO_VALUES;

    if(!grib_find_accessor(a->parent->h,self->bitmap)){
        err = grib_set_double_array_internal(a->parent->h,self->coded_values,val,*len);
        /*printf("SETTING TOTAL number_of_data_points %s %ld\n",self->number_of_data_points,*len);*/
        if(self->number_of_data_points)
            grib_set_long_internal(a->parent->h,self->number_of_data_points,*len);
        return err;
    }

    if((err = grib_get_double_internal(a->parent->h,self->missing_value,&missing_value)) != GRIB_SUCCESS)
        return err;

    if((err = grib_set_double_array_internal(a->parent->h,self->bitmap,val,bmaplen)) != GRIB_SUCCESS)
        return err;

    coded_n_vals = *len;

    if(coded_n_vals <  1){
        err = grib_set_double_array_internal(a->parent->h,self->coded_values,NULL,0);
        return err;
    }

    coded_vals = grib_context_malloc_clear(a->parent->h->context,coded_n_vals*sizeof(double));
    if(!coded_vals) return GRIB_OUT_OF_MEMORY;

    for(i=0; i<*len ; i++)
    {
        if(val[i] != missing_value) {
            coded_vals[j++] = val[i];
        }
    }

    err = grib_set_double_array_internal(a->parent->h,self->coded_values,coded_vals,j);
    if (j==0) {
        if (self->number_of_values)
            err=grib_set_long_internal(a->parent->h,self->number_of_values,0);
        if (self->binary_scale_factor)
            err=grib_set_long_internal(a->parent->h,self->binary_scale_factor,0);
    }

    grib_context_free(a->parent->h->context,coded_vals);

    return err;
}

static int  get_native_type(grib_accessor* a)
{
    /*  grib_accessor_data_apply_bitmap* self =  (grib_accessor_data_apply_bitmap*)a;
    return grib_accessor_get_native_type(grib_find_accessor(a->parent->h,self->coded_values));*/

    return GRIB_TYPE_DOUBLE;
}
