-- Copyright (©) 2020 Hannu Väisänen
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.


-- Documentation of functions is copied form Libvoikko, files voikko.h
-- and Voikko.java, with some modifications.


-- This library should be used in the following manner:
--
-- require "Voikko"
-- Voikko.init ("fi", "/usr/local/lib/voikko")
--    Set options.
--    Use spell/suggest/hyphenate.
-- Voikko.terminate()

-- Add path to a folder where files liblualibvoikko.so and libvoikko.so are.
--
package.cpath = "/usr/local/lib/?.so;" .. package.cpath

require "liblualibvoikko"

local P = {}
Voikko = P


-- Initialises the library for use in the specified language, adding an extra directory
-- to the standard dictionary search path.
-- @param langcode BCP 47 language tag for the language to be used. Private use
--        subtags can be used to specify the dictionary variant.
--        For example, "fi" for Finnish spell checking, and "fi-x-sukija" for Sukija file indexer.
-- @param path Path to a directory from which dictionary files should be searched
--        first before looking into the standard dictionary locations. If NULL, no
--        additional search path will be used.
-- Prints an error message and stops if initialisation failed.
--
function P.init (langcode, path)
  lualibvoikko.voikko_init (langcode, path)
end


-- Terminates an instance of voikko.
--
function P.terminate()
  lualibvoikko.voikko_terminate()
end


-- Sets a boolean option.
-- @param option option name
-- @param value option value
-- @return 1 if option was successfully set, otherwise 0
--
function P.set_boolean_option (option, value)
  result = lualibvoikko.voikko_set_boolean_option (option, value)
  if result == 0 then
    error ("Could not set Boolean option " .. option .. " to value " .. value .. ".")
  end
end


-- Sets an integer option.
-- @param option option name
-- @param value option value
-- @return 1 if option was successfully set, otherwise 0
--
function P.set_integer_option (option, value)
  result = lualibvoikko.voikko_set_integer_option (option, value)
  if result == 0 then
    error ("Could not set integer option " .. option .. " to value " .. value .. ".")
  end
end


-- Checks the spelling of an UTF-8 character string.
-- @param word word to check
-- @return one of the spell checker return codes.
--
function P.spell (word)
  return lualibvoikko.voikko_spell (word)
end


-- Finds suggested correct spellings for given UTF-8 encoded word.
-- @param word word to find suggestions for
-- @return a table of suggestions in UTF-8 encoding. If no suggestions could
--         be generated, the table is empty.
--
function P.suggest (word)
  return lualibvoikko.voikko_suggest (word)
end


-- Hyphenates the given word in UTF-8 encoding.
-- @param word word to hyphenate
-- @return null-terminated character string containing the hyphenation using
-- the following notation:
--     ' ' = no hyphenation at this character,
--     '-' = hyphenation point (character at this position
--           is preserved in the hyphenated form),
--     '=' = hyphenation point (character at this position
--           is replaced by the hyphen.)
-- Returns an empty string on error.
--
function P.hyphenate (word)
  return lualibvoikko.voikko_hyphenate (word)
end


-- Hyphenates the given word in UTF-8 encoding.
-- @param word word to hyphenate
-- @param hyphen character string to insert at hyphenation positions
-- @param allowContextChanges boolean parameter that specifies wheter hyphens
--        may be inserted even if they alter the word in unhyphenated form.
-- @return null terminated character string where hyphens are inserted in all
--         hyphenation points
--
function P.insert_hyphens (word, hyphen, allowContextChanges)
  return lualibvoikko.voikko_insert_hyphens (word, hyphen, allowContextChanges)
end


-- Analyzes the morphology of given word.
-- @param word word to be analyzed.
-- @return A nested table of analysis results in (key,value) pairs.
--         Use print_analysis_result(analysis) to print the table.
--
function P.analyse_word (word)
  return lualibvoikko.voikko_analyse_word (word)
end


-- Return the version number of libvoikko.
-- @return The version number.
--
function P.get_version()
  return lualibvoikko.voikko_get_version()
end


