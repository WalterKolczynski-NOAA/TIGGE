/*
 * Copyright 2005-2014 ECMWF.
 *
 * This software is licensed under the terms of the Apache Licence Version 2.0
 * which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
 *
 * In applying this licence, ECMWF does not waive the privileges and immunities granted to it by
 * virtue of its status as an intergovernmental organisation nor does it submit to any jurisdiction.
 */

/*************************************
 *  Enrico Fucile
 ***********************************/

#include "grib_api_internal.h"
/* 
   This is used by make_class.pl

   START_CLASS_DEF
   CLASS      = accessor
   SUPER      = grib_accessor_class_double
   IMPLEMENTS = unpack_double;pack_double
   IMPLEMENTS = init
   MEMBERS=const char*                  directionIncrementGiven
   MEMBERS=const char*                  directionIncrement
   MEMBERS=const char*                  first
   MEMBERS=const char*                  last
   MEMBERS=const char*                  numberOfPoints
   END_CLASS_DEF

 */

/* START_CLASS_IMP */

/*

Don't edit anything between START_CLASS_IMP and END_CLASS_IMP
Instead edit values between START_CLASS_DEF and END_CLASS_DEF
or edit "accessor.class" and rerun ./make_class.pl

*/

static int pack_double(grib_accessor*, const double* val,size_t *len);
static int unpack_double(grib_accessor*, double* val,size_t *len);
static void init(grib_accessor*,const long, grib_arguments* );
static void init_class(grib_accessor_class*);

typedef struct grib_accessor_g1_increment {
    grib_accessor          att;
/* Members defined in gen */
/* Members defined in double */
/* Members defined in g1_increment */
	const char*                  directionIncrementGiven;
	const char*                  directionIncrement;
	const char*                  first;
	const char*                  last;
	const char*                  numberOfPoints;
} grib_accessor_g1_increment;

extern grib_accessor_class* grib_accessor_class_double;

static grib_accessor_class _grib_accessor_class_g1_increment = {
    &grib_accessor_class_double,                      /* super                     */
    "g1_increment",                      /* name                      */
    sizeof(grib_accessor_g1_increment),  /* size                      */
    0,                           /* inited */
    &init_class,                 /* init_class */
    &init,                       /* init                      */
    0,                  /* post_init                      */
    0,                    /* free mem                       */
    0,                       /* describes himself         */
    0,                /* get length of section     */
    0,              /* get length of string      */
    0,                /* get number of values      */
    0,                 /* get number of bytes      */
    0,                /* get offset to bytes           */
    0,            /* get native type               */
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
    0,     /* unpack only ith value          */
    0,     /* unpack a subarray         */
    0,             		/* clear          */
};


grib_accessor_class* grib_accessor_class_g1_increment = &_grib_accessor_class_g1_increment;


static void init_class(grib_accessor_class* c)
{
	c->dump	=	(*(c->super))->dump;
	c->next_offset	=	(*(c->super))->next_offset;
	c->string_length	=	(*(c->super))->string_length;
	c->value_count	=	(*(c->super))->value_count;
	c->byte_count	=	(*(c->super))->byte_count;
	c->byte_offset	=	(*(c->super))->byte_offset;
	c->get_native_type	=	(*(c->super))->get_native_type;
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
	c->unpack_double_element	=	(*(c->super))->unpack_double_element;
	c->unpack_double_subarray	=	(*(c->super))->unpack_double_subarray;
	c->clear	=	(*(c->super))->clear;
}

/* END_CLASS_IMP */

static void init(grib_accessor* a,const long l, grib_arguments* c)
{
	grib_accessor_g1_increment* self = (grib_accessor_g1_increment*)a; 
	int n = 0;
	
	self->directionIncrementGiven = grib_arguments_get_name(a->parent->h,c,n++);
	self->directionIncrement    = grib_arguments_get_name(a->parent->h,c,n++);
	self->first = grib_arguments_get_name(a->parent->h,c,n++);
	self->last    = grib_arguments_get_name(a->parent->h,c,n++);
	self->numberOfPoints    = grib_arguments_get_name(a->parent->h,c,n++);
}

