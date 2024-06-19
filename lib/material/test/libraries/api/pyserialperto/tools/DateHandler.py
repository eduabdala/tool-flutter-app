import datetime

class DateHandler():

    DEFAULT_FORMAT = "%Y-%m-%dT%H:%M:%S"

    @staticmethod
    def get_time(date=None, **kwargs):  # Date must be a datetime/date/time object
        if 'format' in kwargs:
            DateHandler.date_format = kwargs['format'] 
        else: 
            DateHandler.date_format = DateHandler.DEFAULT_FORMAT

        if date == None:
            DateHandler.date = DateHandler.get_current_time()
        else:
            DateHandler.date = date

        return DateHandler.date.strftime(DateHandler.date_format)

    @staticmethod
    def get_current_time():
        return datetime.datetime.now()

    @staticmethod
    def convert_time(times):
        return datetime.timedelta(hours=times[0], minutes=times[1], seconds=times[2], milliseconds=times[3], microseconds=times[4])