-- Voikko defines from
-- grep 'define VOIKKO_' voikko_defines.h | grep -v DEFINES_H | gawk '{printf "%s = %s\n", $2, $3}'
VOIKKO_SPELL_FAILED = 0
VOIKKO_SPELL_OK = 1
VOIKKO_INTERNAL_ERROR = 2
VOIKKO_CHARSET_CONVERSION_FAILED = 3
VOIKKO_OPT_IGNORE_DOT = 0
VOIKKO_OPT_IGNORE_NUMBERS = 1
VOIKKO_OPT_IGNORE_UPPERCASE = 3
VOIKKO_OPT_ACCEPT_FIRST_UPPERCASE = 6
VOIKKO_OPT_ACCEPT_ALL_UPPERCASE = 7
VOIKKO_OPT_NO_UGLY_HYPHENATION = 4
VOIKKO_OPT_OCR_SUGGESTIONS = 8
VOIKKO_OPT_IGNORE_NONWORDS = 10
VOIKKO_OPT_ACCEPT_EXTRA_HYPHENS = 11
VOIKKO_OPT_ACCEPT_MISSING_HYPHENS = 12
VOIKKO_OPT_ACCEPT_TITLES_IN_GC = 13
VOIKKO_OPT_ACCEPT_UNFINISHED_PARAGRAPHS_IN_GC = 14
VOIKKO_OPT_HYPHENATE_UNKNOWN_WORDS = 15
VOIKKO_OPT_ACCEPT_BULLETED_LISTS_IN_GC = 16
VOIKKO_MIN_HYPHENATED_WORD_LENGTH = 9
VOIKKO_SPELLER_CACHE_SIZE = 17


-- TYPO and OCR are taken from file org/puimula/libvoikko/SuggestionStrategy.java

-- Suggestion strategy for correcting human typing errors. 
TYPO = 0

-- Suggestion strategy for correcting errors in text produced by
-- optical character recognition software.
OCR = 1


-- These functions and documentation is copied from libvoikko file Voikko.java

-- Ignore dot at the end of the word (needed for use in some word processors).
-- If this option is set and input word ends with a dot, spell checking and
-- hyphenation functions try to analyze the word without the dot if no results
-- can be obtained for the original form. Also with this option, string tokenizer
-- will consider trailing dot of a word to be a part of that word.
-- Default: false
--
function P.set_ignore_dot (value)
  set_boolean_option (0, value)
end


-- Ignore words containing numbers.
-- Default: false
--
function P.set_ignore_numbers (value)
  set_boolean_option (1, value)
end


-- Accept words that are written completely in uppercase letters without checking
-- them at all.
-- Default: false
--
function P.set_ignore_uppercase (value)
  set_boolean_option (3, value)
end


-- Accept words even when the first letter is in uppercase (start of sentence etc.)
-- Default: true
--
function P.set_accept_first_uppercase (value)
  set_boolean_option (6, value)
end


-- Accept words even when all of the letters are in uppercase. Note that this is
-- not the same as set_ignore_uppercase: with this option the word is still
-- checked, only case differences are ignored.
-- Default: true
--
function P.set_accept_all_uppercase (value)
  set_boolean_option (7, value)
end


-- (Spell checking only): Ignore non-words such as URLs and email addresses.
-- Default: true
--
function P.set_ignore_nonwords (value)
  set_boolean_option (10, value)
end


-- (Spell checking only): Allow some extra hyphens in words. This option relaxes
-- hyphen checking rules to work around some unresolved issues in the underlying
-- morphology, but it may cause some incorrect words to be accepted. The exact
-- behaviour (if any) of this option is not specified.
-- Default: false
--
function P.set_accept_extra_hyphens (value)
  set_boolean_option (11, value)
end


-- (Spell checking only): Accept missing hyphens at the start and end of the word.
-- Some application programs do not consider hyphens to be word characters. This
-- is reasonable assumption for many languages but not for Finnish. If the
-- application cannot be fixed to use proper tokenization algorithm for Finnish,
-- this option may be used to tell libvoikko to work around this defect.
-- Default: false
--
function P.set_accept_missing_hyphens (value)
  set_boolean_option (12, value)
end


-- (Grammar checking only): Accept incomplete sentences that could occur in
-- titles or headings. Set this option to true if your application is not able
-- to differentiate titles from normal text paragraphs, or if you know that
-- you are checking title text.
-- Default: false
--
function P.set_accept_titles_in_gc (value)
  set_boolean_option (13, value)
end


-- (Grammar checking only): Accept incomplete sentences at the end of the
-- paragraph. These may exist when text is still being written.
-- Default: false
--
function P.set_accept_unfinished_paragraphs_in_gc (value)
  set_boolean_option (14, value)
end


-- (Grammar checking only): Accept paragraphs if they would be valid within
-- bulleted lists.
-- Default: false
--
function P.set_accept_bulleted_lists_in_gc (value)
  set_boolean_option (16, value)
end


-- Do not insert hyphenation positions that are considered to be ugly but correct
-- Default: false
--
function P.set_no_ugly_hyphenation (value)
  set_boolean_option (4, value)
end


