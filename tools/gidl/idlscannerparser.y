%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <glib.h>
#include <glib/gstdio.h>
#include "gidl-source-scanner.h"
#include "idlscannerparser.h"

extern FILE *yyin;
extern int lineno;
extern char linebuf[2000];
extern char *yytext;

extern int yylex (GidlSourceScanner *scanner);
static void yyerror (GidlSourceScanner *scanner, const char *str);

extern void ctype_free (GISourceType * type);

static int last_enum_value = -1;
static gboolean is_bitfield;
static GHashTable *const_table = NULL;
%}

%error-verbose

%parse-param { GidlSourceScanner* scanner }
%lex-param { GidlSourceScanner* scanner }

%token <str> IDENTIFIER "identifier"
%token <str> TYPEDEF_NAME "typedef-name"

%token INTEGER FLOATING CHARACTER STRING BOOLEAN
%token MODULE INTERFACE PROPERTY SIGNAL DIRECTION VISIBILITY
%token ANNOTATION
