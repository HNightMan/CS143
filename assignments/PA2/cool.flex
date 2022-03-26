%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

#define yylval cool_yylval
#define yylex  cool_yylex

#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

%}
%option stack
%option noyywrap

DIGIT			[0-9]

%x				COMMENTS
%x				STRING
%%

	BEGIN(INITIAL);

[ \t\f\r\v]+

<INITIAL,COMMENTS>\n	curr_lineno++;

--.*$ 

<INITIAL,COMMENTS>"(*"	yy_push_state(COMMENTS);

<COMMENTS>{

"*)"	yy_pop_state();

.

<<EOF>> {
    yylval.error_msg = (char*)"EOF in comment";
    return ERROR;
}

}

"*)" {
    yylval.error_msg = (char*)"Unmatched *)";
    return ERROR;
}

\" {
    yy_push_state(STRING);
    yymore();
}

<STRING>{

[^\"\n]*  yymore();

\n	{
    yylval.error_msg = (char*)"NEWLINE in STR_CONST";
    return ERROR;
}

<<EOF>>	{
    yylval.error_msg = (char*)"EOF in STR_CONST";
    return ERROR;
}

\"	{
	std::string input(yytext, yyleng);
	std::string::size_type pos;
	input=input.substr(1,input.length()-2);
	std::string output = "";
	if (input.find_first_of('\0') != std::string::npos) {
		yylval.error_msg = (char*)"String contains null character";
		return ERROR;    
	}
	while ((pos = input.find_first_of("\\")) != std::string::npos) {
		output += input.substr(0, pos);
		switch (input[pos + 1]) {
		case 'b':
			output += "\b";
			break;
		case 't':
			output += "\t";
			break;
		case 'n':
			output += "\n";
			break;
		case 'f':
			output += "\f";
			break;
		default:
			output += input[pos + 1];
			break;
		}
		input = input.substr(pos + 2, input.length() - 2);
	}
	output += input;
	yylval.symbol = stringtable.add_string((char*)output.c_str());
	return STR_CONST;
}
}

(?i:class)		return CLASS;

(?i:else)		return ELSE;

(?i:fi)			return FI;

(?i:if)			return IF;

(?i:in)			return IN;

(?i:inherits)	return INHERITS;

(?i:let)		return LET;

(?i:loop)		return LOOP;

(?i:pool)		return POOL;

(?i:then)		return THEN;

(?i:while)		return WHILE;

(?i:case)		return CASE;

(?i:esac)		return ESAC;

(?i:of)			return OF;

(?i:new)		return NEW;

(?i:isvoid)		return ISVOID;

(?i:not)		return NOT;

(?i:le)			return LE;

{DIGIT}+ {
    cool_yylval.symbol = inttable.add_string(yytext);
    return INT_CONST;
}

t(?i:rue) {
    cool_yylval.boolean = 1;
    return BOOL_CONST;
}

f(?i:alse) {
    cool_yylval.boolean = 0;
    return BOOL_CONST;
}

[A-Z][A-Za-z0-9_]* {
    cool_yylval.symbol = idtable.add_string(yytext);
    return TYPEID;
}

[a-z][A-Za-z0-9_]* {
    cool_yylval.symbol = idtable.add_string(yytext);
    return OBJECTID;
}

"<-" { return ASSIGN; }

"<=" { return LE; }

"=>" { return DARROW; }

"+" { return int('+'); }

"-" { return int('-'); }

"*" { return int('*'); }

"/" { return int('/'); }

"<" { return int('<'); }

"=" { return int('='); }

"." { return int('.'); }

";" { return int(';'); }

"~" { return int('~'); }

"{" { return int('{'); }

"}" { return int('}'); }

"(" { return int('('); }

")" { return int(')'); }

":" { return int(':'); }

"@" { return int('@'); }

"," { return int(','); }

[^\n] {
    yylval.error_msg = yytext;
    return ERROR;
}

%%
