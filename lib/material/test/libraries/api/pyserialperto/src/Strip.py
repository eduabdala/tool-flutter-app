import itertools
import re

class Strip():
    """Buffer Content Strator

    Every exposed method must be high order function style.
    """

    class Error(Exception):
        """Failed strip
        """

    @staticmethod
    def none():
        """Does nothing
        """
        def __strip(text):
            return text
        return __strip

    @staticmethod
    def regex_or_pass(expression):
        """Extract with regex or repeat buffer.
        """
        def __strip(text):
            if isinstance(text, (str, bytes)):
                newtext = (text.decode('unicode_escape') if isinstance(text, bytes) else text)
                newtext = re.findall(expression, newtext) #find all match´s as array
                newtext = ''.join(tuple(itertools.chain(*newtext))) #unify groups/subgroup
                text = newtext if len(newtext) != 0 else text # use unstriped text when fails.
            return text
        return __strip

    @staticmethod
    def regex(expression):
        """Extract with regex or throw error.
        """
        def __strip(text):
            if isinstance(text, bytes) and isinstance(expression, bytes):
                newtext = re.findall(expression, text) #find all match´s as array
                newtext = b''.join(map(Strip.__joinByteTuple, newtext))
            elif isinstance(text, str) and isinstance(expression, str):
                newtext = re.findall(expression, text) #find all match´s as array
                newtext = ''.join(tuple(itertools.chain(*newtext)))
            elif isinstance(text, bytes) and isinstance(expression, str):
                newtext = re.findall(expression, text.decode()) #find all match´s as array
                newtext = ''.join(tuple(itertools.chain(*newtext)))
            else:
                msg = f"text({type(text).__name__})' and "
                msg += f"expression({type(expression).__name__}) types don't match."
                raise Strip.Error(msg)
            if len(newtext) == 0:
                raise Strip.Error(f"strip /{expression}/ not matching {text}")
            return newtext
        return __strip

    
    @staticmethod
    def __joinByteTuple(byte_tuple) -> bytes:
        return byte_tuple if isinstance(byte_tuple, bytes) else b''.join(byte_tuple)
