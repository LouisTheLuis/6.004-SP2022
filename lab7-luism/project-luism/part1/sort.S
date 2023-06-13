// TODO: Copy your quicksort.S file from Lab 2, overwriting this one

.section ".text.init"
    .globl sort

/* Python code for reference
# p is an integer array
# n is the number of elements in p: n == len(p)
def sort(p, n):
    quicksort(p, 0, n - 1)

def quicksort(p, start, end):      # Sort elements from p[start] to p[end]
    if (start < end):
        q = partition(p, start, end)
        quicksort(p, start, q - 1)
        quicksort(p, q + 1, end)

def partition(p, start, end):      # Divide p[start:end] into two subarrays, one with all
    pivot = p[end]                 # elements smaller or equal to a pivot value (the last
    i = start                      # value of input array), and another with all elements
    for j in range(start, end):    # larger than the pivot. Returns the index of the pivot.
        if (p[j] <= pivot):
            (p[i], p[j]) = (p[j], p[i]) # swap
            i += 1
    (p[i], p[end]) = (p[end], p[i]) # swap
    return i
*/
sort:
    // Your code (from Lab 2) here
    ret
