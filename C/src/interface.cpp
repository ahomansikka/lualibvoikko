/*
Copyright (©) 2020 Hannu Väisänen

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <lua5.3/lua.hpp>
#include <stdio.h>
#include <string.h>
#include <string>
#include <libvoikko/voikko.h>

namespace {

/* Fix spelling mistakes that are in Libvoikko code.
*/
std::string fix_value (const char *key, const char *value)
{
  if (strcmp (key, "SIJAMUOTO") == 0) {
         if (strcmp (value, "nimento")     == 0) {return "nimentö";}
    else if (strcmp (value, "omanto")      == 0) {return "omanto";}
    else if (strcmp (value, "osanto")      == 0) {return "osanto";}
    else if (strcmp (value, "olento")      == 0) {return "olento";}
    else if (strcmp (value, "tulento")     == 0) {return "tulento";}
    else if (strcmp (value, "kohdanto")    == 0) {return "kohdanto";}
    else if (strcmp (value, "sisaolento")  == 0) {return "sisäolento";}
    else if (strcmp (value, "sisaeronto")  == 0) {return "sisäeronto";}
    else if (strcmp (value, "sisatulento") == 0) {return "sisätulento";}
    else if (strcmp (value, "ulkoolento")  == 0) {return "ulko_olento";}
    else if (strcmp (value, "ulkoeronto")  == 0) {return "ulkoeronto";}
    else if (strcmp (value, "ulkotulento") == 0) {return "ulkotulento";}
    else if (strcmp (value, "vajanto")     == 0) {return "vajanto";}
    else if (strcmp (value, "seuranto")    == 0) {return "seuranto";}
    else if (strcmp (value, "keinonto")    == 0) {return "keinonto";}
    else if (strcmp (value, "kerrontosti") == 0) {return "kerronto_sti";}
  }
  return value;
}


const char *HANDLE = "HANDLE";


/** Gets Voikko handle from stack.
*/
inline VoikkoHandle *get_handle (lua_State *L)
{
  lua_pushlightuserdata (L, &HANDLE);
  lua_gettable (L, LUA_REGISTRYINDEX);
  return (VoikkoHandle *)lua_touserdata (L, -1);
}


void make_table (lua_State *L, char **list)
{
  lua_newtable (L);
  int i = 1;
  for (char **s = list; *s; s++) {
    lua_pushstring (L, *s);
    lua_rawseti (L, -2, i++);
  }
}


template <typename Function>
int get_list (lua_State *L, Function f)
{
  const char *path = luaL_checkstring (L, 1);
  char **list = f (path);
  if (list != NULL) {
    make_table (L, list);
    voikkoFreeCstrArray (list);
    return 1;
  }
  return 0;
}


template <typename Function>
int get_list2 (lua_State *L, Function f)
{
  const char *string = luaL_checkstring (L, 1);
  VoikkoHandle *handle = get_handle (L);
  char **list = f (handle, string);
  if (list != NULL) {
    make_table (L, list);
    voikkoFreeCstrArray (list);
    return 1;
  }
  return 0;
}


/** Initialises libvoikko.

Calls VoikkoHandle *handle = voikkoInit (&error, langcode, path);

error is defined in this function
langcode == stack(1) (string)
path == stack(2) (string)

If (error != NULL) calls

luaL_error (L, error);

and stops, otherwise puts the handle to stack as lightuserdata that
other functions in this package use automagically.
*/
int lualibvoikko_init (lua_State *L)
{
  const char *error = NULL;
  const char *langcode = luaL_checkstring (L, 1);
  const char *path     = luaL_checkstring (L, 2);
  VoikkoHandle *handle = voikkoInit (&error, langcode, path);
  if (error != NULL) {
    luaL_error (L, error);
    // voikkoFreeErrorMessageCstr (error); does not work here,
    // because luaL_error() aborts the program.
  }
  else {
    lua_pushlightuserdata (L, &HANDLE);
    lua_pushlightuserdata (L, handle);
    lua_settable (L, LUA_REGISTRYINDEX);
    return 0;
  }
}