static int    unpack_double   (grib_accessor* a, double* val, size_t *len)
{
	grib_accessor_g1_increment* self = (grib_accessor_g1_increment*)a;
	int ret = 0;

	long directionIncrementGiven=0;
	long directionIncrement;
	double first = 0;
	double last = 0;
	long numberOfPoints = 0;

	if(*len < 1)
		ret = GRIB_ARRAY_TOO_SMALL;

	if((ret = grib_get_long_internal(a->parent->h, self->directionIncrementGiven,&directionIncrementGiven)) 
					!= GRIB_SUCCESS)
		return ret;
	
	if((ret = grib_get_long_internal(a->parent->h, self->directionIncrement,&directionIncrement)) 
				!= GRIB_SUCCESS)
		return ret;
	
	if((ret = grib_get_double_internal(a->parent->h, self->first,&first)) != GRIB_SUCCESS)
		return ret;
	
	if((ret = grib_get_double_internal(a->parent->h, self->last,&last)) != GRIB_SUCCESS)
		return ret;

	if((ret = grib_get_long_internal(a->parent->h, self->numberOfPoints,&numberOfPoints))
       != GRIB_SUCCESS)
		return ret;
	
	if (!directionIncrementGiven || directionIncrement == GRIB_MISSING_LONG) {
		*val = fabs(last-first)/(double)(numberOfPoints-1);
	} else {
		*val = (double)directionIncrement/1000.0;
	} 
	
#if 0
	printf("unpack -- %s=%ld %s=%ld %s=%f %s=%f %s=%ld %s=%f\n",
						self->directionIncrementGiven,directionIncrementGiven,
						self->directionIncrement,directionIncrement,
						self->last,last,
						self->first,first,
						self->numberOfPoints,numberOfPoints,
						a->name,*val);
#endif
	if (ret == GRIB_SUCCESS) *len = 1;
		
	return ret;
} 


static int pack_double(grib_accessor* a, const double* val, size_t *len)
{
	grib_accessor_g1_increment* self = (grib_accessor_g1_increment*)a;
	int ret = 0;
		long codedNumberOfPoints=0;
	
	long directionIncrementGiven=0;
	long directionIncrement;
	double first = 0;
	double last = 0;
	long numberOfPoints = 0;
	double incrementInMillidegrees;
	
	ret = grib_get_double_internal(a->parent->h, self->first,&first);
	if(ret != GRIB_SUCCESS) {
		grib_context_log(a->parent->h->context, GRIB_LOG_ERROR, "Accessor %s cannont gather value for %s error %d \n", a->name, self->first, ret);   
		return ret;
	}	
	ret = grib_get_double_internal(a->parent->h, self->last,&last);
	if(ret != GRIB_SUCCESS){
		grib_context_log(a->parent->h->context, GRIB_LOG_ERROR, "Accessor %s cannont gather value for %s error %d \n", a->name, self->last, ret);   
		return ret;
	}

	if((ret = grib_get_long_internal(a->parent->h, self->directionIncrementGiven,&directionIncrementGiven)) 
					!= GRIB_SUCCESS){
		grib_context_log(a->parent->h->context, GRIB_LOG_ERROR, "Accessor %s cannont gather value for %s error %d \n", a->name, self->directionIncrementGiven, ret);   
		return ret;
	}	
	
	numberOfPoints = 1+rint(fabs((last-first) / *val));
	
	incrementInMillidegrees = *val * 1000;
	if ((int)incrementInMillidegrees ==  incrementInMillidegrees ) {
		directionIncrement=(int)incrementInMillidegrees;
	} else {
		directionIncrement=0xffffff;
		directionIncrementGiven=0;
	} 

	ret = grib_set_long_internal(a->parent->h, self->numberOfPoints,numberOfPoints);
	if(ret )
		grib_context_log(a->parent->h->context, GRIB_LOG_ERROR, "Accessor %s cannont pack value for %s error %d \n", a->name, self->numberOfPoints, ret);
	

	grib_get_long_internal(a->parent->h, self->numberOfPoints,&codedNumberOfPoints);
	
	
		ret = grib_set_long_internal(a->parent->h, self->directionIncrement,directionIncrement);
	if(ret )
		grib_context_log(a->parent->h->context, GRIB_LOG_ERROR, "Accessor %s cannont pack value for %s error %d \n", a->name, self->directionIncrement, ret);
	
		ret = grib_set_long_internal(a->parent->h, self->directionIncrementGiven,directionIncrementGiven);
	if(ret )
		grib_context_log(a->parent->h->context, GRIB_LOG_ERROR, "Accessor %s cannont pack value for %s error %d \n", a->name, self->directionIncrementGiven, ret);

#if 0
	printf("pack -- %s=%ld %s=%ld %s=%f %s=%f %s=%ld codedNumberOfPoints=%ld %s=%f\n",
						self->directionIncrementGiven,directionIncrementGiven,
						self->directionIncrement,directionIncrement,
						self->last,last,
						self->first,first,
						self->numberOfPoints,numberOfPoints,
						codedNumberOfPoints,
						a->name,*val);
#endif


	if (ret == GRIB_SUCCESS) *len = 1;

	return ret;
}

