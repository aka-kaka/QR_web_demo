"""
    No Doc
"""


class MyException(Exception):
    """
    NO DOC
    """

    def __init__(self, *args):
        self.val = args

    def __str__(self):
        return f"{self.val}"
