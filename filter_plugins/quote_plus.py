from urllib.parse import quote_plus

class FilterModule(object):
    def filters(self):
        return {
            'quote_plus': quote_plus,
        }
