
CREATE SCHEMA IF NOT EXISTS nlp; 

-- 0. Tokenyze the previous position : split the input string into words.
	DROP FUNCTION IF EXISTS nlp._plpy_tokenize_a_text( TEXT) ; 
	CREATE OR REPLACE FUNCTION nlp._plpy_tokenize_a_text(text_to_tokenize TEXT) RETURNS TEXT[] AS $$
""" given a string, use NLTK tokenyzer to split the string into an array of words. """
# getting the virtual env
import os ; venv_dir = "/var/lib/postgresql/11/main/python_3_venv/lobby" ; activate_script = os.path.join(venv_dir, "bin", "activate_this.py") ; exec(compile(open(activate_script, "rb").read(), activate_script, "exec") ,dict(__file__=activate_script))
# tokenize
from nltk import word_tokenize
# nltk.download('punkt')
return word_tokenize(text_to_tokenize)
	$$ LANGUAGE plpython3u PARALLEL SAFE IMMUTABLE STRICT;


DROP FUNCTION IF EXISTS nlp._plpy_find_keywords( input_string text, input_keywords text[], case_insensitive BOOLEAN) ; 
CREATE OR REPLACE FUNCTION nlp._plpy_find_keywords(input_string text, input_keywords text[], case_insensitive BOOLEAN DEFAULT FALSE) 
RETURNS TABLE(pos bigint, keyword text) AS $$
""" given a string and a list of keywoprds, find the positions of the keywords."""
res = []
for f in input_keywords:
    if case_insensitive is True:
        pos = input_string.lower().find(f)
    else:
        pos = input_string.find(f)
    if pos != -1:
        res.append([pos, f])
return res 
$$ LANGUAGE plpython3u PARALLEL SAFE IMMUTABLE STRICT;

SELECT *
FROM nlp._plpy_find_keywords('titi Toto tata', ARRAY['test','toto'], TRUE) ;  