/* Terminates libvoikko.

Calls voikkoTerminate (handle);
*/
int lualibvoikko_terminate (lua_State *L)
{
  VoikkoHandle *handle = get_handle (L);
  voikkoTerminate (handle);
  return 0;
}


/** Calls voikkoSetBooleanOption (handle, option, value);
    and returns the result in the stack.

option == stack(1) (integer)
value == stack(2) (integer)
*/
int lualibvoikko_set_boolean_option (lua_State *L)
{
  int option = lua_tointeger (L, 1);
  int value  = lua_tointeger (L, 2);
  VoikkoHandle *handle = get_handle (L);
  const int n = voikkoSetBooleanOption (handle, option, value);
  lua_pushinteger (L, n);
  return 1;
}


/** Calls voikkoSetIntegerOption (handle, option, value);
    and returns the result in the stack.

option == stack(1) (integer)
value == stack(2) (integer)
*/
int lualibvoikko_set_integer_option (lua_State *L)
{
  int option = lua_tointeger (L, 1);
  int value  = lua_tointeger (L, 2);
  VoikkoHandle *handle = get_handle (L);
  const int n = voikkoSetIntegerOption (handle, option, value);
  lua_pushinteger (L, n);
  return 1;
}


/** Calls voikkoSpellCstr (handle, word);
    and returns the result in the stack.

word == stack(1) (string)
*/
int lualibvoikko_spell_cstr (lua_State *L)
{
  const char *word = luaL_checkstring (L, 1);
  VoikkoHandle *handle = get_handle (L);
  const int n = voikkoSpellCstr (handle, word);
  lua_pushinteger (L, n);
  return 1;
}


/** Calls voikkoSuggestCstr (handle, word);

word == stack(1) (string)

Returns the suggestions in a stack as a Lua table.
*/
int lualibvoikko_suggest_cstr (lua_State *L)
{
  return get_list2 (L, &voikkoSuggestCstr);
}


/** Calls voikkoHyphenateCstr (handle, word);
    and returns the result (string) in stack.

word == stack(1) (string)
*/
int lualibvoikko_hyphenate_cstr (lua_State *L)
{
  const char *word = luaL_checkstring (L, 1);
  VoikkoHandle *handle = get_handle (L);

  char *s = voikkoHyphenateCstr (handle, word);
  if (s != NULL) {
    lua_pushstring (L, s);
    voikkoFreeCstr (s);
    return 1;
  }
  return 0;
}


/** Calls voikkoInsertHyphensCstr (handle, word, hyphen, allowContextChanges);
    and returns the result (string) in stack.

word == stack(1) (string)
hyphen == stack(2) (string)
allowContextChanges == stack(3) (int (boolean))
*/
int lualibvoikko_insert_hyphens_cstr (lua_State *L)
{
  const char *word   = luaL_checkstring (L, 1);
  const char *hyphen = luaL_checkstring (L, 2);
  int allowContextChanges = lua_tointeger (L, 3);
  VoikkoHandle *handle = get_handle (L);
  char *s = voikkoInsertHyphensCstr (handle, word, hyphen, allowContextChanges);
  lua_pushstring (L, s);
  voikkoFreeCstr (s);
  return 1;
}


