/*
 * Copyright 2005-2014 ECMWF.
 *
 * This software is licensed under the terms of the Apache Licence Version 2.0
 * which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
 *
 * In applying this licence, ECMWF does not waive the privileges and immunities granted to it by
 * virtue of its status as an intergovernmental organisation nor does it submit to any jurisdiction.
 */

/***************************************************************************
 *   Jean Baptiste Filippi - 01.11.2005                                                           *
 *   Enrico Fucile
 *                                                                         *
 ***************************************************************************/

#include "grib_api_internal.h"

#define NUMBER(x) (sizeof(x)/sizeof(x[0]))

/* This file is generated my ./make_class.pl */
#include "grib_iterator_class.h"

struct table_entry
{
  char                  *type;
  grib_iterator_class   **cclass;
};

static struct table_entry table[] =
{
  /* This file is generated my ./make_class.pl */
#include "grib_iterator_factory.h"
};

grib_iterator* grib_iterator_factory( grib_handle* h, grib_arguments* args, unsigned long flags,int *ret)
{
  int i;
  char* type = (char*)grib_arguments_get_name(h,args,0);

  for(i = 0; i < NUMBER(table) ; i++)
    if(strcmp(type,table[i].type) == 0)
    {
      grib_iterator_class* c = *(table[i].cclass);
      grib_iterator*       it = (grib_iterator*) grib_context_malloc_clear(h->context,c->size);
      it->cclass              = c;
	  it->flags    = flags;
      *ret = GRIB_SUCCESS;
      *ret = grib_iterator_init(it,h,args);
      if(*ret ==  GRIB_SUCCESS) return it;
      grib_context_log(h->context,GRIB_LOG_DEBUG,"grib_iterator_factory: error %d instantiating iterator %s", *ret, table[i].type);
      grib_iterator_delete(it);
      return NULL;
    }

  grib_context_log(h->context,GRIB_LOG_ERROR,"grib_iterator_factory : Unknown type : %s for iterator", type);

  return NULL;
}