-- (Hyphenation only): Hyphenate unknown words.
-- Default: true
--
function P.set_hyphenate_unknown_words (value)
  set_boolean_option (15, value)
end


-- The minimum length for words that may be hyphenated. This limit is also enforced on
-- individual parts of compound words.
-- Default: 2
--
function P.set_min_hyphenated_word_length (length)
  set_integer_option(9, length)
end


-- Controls the size of in memory cache for spell checking results. 0 is the default size,
-- 1 is twice as large as 0 etc. -1 disables the spell checking cache entirely.
--
function P.set_speller_cache_size (size_param)
  set_integer_option(17, size_param)
end


-- Set the suggestion strategy to be used when generating spelling suggestions.
-- Default: TYPO
--
function P.set_suggestion_strategy (suggestion_strategy)
  assert ((suggestion_strategy == TYPO) or (suggestion_strategy == OCR))
  if suggestion_strategy == TYPO then
    set_boolean_option (8, false)
  elseif suggestion_strategy == OCR then
    set_boolean_option (8, true)
  end
end


-- Return a list of language codes representing the languages for which
-- at least one dictionary is available for spell checking.
-- The codes conform to those specified in BCP 47. Typically the returned
-- codes consist only of BCP 47 language subtags. They may also include
-- tags in format Language-Script, Language-Region or Language-Script-Region
-- if such variants are widely used for a particular language.
-- @param path path to a directory from which dictionary files should be searched
--        first before looking into the standard dictionary locations.
--
function P.list_supported_spelling_languages (path)
  return lualibvoikko.voikko_list_supported_spelling_languages (path)
end


-- Same as list_supported_spelling_languages but for hyphenation.
--
function P.list_supported_hyphenation_languages (path)
  return lualibvoikko.voikko_list_supported_hyphenation_languages (path)
end


-- Same as list_supported_spelling_languages but for grammar checking.
--
function P.list_supported_grammar_checking_languages (path)
  return lualibvoikko.voikko_list_supported_grammar_checking_languages (path)
end


-- Get list of possible attribute values in morphological analysis.
-- @param attribute_name name of morphological analysis attribute
-- Return a table of possible attribute values for attribute in morphological analysis.
-- If the attribute does not exist or it does not have a known finite set of possible values returns nil.
--
function P.get_attribute_values (attribute_name)
  return lualibvoikko.voikko_get_attribute_values (attribute_name)
end

-------------------------------------------------------------------------------
-- The following functions are additions to function declared in file voikko.h.


function P.print_table (table)
  assert (not (table == nil))
  for i, v in pairs (table) do
    print (i, v)
  end
end


-- Prints a nested table returned by functions
-- analyse_word(word) and get_analysis_keys(analysis)
-- @param nested_table  Table to print.
--
function P.print_nested_table (nested_table)
  assert (not (nested_table == nil))
  for i, v in pairs (nested_table) do
    print (i, v)
    for j, w in pairs(nested_table[i]) do print ("     ", j, w) end
  end
end


-- Get a property of analysis result(s).
-- @param analysis  Value returned by function analyse_word(word).
-- @param key       Key of a property whose value is wanted, e.g. "BASEFORM".
-- @return a table of values of property 'key'.
--
function P.get_analysis_property_value (analysis, key)
  assert (not (analysis == nil))
  local values = {}
  for i, v in pairs (analysis) do
    for j, w in pairs(analysis[i]) do 
--      print (key, j, w, type(key), type(j), type(w), (j==key))
      if j == key then
        table.insert (values, w)
--        print (w)
      end
    end
  end
  return values
end

-- Get a property of selected analysis result(s).
-- Example of usage is at the end of file examples.lua.
-- @param analysis  Value returned by function analyse_word(word).
-- @param f         Function that returns true if analysis result is to be selected.
-- @param key       Key of a property whose value is wanted, e.g. "BASEFORM".
-- @return a table of values of property 'key'.
--
function P.get_analysis_result (analysis, f, key)
  assert (not (analysis == nil))
  local values = {}
  for i, v in pairs (analysis) do
    if f(analysis[i]) then
      table.insert (values, analysis[i][key])
    end
  end
  return values
end


-- Lists the keys available within given morphology analysis result.
-- @param analysis Analysis to be examined.
-- @return Nested table of known keys within the result.
--
function P.get_analysis_keys (analysis)
  assert (not (analysis == nil))
  local list = {}
  for i, v in pairs (analysis) do
    local keys = {}
    for j, w in pairs(analysis[i]) do
      table.insert (keys, j)
    end
    table.insert (list, keys)
  end
  return list
end

return Voikko