/** Calls voikkoAnalyzeWordCstr (handle, word);

word == stack(1) (string)

Returns the result(s) of analysis as nested Lua table(s).
*/
int lualibvoikko_analyze_word_cstr (lua_State *L)
{
  const char *word = luaL_checkstring (L, 1);
  VoikkoHandle *handle = get_handle (L);
//  printf ("Sana: %s\n", word);
  voikko_mor_analysis **analysis = voikkoAnalyzeWordCstr (handle, word);

  if (analysis != NULL) {
    lua_newtable (L);
    int i = 1;
    const size_t N = 100;
    char buffer[N];
    for (voikko_mor_analysis **a = analysis; *a; a++) {
      const char **keys = voikko_mor_analysis_keys (*a);
      if (snprintf (buffer, N, "table%d", i++) >= N) {
        luaL_error (L, "Function lualibvoikko_analyze_word_cstr: value of N is too small.");
      }
      lua_pushstring (L, buffer);
      lua_newtable (L);
//      printf ("TABLE %s %d\n", buffer, lua_gettop(L));
      for (const char **k = keys; *k; k++) {
        char *value = voikko_mor_analysis_value_cstr (*a, *k);
        const std::string new_value = fix_value (*k, value);
        const char *new_char_value = new_value.c_str();
//        printf ("Key %s  value %s %s\n", *k, value, new_char_value);
        lua_pushstring (L, new_char_value);
        lua_setfield (L, -2, *k);
        voikko_free_mor_analysis_value_cstr (value);
      }
      lua_settable (L, -3);
//      printf ("=================== %d\n", lua_gettop(L));
    }

    voikko_free_mor_analysis (analysis);
    return 1;
  }
  voikko_free_mor_analysis (analysis);
  return 0;
}


/**
 * Calls list = voikkoListSupportedSpellingLanguages (path)
 * path = stack(1)
 * Return sa table of language codes.
 */
int lualibvoikko_list_supported_spelling_languages (lua_State *L)
{
  return get_list (L, &voikkoListSupportedSpellingLanguages);
}


/**
 * Calls list = voikkoListSupportedHyphenationLanguages (path)
 * path = stack(1)
 * Return sa table of language codes.
 */
int lualibvoikko_list_supported_hyphenation_languages (lua_State *L)
{
  return get_list (L, &voikkoListSupportedHyphenationLanguages);
}


/**
 * Calls list = voikkoListSupportedGrammarCheckingLanguages (path)
 * path = stack(1)
 * Return sa table of language codes.
 */
int lualibvoikko_list_supported_grammar_checking_languages (lua_State *L)
{
  return get_list (L, &voikkoListSupportedGrammarCheckingLanguages);
}


/** Calls voikkoGetVersion();

and returns he result (string) in stack.
*/
int lualibvoikko_get_version (lua_State *L)
{
  const char *version = voikkoGetVersion();
  lua_pushstring (L, version);
  return 1;
}


/** Calls (voikkoGetAttributeValues (handle, attributeName)
and returns the values as a table.

attributeName == stack(1) (string)
*/
int lualibvoikko_get_attribute_values (lua_State *L)
{
  return get_list2 (L, &voikkoGetAttributeValues);
}


const struct luaL_Reg lualibvoikko[] = {
  {"voikko_init",               lualibvoikko_init},
  {"voikko_terminate",          lualibvoikko_terminate},
  {"voikko_set_boolean_option", lualibvoikko_set_boolean_option},
  {"voikko_set_integer_option", lualibvoikko_set_integer_option},
  {"voikko_spell",              lualibvoikko_spell_cstr},
  {"voikko_suggest",            lualibvoikko_suggest_cstr},
  {"voikko_hyphenate",          lualibvoikko_hyphenate_cstr},
  {"voikko_insert_hyphens",     lualibvoikko_insert_hyphens_cstr},
  {"voikko_analyse_word",       lualibvoikko_analyze_word_cstr},
  {"voikko_get_version",        lualibvoikko_get_version},
  {"voikko_list_supported_spelling_languages",    lualibvoikko_list_supported_spelling_languages},
  {"voikko_list_supported_hyphenation_languages", lualibvoikko_list_supported_hyphenation_languages},
  {"voikko_list_supported_grammar_checking_languages", lualibvoikko_list_supported_grammar_checking_languages},
  {"voikko_get_attribute_values", lualibvoikko_get_attribute_values},
  {NULL, NULL}
};
}


/** Initialises the library.
*/
extern "C" int luaopen_liblualibvoikko (lua_State *L)
{
  lua_newtable (L);
  luaL_setfuncs (L, lualibvoikko, 0);
  lua_setglobal (L, "lualibvoikko");
  return 1;
}
