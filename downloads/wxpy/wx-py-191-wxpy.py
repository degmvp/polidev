class SampleApp(tk.Tk):
    def __init__(self, *args, **kwargs):
        ...
        self.frames = {}
        for F in (StartPage, PageOne, PageTwo, Page3):
            ...
        self.show_frame("StartPage")

    def show_frame(self, page_name):
        frame = self.frames[page_name]
        frame.tkraise()