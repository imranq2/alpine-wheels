import pyarrow as pa

data = [pa.array([1, 2, 3, 4]), pa.array(['foo', 'bar', 'baz', 'qux'])]

table = pa.table(data, names=['numbers', 'strings'])
print(table)
