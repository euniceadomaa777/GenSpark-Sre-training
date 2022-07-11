class Storage: 
    def __init__(self):
        self.value = ""

    def store_value(self, value_to_store):
        self.value = value_to_store

    def print_value(self):
	    print(f"stored value is: {self.value}")

container = []        
storage1 = Storage()
storage1.store_value("eunice")

storage2 = Storage()
storage2.store_value("Kumar")

storage3 = Storage()
storage3.store_value("Mike")

storage4 = Storage()
storage4.store_value("Amos")

storage5 = Storage()
storage5.store_value("Shagy")

for i in [storage1, storage2, storage3, storage4, storage5]:
    container.append(i)
    
for curr_storage in container:
    curr_storage.print_value()