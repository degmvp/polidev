print('✅' * 50)
print('''
#---------------------------------------
# ✅ AppA02
# ✅ Python 3.6 alterado: 2018/08/02
# ✅ Objetivo:Cmd map,collections deque
#---------------------------------------''')
print('✅' * 50)
print('''
# ✅ self --> é uma variavel de classe
# ✅ self --> passa toda -->class<-- para
# ✅      --> dentro da definição -->def<--
#------------------------------------------''')
print('✅' * 50)

print('''
#---------------------------------------
# ✅ A função map
# ✅ map(pow, range(10))
#---------------------------------------''')


def pow(x):
    return x ** 2


mapa = map(pow, range(10))
print(*mapa)

ran = tuple(map(pow, range(10)))
print(ran)

print('''
#--------------------------------------------:
# ✅ os.path.exists() and os.path.isfile()
#--------------------------------------------''')
import os.path

print(os.path.exists('P:/app_advanced/app_tipB.py'))
print(os.path.exists('P:/app_advanced'))

print(os.path.isfile('P:/app_advanced/app_tipB.py'))
print(os.path.isfile('P:/app_advanced'))

print('''
#--------------------------------------------
# ✅ Using collections.deque as a Linked List
#--------------------------------------------''')
import collections

lst = collections.deque()

print('''
#--------------------------------------------
# Inserting elements at the front
# or back :deque(['A', 'B', 'C'])
#--------------------------------------------''')
lst.append('B')
lst.append('C')
lst.appendleft('A')
print(lst)

print('''
#--------------------------------------------
# However, inserting elements at
# arbitrary indexes takes O(n) time:
# deque(['A', 'B', 'X', 'C'])
#--------------------------------------------''')
lst.insert(2, 'X')
print(lst)

print('''
#--------------------------------------------
# Removing elements at the front
# or back takes O(1) time:deque(['B', 'X'])
#--------------------------------------------''')
lst.pop()
lst.popleft()
print(lst)

print('''
#--------------------------------------------
# Removing elements at arbitrary
# indexes or by key takes O(n) time again:
#--------------------------------------------''')
del lst[1]
lst.remove('B')
print(lst)

print('''
#--------------------------------------------
# Deques can be reversed in-place:
# deque(['C', 'X', 'B', 'A'])
#--------------------------------------------''')
lst = (['A', 'B', 'X', 'C'])
lst.reverse()
print(lst)

print('''
#--------------------------------------------
# Searching for elements takes
#--------------------------------------------''')
print(lst.index('X'))

print('''
#--------------------------------------------
✅ A Singly-Linked List Class in Python
#--------------------------------------------''')


class ListNode:
    """
    A node in a singly-linked list.
    """

    def __init__(self, data=None, next=None):
        self.data = data
        self.next = next

    def __repr__(self):
        return repr(self.data)


class SinglyLinkedList:
    def __init__(self):
        """
        Create a new singly-linked list.
        Takes O(1) time.
        """
        self.head = None

    def __repr__(self):
        """
        Return a string representation of the list.
        Takes O(n) time.
        """
        nodes = []
        curr = self.head
        while curr:
            nodes.append(repr(curr))
            curr = curr.next
        return '[' + ', '.join(nodes) + ']'

    def prepend(self, data):
        """
        Insert a new element at the beginning of the list.
        Takes O(1) time.
        """
        self.head = ListNode(data=data, next=self.head)

    def append(self, data):
        """
        Insert a new element at the end of the list.
        Takes O(n) time.
        """
        if not self.head:
            self.head = ListNode(data=data)
            return
        curr = self.head
        while curr.next:
            curr = curr.next
        curr.next = ListNode(data=data)

    def find(self, key):
        """
        Search for the first element with `data` matching
        `key`. Return the element or `None` if not found.
        Takes O(n) time.
        """
        curr = self.head
        while curr and curr.data != key:
            curr = curr.next
        return curr  # Will be None if not found

    def remove(self, key):
        """
        Remove the first occurrence of `key` in the list.
        Takes O(n) time.
        """
        # Find the element and keep a
        # reference to the element preceding it
        curr = self.head
        prev = None
        while curr and curr.data != key:
            prev = curr
            curr = curr.next
        # Unlink it from the list
        if prev is None:
            self.head = curr.next
        elif curr:
            prev.next = curr.next
            curr.next = None

    def reverse(self):
        """
        Reverse the list in-place.
        Takes O(n) time.
        """
        curr = self.head
        prev_node = None
        next_node = None
        while curr:
            next_node = curr.next
            curr.next = prev_node
            prev_node = curr
            curr = next_node
        self.head = prev_node


print('''
#--------------------------------------------
✅ A linked list class in practice:
✅ ['X', 42, 'a', 23, '1945', '1983']
#--------------------------------------------''')

lst = SinglyLinkedList()

lst.prepend(23)
lst.prepend('a')
lst.prepend(42)
lst.prepend('X')
lst.append('1945')
lst.append('1983')
print(lst)

lst.find('X')
elem = lst.find(42)
lst.remove('X')
print(lst)

print('''
#--------------------------------------------
✅ The set Built-in
#--------------------------------------------''')
vogais = {'a', 'e', 'i', 'o', 'u'}
print('e' in vogais)

nome = set('Degmar')
print(nome.intersection(vogais))

vogais.add('x')
print(vogais)
print(len(vogais))

nome.add('xx')
print(nome)

print('''
#--------------------------------------------
✅ The frozenset Built-in
#--------------------------------------------''')

vfro = frozenset({'a', 'e', 'i', 'o', 'u'})
print(vfro)

print('''
#--------------------------------------------
✅  The collections.Counter Class
#--------------------------------------------''')
from collections import Counter

inventory = Counter()
dbqty = {'proc', 'func', 'view''proc', 'func', 'view', 'func'}
dbqty = {'proc': 2, 'func': 3, 'view': 2}

print(dbqty)

inventory.update(dbqty)
print(inventory)

more_dbqty = {'proc': 4, 'func': 2, 'view': 1}
inventory.update(more_dbqty)
print(inventory)

print('total de elementos unicos -->: ', len(inventory))
print('total itens dos elementos -->: ', sum(inventory.values()))

print('total elemento -->proc<-- ', inventory['proc'])
print('total elemento -->func<-- ', inventory['func'])
print('total elemento -->view<-- ', inventory['view'])

print(list(inventory.elements()))
print(*inventory.elements())

print('''
#--------------------------------------------
✅ Python Underscore Naming Patterns -Summary
#--------------------------------------------''')

print('''
#--------------------------------------------
✅ Python Single Leading Underscore _var 
#--------------------------------------------''')

print('''
#--------------------------------------------
✅ Python Single Trailing Underscore var_ 
#--------------------------------------------''')

print('''
#--------------------------------------------
✅ Python Double Leading Underscore __var 
#--------------------------------------------''')

print('''
#--------------------------------------------
✅ Double Leading & Trailing Underscore __var__ 
#--------------------------------------------''')

print('''
#--------------------------------------------
✅ Python Single Underscore _ 
#--------------------------------------------''')

print('''
#--------------------------------------------
✅ _var : Naming convention indicating a name
          is meant for internal use.
✅ var_ : Used by convention to avoid naming
          conflicts with Python keywords
✅ __var: Triggers name mangling when used in
          a class context. Enforced by the
          Python interpreter.
 __var__: Indicates special methods defined
          by the Python language
✅      _: Sometimes used as a name for temporary
          or insignificant variables
#--------------------------------------------''')

