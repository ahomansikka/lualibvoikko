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


require "Voikko"

Voikko.init ("fi", "/usr/local/lib/voikko")
s = Voikko.suggest ("voikkon")
Voikko.print_table (s)
print ("===============")

print ("spell0", Voikko.spell (""))

print ("spell1", Voikko.spell ("juveli"))
print ("spell2", Voikko.spell ("alusta"))

analysis = Voikko.analyse_word ("alusta")
Voikko.print_nested_table (analysis)

print ("Titityy")
t = Voikko.get_analysis_property_value (analysis, "BASEFORM")
print (t)
print ("=========")
for i, v in ipairs(Voikko.get_analysis_property_value (analysis, "BASEFORM")) do
  print (i, v)
end


t = Voikko.get_analysis_keys (analysis)
Voikko.print_nested_table (t)


t = Voikko.list_supported_spelling_languages ("/usr/local/lib/voikko")
Voikko.print_table (t)

t = Voikko.list_supported_hyphenation_languages ("/usr/local/lib/voikko")
Voikko.print_table (t)

t = Voikko.list_supported_grammar_checking_languages ("/usr/local/lib/voikko")
Voikko.print_table (t)


print ("get_attribute_values")
t = Voikko.get_attribute_values ("CLASS")
if not (t == nil) then
  Voikko.print_table (t)
end

Voikko.terminate()
