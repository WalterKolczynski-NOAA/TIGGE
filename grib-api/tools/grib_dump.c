/*
 * Copyright 2005-2014 ECMWF.
 *
 * This software is licensed under the terms of the Apache Licence Version 2.0
 * which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
 *
 * In applying this licence, ECMWF does not waive the privileges and immunities granted to it by
 * virtue of its status as an intergovernmental organisation nor does it submit to any jurisdiction.
 */

/*
 * C Implementation: grib_dump
 *
 */

#include "grib_tools.h"

grib_option grib_options[]={
/*  {id, args, help}, on, command_line, value*/
    {"S",0,0,1,0,0},
    {"O",0,"Octet mode. WMO documentation style dump.\n",0,1,0},
    {"D",0,0,0,1,0},
    {"d",0,"Print all data values.\n",0,1,0},
    {"j",0,0,0,1,0},
    {"C",0,0,0,1,0},
    {"t",0,0,0,1,0},
    {"H",0,0,0,1,0},
    {"a",0,0,0,1,0},
    {"w:",0,0,0,1,0},
    {"s:",0,0,0,1,0},
    {"M",0,0,0,1,0},
    {"T:",0,0,0,1,0},
    {"7",0,0,0,1,0},
    {"V",0,0,0,1,0},
    {"q",0,0,1,0,0},
    {"X:",0,0,0,1,0}
};

char* grib_tool_description="Dump the content of a grib file in different formats.";
char* grib_tool_name="grib_dump";
char* grib_tool_usage="[options] grib_file grib_file ...";
static int json=0;

int grib_options_count=sizeof(grib_options)/sizeof(grib_option);

/**
 *grib_dump
 *Dump the content of a grib file
 *
 */
int main(int argc, char *argv[])
{
    return grib_tool(argc,argv);
}

int grib_tool_before_getopt(grib_runtime_options* options)
{
    return 0;
}

int grib_tool_init(grib_runtime_options* options)
{

    int opt=grib_options_on("C")+grib_options_on("O")+grib_options_on("D")+grib_options_on("j");

    options->dump_mode = "default";

    if (opt > 1) {
        printf("%s: simultaneous j/C/O/D options not allowed\n",grib_tool_name);
        exit(1);
    }

    if (grib_options_on("j")) {
        options->dump_mode = "json";
        json=1;
    }

    if (grib_options_on("C")) {
        options->dump_mode = "c_code";
        if (grib_options_on("d"))
            options->dump_flags = 0;
        else
            options->dump_flags = GRIB_DUMP_FLAG_NO_DATA;
    }

    if  (grib_options_on("O")) {
        options->dump_mode = "wmo";
        options->dump_flags = GRIB_DUMP_FLAG_CODED
                | GRIB_DUMP_FLAG_OCTECT
                | GRIB_DUMP_FLAG_VALUES
                | GRIB_DUMP_FLAG_READ_ONLY;
    }

    if (grib_options_on("D")) {
        options->dump_mode = "debug";
        options->dump_flags = GRIB_DUMP_FLAG_VALUES
                |  GRIB_DUMP_FLAG_READ_ONLY;
    }

    if (grib_options_on("a"))
        options->dump_flags |= GRIB_DUMP_FLAG_ALIASES;

    if (grib_options_on("t"))
        options->dump_flags |= GRIB_DUMP_FLAG_TYPE;

    if (grib_options_on("H"))
        options->dump_flags |= GRIB_DUMP_FLAG_HEXADECIMAL;

    /* In JSON mode we want to print all data values */
    if ( grib_options_on("d") || grib_options_on("j") )
        options->dump_flags |= GRIB_DUMP_FLAG_ALL_DATA;

    return 0;
}

int grib_tool_new_filename_action(grib_runtime_options* options,const char* file)
{
    return 0;
}

int grib_tool_new_file_action(grib_runtime_options* options,grib_tools_file* file)
{
    char tmp[1024];
    if (!options->current_infile->name) return 0;
    if (json) return 0;
    sprintf(tmp,"FILE: %s ",options->current_infile->name);
    if (!grib_options_on("C"))
        fprintf(stdout,"***** %s\n",tmp);

    /*
     * In debug dump mode, allow dumping of GRIB index files
     */
    if (strcmp(options->dump_mode, "debug")==0)
    {
        if (is_index_file(options->current_infile->name))
        {
            int err = 0;
            grib_context* c = grib_context_get_default();
            const char* filename = options->current_infile->name;
            
            err = grib_index_dump_file(stdout, filename);
            if (err) {
                grib_context_log(c, GRIB_LOG_ERROR, "%s: Could not dump index file \"%s\".\n%s\n",
                        grib_tool_name,
                        filename,
                        grib_get_error_message(err));
                exit(1);
            }
            /* Since there are no GRIB messages, we have to stop tool exiting in case there
             * are more index files
            */
            options->fail = 0;
        }
    }
    return 0;
}

int grib_tool_new_handle_action(grib_runtime_options* options, grib_handle* h)
{
    long length=0;
    char tmp[1024];
    char identifier[100];
    size_t idlen=100;
    int i,err=0;
    GRIB_CHECK_NOLINE(grib_get_long(h,"totalLength",&length),0);

    if (!options->skip) {
        if (options->set_values_count != 0)
            err=grib_set_values(h,options->set_values,options->set_values_count);
        if( err != GRIB_SUCCESS && options->fail) exit(err);
    }

    for (i=0;i<options->print_keys_count;i++)
        grib_set_flag(h,options->print_keys[i].name,GRIB_ACCESSOR_FLAG_DUMP);

    if(json) {
    }
    else {
        sprintf(tmp,"MESSAGE %d ( length=%ld )",options->handle_count,length);
        if (!grib_options_on("C"))
            fprintf(stdout,"#==============   %-38s   ==============\n",tmp);
        if (!strcmp(options->dump_mode,"default")) {
            GRIB_CHECK_NOLINE(grib_get_string(h,"identifier",identifier,&idlen),0);
            printf("%s {\n",identifier);
        }
    }

    grib_dump_content(h,stdout,options->dump_mode,options->dump_flags,0);

    if (!strcmp(options->dump_mode,"default"))
        printf("}\n");
    return 0;
}

int grib_tool_skip_handle(grib_runtime_options* options, grib_handle* h)
{
    grib_handle_delete(h);
    return 0;
}

void grib_tool_print_key_values(grib_runtime_options* options,grib_handle* h)
{
    grib_print_key_values(options,h);
}

int grib_tool_finalise_action(grib_runtime_options* options)
{
    return 0;
}
